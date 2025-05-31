package main

import (
	"context"
	"fmt"
	"log"

	"github.com/shibataka000/librarian/internal/aws/bedrock"
	"github.com/spf13/cobra"
)

func main() {
	var (
		agentID string
	)

	log.SetFlags(0)

	command := &cobra.Command{
		Use:   "invokeagent",
		Short: "Sends a prompt for the agent to process and respond to.",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			client, err := bedrock.NewClient(cmd.Context())
			if err != nil {
				return err
			}
			response, err := client.InvokeAgent(cmd.Context(), agentID, "Hi!")
			if err != nil {
				return err
			}
			fmt.Println(response)
			return nil
		},
		SilenceUsage: true,
	}

	command.Flags().StringVar(&agentID, "agent-id", "", "The unique identifier of the agent to invoke.")

	for _, flag := range []string{"agent-id"} {
		if err := command.MarkFlagRequired(flag); err != nil {
			log.Fatal(err)
		}
	}

	if err := command.ExecuteContext(context.Background()); err != nil {
		log.Fatal(err)
	}
}
