
variable "project" {
  default = "news-project"
  type = string
  description = "The name of the project"
}

variable "region" {
  default = "us-east-1"
  type = string
  description = "The AWS region where resources will be created."
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC"
}

variable "subnet_id" {
  type = string
  description = "The ID of the Subnet"
}

variable "acm_cert" {
  type = string
  description = "The ARN of the ACM Certificate"
}



