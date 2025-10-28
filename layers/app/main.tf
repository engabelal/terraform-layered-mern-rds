provider "aws" {
  region = var.region
}

# --- Remote states for VPC & Database ---
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-layered-mern-rds-state"
    key    = "network/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = "terraform-layered-mern-rds-state"
    key    = "database/terraform.tfstate"
    region = var.region
  }
}

# --- Security group for the App ---
resource "aws_security_group" "app_sg" {
  name        = "mern-app-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mern-app-sg" }
}

# --- Allow App -> DB (3306) ---
resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.database.outputs.rds_sg_id
  source_security_group_id = aws_security_group.app_sg.id
}

# --- EC2 Instance ---
resource "aws_instance" "mern_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(data.terraform_remote_state.network.outputs.subnet_ids, 0)
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>MERN App Deployed via Terraform</h1><p>DB Endpoint: ${data.terraform_remote_state.database.outputs.db_endpoint}</p>" > /usr/share/nginx/html/index.html
              EOF

  tags = { Name = "mern-app-instance" }
}
