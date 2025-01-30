terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
    backend "s3" {
    bucket = "daws78s.xyz-remote-state"
    key    = "remote-state"
    region = "us-east-1"
    dynamodb_table = "daws78s.xyz-locking-demo"
  }
}

provider "aws" {
  # Configuration options
 region = "us-east-1"
}