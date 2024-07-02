variable "region" {
  description = "AWS region"
  default     = "sa-east-1"
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
