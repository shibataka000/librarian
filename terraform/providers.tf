provider "aws" {}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.bedrock_knowledge_base.collection_endpoint
  healthcheck = false
}
