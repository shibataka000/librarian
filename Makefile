.DEFAULT_GOAL := lint

.PHONY: sync
sync:
	aws s3 sync ./books s3://$(shell terraform -chdir=terraform output -raw bedrock_data_source_s3_bucket_name)
	aws bedrock-agent start-ingestion-job --knowledge-base-id "$(shell terraform -chdir=terraform output -raw bedrock_konowledge_base_id)" --data-source-id "$(shell terraform -chdir=terraform output -raw bedrock_data_source_id)"

.PHONY: lint
lint:
	golangci-lint run

.PHONY: test
test:
	go test ./...

.PHONY: build
build:
	go build -C cmd/heimdall

.PHONY: install
install:
	go install -C cmd/heimdall

.PHONY: clean
clean:
	go clean -testcache

.PHONY: run
run: build
	./cmd/heimdall/heimdall up
	./cmd/heimdall/heimdall down
