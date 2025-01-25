terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
    opensearch = {
      source = "opensearch-project/opensearch"
    }
  }
}
