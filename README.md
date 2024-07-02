# AWS Lambda DocumentDB Integration

This project demonstrates how to integrate AWS Lambda with Amazon DocumentDB. The Lambda function processes CSV files uploaded to an S3 bucket and updates the DocumentDB database with the parsed data.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Terraform Configuration](#terraform-configuration)
- [Deployment](#deployment)
- [Client configuration](#connecting-to-the-cluster-with-mongodb-compass)
- [Cleanup](#cleanup)

## Prerequisites

- AWS account with IAM permissions to create resources.
- A [key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html?icmpid=docs_ec2_console) for the bastion host 
- [Terraform](https://www.terraform.io/downloads.html) installed.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured.
- [Python](https://www.python.org/downloads/) and [pip](https://pip.pypa.io/en/stable/installation/) installed.
- [zip](https://infozip.sourceforge.net/) installed.


## Terraform Configuration

1. **Clone the repository**

    ```bash
    git clone https://github.com/VitalyUsik/neklo.git
    cd neklo
    ```

2. **Create a `.tfvars` file to store secrets**

    Create a `local.tfvars` file and add the following content:

    ```plaintext
    region                    = "your-region"
    vpc_cidr                  = "your-cidr-block" (default is "10.0.0.0/16")
    vpc_name                  = "your-vpc-name"
    azs                       = list of AZs (ex. [ "sa-east-1a", "sa-east-1b" ])
    public_subnets            = subnets cidrs (default [ "10.0.1.0/24", "10.0.2.0/24" ])
    private_subnets           = subnets cidrs (default [ "10.0.3.0/24" ])
    bucket_name               = "your-bucket-name" (should be globally unique)
    documentdb_cluster_id     = "your-cluster-id"
    documentdb_instance_class = "instance-type" (default "db.t3.medium")
    documentdb_db_name        = "your-db-name"
    lambda_function_name      = "your-lambda-name"
    whitelisted_ips           = "your-ip-address-to-whitelist"
    key_pair                  = "your-key-pair-name"
    documentdb_username       = "your-username"
    documentdb_password       = "your-password"

    ```

3. **Initialize Terraform**

    ```bash
    terraform init
    ```

## Deployment

1. **Package the Lambda Function**

    ```bash
    ./package.sh
    ```

2. **Deploy the Infrastructure**

    ```bash
    terraform apply -var-file="local.tfvars"
    ```

    Confirm the deployment when prompted.

3. **Upload cert file to S3**

    Download the cert file
    ```bash
    wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
    ```
    And upload it to the S3 bucket created in the previous step. This cert file will be used by the Lambda function to connect to the DocumentDB cluster.

## Connecting to the cluster with MongoDB Compass

Use the following connection string in your client:

`mongodb://<your-username>:<your-password>@<cluster-endpoint>:27017/?tls=true&tlsCAFile=<path to your global-bundle.pem file>&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false`

where:

* `your-username`   - the username you specified in the `local.tfvars` file
* `your-password`   - the password you specified in the `local.tfvars` file
* `cluster-endpoint`- the endpoint from Terraform output or from the AWS Web Console
* `tlsCAFile`       - the cert file your downloaded earlier

Then configure SSH Tunneling in "Proxy/SSH -> SSH with Identity File"

Use the IP address of the bastion host from Terraform outputs, `ubuntu` as username and your private key.

## Cleanup

To clean up the resources created by this project, run:

```bash
terraform destroy -var-file="secrets.tfvars"