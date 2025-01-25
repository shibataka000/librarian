locals {
  aoss_collection_name     = "bedrock-knowledge-base-${random_string.aoss_collection_name_suffix.result}"
  aoss_vector_field_name   = "bedrock-knowledge-base-default-vector"
  aoss_metadata_field_name = "AMAZON_BEDROCK_METADATA"
  aoss_text_field_name     = "AMAZON_BEDROCK_TEXT_CHUNK"
}
