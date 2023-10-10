resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.prefix}-static-page"
  force_destroy = true

}

resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = aws_s3_bucket.s3_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.s3_public_block,
    aws_s3_bucket_ownership_controls.s3_ownership,
  ]

  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "s3_policy" {
  depends_on = [
    aws_s3_bucket_public_access_block.s3_public_block,
    aws_s3_bucket_ownership_controls.s3_ownership,
  ]

  bucket = aws_s3_bucket.s3_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "newsBucketPolicy",
  "Statement": [
    {
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["${aws_s3_bucket.s3_bucket.arn}/*"]
    },
    {
      "Sid": "AllowBucketAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.s3_bucket.arn}"
    }
  ]
}
POLICY
}
