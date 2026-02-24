terraform {
  backend "s3" {
    bucket         = "matthew-terraform-state-12345"
    key            = "event-driven-aws/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}