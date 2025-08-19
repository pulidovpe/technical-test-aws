#
# Archivo: providers.tf
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.12.2"
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}