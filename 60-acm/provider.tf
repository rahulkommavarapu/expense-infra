terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
  backend "s3" {
    bucket         = "83s-remote-state-devlop"
    key            = "expense-dev-acm"
    region         = "us-east-1"
    dynamodb_table = "83s-remote-state-devlop"
  }


}

provider "aws" {
  region = "us-east-1"
}