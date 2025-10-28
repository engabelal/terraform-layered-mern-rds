terraform {
  backend "s3" {
    bucket = "terraform-layered-mern-rds-state"
    key    = "network/terraform.tfstate"
    region = "eu-north-1"
  }
}
