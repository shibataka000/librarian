resource "aws_s3_bucket" "bedrock_data_source" {
  bucket_prefix = "books-"
  force_destroy = true
}
