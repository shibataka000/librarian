package bedrock

import (
	"context"
	"errors"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagent"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagent/types"
)

type Client struct {
	bedrockagent *bedrockagent.Client
}

func NewClient(ctx context.Context) (*Client, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	return &Client{
		bedrockagent: bedrockagent.NewFromConfig(cfg),
	}, nil
}

func (c *Client) Ingest(ctx context.Context, knowledgeBaseID string, dataSourceID string) error {
	// Start the ingestion job.
	startIngestionJobOutput, err := c.bedrockagent.StartIngestionJob(ctx, &bedrockagent.StartIngestionJobInput{
		DataSourceId:    aws.String(dataSourceID),
		KnowledgeBaseId: aws.String(knowledgeBaseID),
	})
	if err != nil {
		return err
	}

	// Wait for the ingestion job to complete.
	for {
		getIngestionJobOutput, err := c.bedrockagent.GetIngestionJob(ctx, &bedrockagent.GetIngestionJobInput{
			DataSourceId:    startIngestionJobOutput.IngestionJob.DataSourceId,
			IngestionJobId:  startIngestionJobOutput.IngestionJob.IngestionJobId,
			KnowledgeBaseId: startIngestionJobOutput.IngestionJob.KnowledgeBaseId,
		})
		if err != nil {
			return err
		}
		switch getIngestionJobOutput.IngestionJob.Status {
		case types.IngestionJobStatusComplete:
			return nil
		case types.IngestionJobStatusFailed:
			return errors.New("ingestion job failed")
		case types.IngestionJobStatusStopped:
			return errors.New("ingestion job stopped")
		default:
			time.Sleep(10 * time.Second)
		}
	}
}
