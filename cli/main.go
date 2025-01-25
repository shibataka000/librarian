package main

import (
	"context"
	"log"

	"github.com/spf13/cobra"
)

func main() {
	log.SetFlags(0)

	command := &cobra.Command{
		Use:   "librarian",
		Short: "The command line interface for the librarian.",
		Args:  cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs),
		RunE: func(_ *cobra.Command, args []string) error {
			ctx := context.Background()
			client, err := newBedrockClient(ctx)
			if err != nil {
				return err
			}
			response, err := client.invokeAgent(ctx, args[0])
			if err != nil {
				return err
			}
			log.Println(string(response))
			return nil
		},
		SilenceErrors: true,
		SilenceUsage:  true,
	}

	if err := command.Execute(); err != nil {
		log.Fatal(err)
	}
}
