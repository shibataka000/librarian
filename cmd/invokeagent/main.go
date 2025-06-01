// Sends a prompt for the agent to process and respond to.
package main

import (
	"context"
	"fmt"
	"os"

	"github.com/shibataka000/librarian/internal/aws/bedrock"
	"github.com/spf13/cobra"
)

func main() {
	var (
		agentID string
	)

	command := &cobra.Command{
		Use:   "invokeagent <prompt-file>",
		Short: "Sends a prompt for the agent to process and respond to.",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			client, err := bedrock.NewClient(cmd.Context())
			if err != nil {
				return err
			}
			prompt, err := os.ReadFile(args[0])
			if err != nil {
				return err
			}
			response, err := client.InvokeAgent(cmd.Context(), agentID, string(prompt))
			if err != nil {
				return err
			}
			fmt.Println(string(response))
			return nil
		},
		SilenceUsage: true,
	}

	command.Flags().StringVar(&agentID, "agent-id", "", "The unique identifier of the agent to invoke.")

	for _, flag := range []string{"agent-id"} {
		if err := command.MarkFlagRequired(flag); err != nil {
			panic(err)
		}
	}

	if command.ExecuteContext(context.Background()) != nil {
		os.Exit(1)
	}
}
