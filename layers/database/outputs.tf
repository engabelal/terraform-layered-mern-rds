output "db_endpoint" {
  description = "RDS endpoint to be used by the app layer"
  value       = aws_db_instance.mariadb.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mariadb.db_name
}

output "rds_sg_id" {
  description = "Security Group ID of the RDS instance"
  value       = aws_security_group.rds_sg.id
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.mariadb.username
}
