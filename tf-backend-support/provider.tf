# Setup our aws provider
variable "region" {
  default = "us-east-1"
}



provider "aws" {
  region = "${var.region}"
#  version = "4.26.0"
  profile = "default"
}
