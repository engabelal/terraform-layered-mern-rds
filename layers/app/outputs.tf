output "app_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.mern_app.public_ip
}

output "app_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.mern_app.public_dns
}

output "app_sg_id" {
  description = "Security Group ID of the app"
  value       = aws_security_group.app_sg.id
}
