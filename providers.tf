terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Using the shared credentials from `aws configure` (profile: default, region: us-east-1)
provider "aws" {
  region = "us-east-1"
}
