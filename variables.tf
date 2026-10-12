variable "environment" {
  description = "Environment name (e.g. dev, stg, prod). Used to identify the deployment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "tags" {
  description = "Tags applied to the VPC."
  type        = map(string)
}
