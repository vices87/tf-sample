
# Create S3 bucket for terraform state files
# Create DYnamoDB for state lock

locals {
  project = "" #project name
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${local.project}-terraform-infra"
  force_destroy = true

  tags = {
     Name = "Bucket for terraform states of ${local.project}"
     createdBy = "infra-${local.project}/backend-support"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id = "rule-1"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_ownership]

  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${local.project}-terraform-locks"

  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
     Name = "Terraform Lock Table"
     createdBy = "infra-${local.project}/backend-support"
  }
}
