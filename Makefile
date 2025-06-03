.DEFAULT_GOAL := help

.PHONY: help
help:
	@cat README.md

.PHONY: lint
lint:
	golangci-lint run

.PHONY: test
test:
	go test ./...

.PHONY: clean
clean:
	go clean -testcache

.PHONY: ingest
ingest:
	aws s3 sync ./books s3://$(shell terraform -chdir=terraform output -raw bedrock_data_source_s3_bucket_name)
	go tool ingest --knowledge-base-id "$(shell terraform -chdir=terraform output -raw bedrock_knowledge_base_id)" --data-source-id "$(shell terraform -chdir=terraform output -raw bedrock_data_source_id)"

.PHONY: invoke-agent
invoke-agent:
	go tool invokeagent --agent-id "$(shell terraform -chdir=terraform output -raw bedrock_agent_id)" prompt.txt
