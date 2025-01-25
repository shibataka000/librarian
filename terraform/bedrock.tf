resource "aws_bedrockagent_agent" "librarian" {
  agent_name              = "librarian"
  agent_resource_role_arn = aws_iam_role.bedrock_agent.arn
  foundation_model        = data.aws_bedrock_foundation_model.agent.id
  instruction             = "You are a question answering agent. The user will provide you with a question about contents in e-books in knowledge base. Your job is to answer the user's question by referring content in e-books in knowledge base."
}

resource "aws_bedrockagent_agent_knowledge_base_association" "library" {
  agent_id             = aws_bedrockagent_agent.librarian.id
  knowledge_base_id    = aws_bedrockagent_knowledge_base.library.id
  description          = "This knowledge base contains e-books."
  knowledge_base_state = "ENABLED"
}

resource "aws_bedrockagent_knowledge_base" "library" {
  name     = "library"
  role_arn = aws_iam_role.bedrock_knowledge_base.arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.knowledge_base_embedding.model_arn
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.bedrock_knowledge_base.arn
      vector_index_name = opensearch_index.default.name
      field_mapping {
        vector_field   = local.aoss_vector_field_name
        text_field     = local.aoss_text_field_name
        metadata_field = local.aoss_metadata_field_name
      }
    }
  }
}

resource "aws_bedrockagent_data_source" "books" {
  name                 = "books"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.library.id
  data_deletion_policy = "RETAIN"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.bedrock_data_source.arn
    }
  }
}

resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  count = var.bedrock_model_invocation_logging_enabled ? 1 : 0

  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_model_invocation_logging.name
      role_arn       = aws_iam_role.bedrock_model_invocation_logging.arn
    }
  }
}

data "aws_bedrock_foundation_model" "agent" {
  model_id = var.bedrock_agent_foundation_model_id
}

data "aws_bedrock_foundation_model" "knowledge_base_embedding" {
  model_id = var.bedrock_knowledge_base_embedding_model_id
}
