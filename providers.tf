terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "devops-lab"

  default_tags {
    tags = {
      Project   = "verified-access-lab"
      ManagedBy = "terraform"
      Owner     = "giovanni"
    }
  }
}