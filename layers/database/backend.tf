terraform {
  backend "s3" {
    bucket = "terraform-layered-mern-rds-state"
    key    = "database/terraform.tfstate"
    region = "eu-north-1"
  }
}
