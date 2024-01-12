provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "my-web-site" {
  bucket = "${var.bucket_name}hosting-bucket"

  tags = {
    Name        = "Hosting bucket"
    Environment = "Dev"
    Owner       = "Misyuro"
  }

  force_destroy = true
}

resource "aws_s3_object" "name" {
  bucket       = aws_s3_bucket.my-web-site.id
  for_each     = fileset("./web-site/", "**")
  key          = each.value
  content_type = "text/html"
  source       = "./web-site/${each.value}"
}

resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.my-web-site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "resource-block" {
  bucket = aws_s3_bucket.my-web-site.id

  block_public_acls   = false
  block_public_policy = false

}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.my-web-site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.my-web-site.arn}/*"
        ]
      },
    ],
  })
}
