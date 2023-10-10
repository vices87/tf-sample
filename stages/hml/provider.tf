
provider "aws" {
  region  = var.region
  profile = ""

}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "news-project-terraform-infra" 
    region         = "us-east-1"
    dynamodb_table = "news-project-terraform-infra"
    key            = "news/terraform.tfstate"
    profile        = ""
  }
}