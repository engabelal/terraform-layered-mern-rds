variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "db_user" {
  description = "Database master username"
  default     = "admin"
}

variable "db_pass" {
  description = "Database master password"
  default     = "Password123!"
}

variable "db_name" {
  description = "Initial database name"
  default     = "mernappdb"
}
