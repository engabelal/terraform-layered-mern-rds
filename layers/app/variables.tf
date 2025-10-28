variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID"
  default     = "ami-0aa78f446b4499266"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t3.micro"
}
