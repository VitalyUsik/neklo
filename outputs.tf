output "cluter_endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}

output "bastion_host_ip" {
  value = aws_instance.bastion.public_ip
}