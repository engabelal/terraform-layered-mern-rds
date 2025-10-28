terraform {
  backend "s3" {
    bucket = "terraform-layered-mern-rds-state"
    key    = "app/terraform.tfstate"
    region = "eu-north-1"
  }
}
