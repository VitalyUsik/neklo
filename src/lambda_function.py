import os
import boto3
import csv
import json
from pymongo import MongoClient
from botocore.exceptions import ClientError

def get_credentials():
    secret_client = boto3.client('secretsmanager')
    try:
        secret_name = os.environ['DOCUMENTDB_SECRET_NAME']
        secret_value = secret_client.get_secret_value(SecretId=secret_name)

        secret = secret_value['SecretString']
        secret_json = json.loads(secret)
        username = secret_json['username']
        password = secret_json['password']

        return (username, password)

    except ClientError as e:
        raise e

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Download cert file from S3
    s3.download_file(bucket, 'global-bundle.pem', f'/tmp/global-bundle.pem')
    
    # Download file from S3
    download_path = f'/tmp/{key}'
    s3.download_file(bucket, key, download_path)
    
    # Connect to DocumentDB
    (username, password) = get_credentials()
    client = MongoClient(f'mongodb://{username}:{password}@{os.environ['DOCDB_CLUSTER_ENDPOINT']}:27017/?tls=true&tlsCAFile=/tmp/global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false')
    db = client[os.environ['DOCDB_DB_NAME']]
    
    # Ensure the database and collection exist
    collection_name = 'students'
    if collection_name not in db.list_collection_names():
        db.create_collection(collection_name)

    collection = db[collection_name]
    
    # Read and process the CSV file
    with open(download_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            student = {
                'student_id': int(row['student_id']),
                'first_name': row['first_name'],
                'last_name': row['last_name'],
                'date_of_birth': row['date_of_birth'],
                'year': int(row['year']),
                'quarter': int(row['quarter']),
                'grade': int(row['grade']),
                'email': row['email']
            }
            collection.update_one({'student_id': student['student_id']}, {'$set': student}, upsert=True)
    
    return {
        'statusCode': 200,
        'body': f'Successfully processed {key}'
    }
