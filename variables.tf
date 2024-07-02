variable "region" {
  description = "AWS region"
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "neklo-vpc"
}

variable "azs" {
  type    = list(string)
  default = [ "sa-east-1a", "sa-east-1b" ]
}

variable "public_subnets" {
  type    = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "477911757103-neklo-students-bucket"
}

variable "documentdb_cluster_id" {
  description = "DocumentDB cluster identifier"
  default     = "docdb-cluster"
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
  default     = "0.0.0.0/0"
}