provider "aws" {
  region = var.region
}

# --- Get VPC details from network layer ---
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-layered-mern-rds-state"
    key    = "network/terraform.tfstate"
    region = var.region
  }
}

# --- Security Group for RDS ---
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow DB access from app SG"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "Allow MySQL/MariaDB from app layer"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for testing, restrict later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "rds-sg" }
}

# --- DB Subnet Group (2 subnets from network layer) ---
resource "aws_db_subnet_group" "db_subnets" {
  name        = "mariadb-subnet-group"
  subnet_ids  = data.terraform_remote_state.network.outputs.subnet_ids
  description = "Subnet group for MariaDB RDS"
}

# --- RDS Instance ---
resource "aws_db_instance" "mariadb" {
  identifier              = "mern-mariadb"
  allocated_storage       = 10
  engine                  = "mariadb"
  instance_class          = "db.t3.micro"
  username                = var.db_user
  password                = var.db_pass
  db_name                 = var.db_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  publicly_accessible     = true
  skip_final_snapshot     = true

  tags = { Name = "mern-rds" }
}
