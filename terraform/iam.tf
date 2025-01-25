resource "aws_iam_role" "bedrock_agent" {
  name_prefix        = "AmazonBedrockAgent-"
  assume_role_policy = data.aws_iam_policy_document.bedrock_agent_assume_role_policy.json
}

resource "aws_iam_policy" "bedrock_agent" {
  name_prefix = "AmazonBedrockAgent-"
  policy      = data.aws_iam_policy_document.bedrock_agent_policy.json
}

resource "aws_iam_role_policy_attachment" "bedrock_agent" {
  role       = aws_iam_role.bedrock_agent.name
  policy_arn = aws_iam_policy.bedrock_agent.arn
}

resource "aws_iam_role" "bedrock_knowledge_base" {
  name_prefix        = "AmazonBedrockKnowledgeBase-"
  assume_role_policy = data.aws_iam_policy_document.bedrock_knowledge_base_assume_role_policy.json
}

resource "aws_iam_policy" "bedrock_knowledge_base" {
  name_prefix = "AmazonBedrockKnowledgeBase-"
  policy      = data.aws_iam_policy_document.bedrock_knowledge_base_policy.json
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base" {
  role       = aws_iam_role.bedrock_knowledge_base.name
  policy_arn = aws_iam_policy.bedrock_knowledge_base.arn
}

resource "aws_iam_role" "bedrock_model_invocation_logging" {
  name_prefix        = "AmazonBedrockModelInvocationLogging-"
  assume_role_policy = data.aws_iam_policy_document.bedrock_model_invocation_logging_assume_role_policy.json
}

resource "aws_iam_policy" "bedrock_model_invocation_logging" {
  name_prefix = "AmazonBedrockModelInvocationLogging-"
  policy      = data.aws_iam_policy_document.bedrock_model_invocation_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "bedrock_model_invocation_logging" {
  role       = aws_iam_role.bedrock_model_invocation_logging.name
  policy_arn = aws_iam_policy.bedrock_model_invocation_logging.arn
}

data "aws_iam_policy_document" "bedrock_agent_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
    }
  }
}

data "aws_iam_policy_document" "bedrock_knowledge_base_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
    }
  }
}

data "aws_iam_policy_document" "bedrock_model_invocation_logging_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

data "aws_iam_policy_document" "bedrock_agent_policy" {
  statement {
    sid       = "BedrockInvokeModelStatement"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [data.aws_bedrock_foundation_model.agent.model_arn]
  }
  statement {
    sid       = "BedrockRetrieveStatement"
    effect    = "Allow"
    actions   = ["bedrock:Retrieve"]
    resources = [aws_bedrockagent_knowledge_base.library.arn]
  }
}

data "aws_iam_policy_document" "bedrock_knowledge_base_policy" {
  statement {
    sid       = "BedrockInvokeModelStatement"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [data.aws_bedrock_foundation_model.knowledge_base_embedding.model_arn]
  }
  statement {
    sid       = "OpenSearchServerlessAPIAccessAllStatement"
    effect    = "Allow"
    actions   = ["aoss:APIAccessAll"]
    resources = ["arn:aws:aoss:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:collection/${aws_opensearchserverless_collection.bedrock_knowledge_base.id}"]
  }
  statement {
    sid       = "S3ListBucketStatement"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.bedrock_data_source.arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
  statement {
    sid       = "S3GetObjectStatement"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bedrock_data_source.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "bedrock_model_invocation_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.bedrock_model_invocation_logging.arn}:log-stream:aws/bedrock/modelinvocations"]
  }
}
