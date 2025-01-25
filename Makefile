.DEFAULT_GOAL := sync

.PHONY: sync
sync:
	aws s3 sync ./books s3://$(shell terraform -chdir=terraform output -raw bedrock_data_source_s3_bucket_name)
	aws bedrock-agent start-ingestion-job --knowledge-base-id "$(shell terraform -chdir=terraform output -raw bedrock_konowledge_base_id)" --data-source-id "$(shell terraform -chdir=terraform output -raw bedrock_data_source_id)"
