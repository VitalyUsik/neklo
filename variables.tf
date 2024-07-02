variable "region" {
  description = "AWS region"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
}

variable "azs" {
  type    = list(string)
}

variable "public_subnets" {
  type    = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "private_subnets" {
  type    = list(string)
  default = [ "10.0.3.0/24" ]
}

variable "bucket_name" {
  description = "S3 bucket name"
}

variable "documentdb_cluster_id" {
  description = "DocumentDB cluster identifier"
}

variable "documentdb_instance_class" {
  description = "DocumentDB instance class"
  default     = "db.t3.medium"
}

variable "documentdb_db_name" {
  description = "DocumentDB database name"
  default     = "studentdb"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  default     = "process_student_file"
}

variable "whitelisted_ips" {
  description = "The IP address from which you will connect to the database"
}

variable "key_pair" {
  description = "Your key pair to use to connect to the bastion host"
}

variable "documentdb_username" {
  description = "DocumentDB username"
}

variable "documentdb_password" {
  description = "DocumentDB password"
}

variable "documentdb_secret_name" {
  description = "Secrets Manager secret name for DocumentDB credentials"
  default     = "documentdb/credentials"
}