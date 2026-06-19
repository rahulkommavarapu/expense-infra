terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
  backend "s3" {
    bucket         = "rahul-remote-state"
    key            = "expense-dev-vpc"
    region         = "us-east-1"
    dynamodb_table = "83s-remote-state-env"
  }


}

provider "aws" {
  region = "us-east-1"
}