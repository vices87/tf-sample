
variable "project" {
  default = "news-project"
  type = string
  description = "Name of the project"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC"
}

variable "max_size" {
  type = string
  default = "Maximum size of instances"
}

variable "min_size" {
  type = string
  description = "Minimum size of instances"
}

variable "desired_size" {
  type = string
  description = "Desired size of instances"
}

variable "ebs_size" {
  type = string
  description = "Size of the EBS volume in GB"
}

variable "ebs_type" {
  type = string
  description = "The type of EBS disk"
}

variable "prefix" {
  type = string
  description = "The prefix of the project"
}

variable "instance_type" {
  type = string
  description = "The EC2 instance type"
}

variable "user_data" {
  type = string
  description = "The name of the User Data file"
}

variable "subnet_id" {
  type = string
  description = "The Subnet ID"
}


