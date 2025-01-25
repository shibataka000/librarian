# Librarian

## What's the librarian?

The librarian is a question answering agent. The user will provide it with a question about contents in e-books in knowledge base. Its job is to answer the user's question by referring content in e-books in knowledge base.

This is a sample app about [Amazon Bedrock](https://aws.amazon.com/bedrock/).

## Requirements

- AWS CLI
- Go
- Terraform
- [Access to Amazon Bedrock foundation models](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access-modify.html)

## Set up

1. Construct the knowledge base and the agent.

```bash
terraform -chdir=terraform init
terraform -chdir=terraform apply
```

2. Store e-books in [books](./books/) directory.
3. Send e-books to the knowledge base.

```bash
make sync
```

3. Build the CLI tool.

```bash
go install -C cli
```

## Usage

```bash
librarian <question>
```

## Clean up

```bash
terraform -chdir=terraform destroy
```

## References

- https://docs.aws.amazon.com/bedrock/latest/userguide/index.html
- https://github.com/aws-ia/terraform-aws-bedrock
