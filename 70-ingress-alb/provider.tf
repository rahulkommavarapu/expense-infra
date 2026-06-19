terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
  backend "s3" {
    bucket         = "rahul-remote-state"
    key            = "expense-dev-ingrees-alb"
    region         = "us-east-1"
    # dynamodb_table = "83s-remote-state-env"
    use_lockfile = true
  }


}

provider "aws" {
  region = "us-east-1"
}