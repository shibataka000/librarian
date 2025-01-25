resource "aws_cloudwatch_log_group" "bedrock_model_invocation_logging" {
  name_prefix       = "/aws/bedrock/modelinvocations-"
  retention_in_days = 7
}
