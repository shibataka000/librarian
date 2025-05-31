.DEFAULT_GOAL := test

.PHONY: lint
lint:
	golangci-lint run

.PHONY: test
test:
	go test ./...

.PHONY: clean
clean:
	go clean -testcache

.PHONY: sync
sync:
	aws s3 sync ./books s3://$(shell terraform -chdir=terraform output -raw bedrock_data_source_s3_bucket_name)
	go tool startingestionjob

.PHONY: invoke-agent
invoke-agent:
	go tool invokeagent
