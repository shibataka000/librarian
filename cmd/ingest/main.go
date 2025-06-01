// Ingest the documents in the data source into the knowledge base.
package main

import (
	"context"
	"os"

	"github.com/shibataka000/librarian/internal/aws/bedrock"
	"github.com/spf13/cobra"
)

func main() {
	var (
		knowledgeBaseID string
		dataSourceID    string
	)

	command := &cobra.Command{
		Use:   "ingest",
		Short: "Ingest the documents in the data source into the knowledge base.",
		RunE: func(cmd *cobra.Command, _ []string) error {
			client, err := bedrock.NewClient(cmd.Context())
			if err != nil {
				return err
			}
			return client.Ingest(cmd.Context(), knowledgeBaseID, dataSourceID)
		},
		SilenceUsage: true,
	}

	command.Flags().StringVar(&knowledgeBaseID, "knowledge-base-id", "", "The unique identifier of the knowledge base for the data ingestion job.")
	command.Flags().StringVar(&dataSourceID, "data-source-id", "", "The unique identifier of the data source you want to ingest into your knowledge base.")

	for _, flag := range []string{"knowledge-base-id", "data-source-id"} {
		if err := command.MarkFlagRequired(flag); err != nil {
			panic(err)
		}
	}

	if command.ExecuteContext(context.Background()) != nil {
		os.Exit(1)
	}
}
