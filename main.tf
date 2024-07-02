provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "uploads" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]

  bucket = aws_s3_bucket.uploads.id
  acl    = "private"
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier = var.documentdb_cluster_id
  master_username    = "masterUser"
  master_password    = "masterPassword"
  engine_version     = "4.0.0"

  apply_immediately = true

  depends_on = [
    aws_s3_bucket.uploads,
  ]
}

resource "aws_docdb_cluster_instance" "instance" {
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = var.documentdb_instance_class
  apply_immediately  = true
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.lambda_function_name}_policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.uploads.arn}/*"
      },
      {
        Action = [
          "docdb:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_student_file.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

resource "aws_lambda_function" "process_student_file" {
  filename         = "lambda.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      DOCDB_CLUSTER_ENDPOINT = aws_docdb_cluster.docdb.endpoint
      DOCDB_DB_NAME          = var.documentdb_db_name
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_student_file.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
