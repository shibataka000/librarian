output "bedrock_konowledge_base_id" {
  value = aws_bedrockagent_knowledge_base.library.id
}

output "bedrock_data_source_id" {
  value = aws_bedrockagent_data_source.books.data_source_id
}

output "bedrock_data_source_s3_bucket_name" {
  value = aws_s3_bucket.bedrock_data_source.bucket
}
