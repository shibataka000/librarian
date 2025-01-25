package main

import (
	"context"
	"fmt"
	"slices"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagent"
	agenttypes "github.com/aws/aws-sdk-go-v2/service/bedrockagent/types"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime"
	agentruntimetypes "github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime/types"
	"github.com/google/uuid"
)

const (
	agentName    = "librarian"
	agentAliasID = "TSTALIASID"
)

type BedrockClient struct {
	agent        *bedrockagent.Client
	agentrumtime *bedrockagentruntime.Client
}

func newBedrockClient(ctx context.Context) (*BedrockClient, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return nil, err
	}
	return &BedrockClient{
		agent:        bedrockagent.NewFromConfig(cfg),
		agentrumtime: bedrockagentruntime.NewFromConfig(cfg),
	}, nil
}

func (c BedrockClient) listAgents(ctx context.Context) ([]agenttypes.AgentSummary, error) {
	agents := []agenttypes.AgentSummary{}
	params := &bedrockagent.ListAgentsInput{}
	for {
		output, err := c.agent.ListAgents(ctx, params)
		if err != nil {
			return nil, err
		}
		agents = append(agents, output.AgentSummaries...)
		if output.NextToken == nil {
			break
		}
		params.NextToken = output.NextToken
	}
	return agents, nil
}

func (c BedrockClient) findAgent(ctx context.Context, agentName string) (agenttypes.AgentSummary, error) {
	agents, err := c.listAgents(ctx)
	if err != nil {
		return agenttypes.AgentSummary{}, err
	}
	index := slices.IndexFunc(agents, func(agent agenttypes.AgentSummary) bool {
		return *agent.AgentName == agentName
	})
	if index == -1 {
		return agenttypes.AgentSummary{}, fmt.Errorf("agent '%s' was not found", agentName)
	}
	return agents[index], nil
}

func (c *BedrockClient) invokeAgent(ctx context.Context, prompt string) ([]byte, error) {
	agent, err := c.findAgent(ctx, agentName)
	if err != nil {
		return nil, err
	}
	sessionID, err := newSessionID()
	if err != nil {
		return nil, err
	}
	output, err := c.agentrumtime.InvokeAgent(ctx, &bedrockagentruntime.InvokeAgentInput{
		AgentAliasId: aws.String(agentAliasID),
		AgentId:      agent.AgentId,
		SessionId:    aws.String(sessionID),
		EnableTrace:  aws.Bool(true),
		InputText:    aws.String(prompt),
	})
	if err != nil {
		return nil, err
	}
	response := []byte{}
	stream := output.GetStream()
	for event := range stream.Events() {
		if chunk, ok := event.(*agentruntimetypes.ResponseStreamMemberChunk); ok {
			response = append(response, chunk.Value.Bytes...)
		}
	}
	return response, stream.Close()
}

func newSessionID() (string, error) {
	uuid, err := uuid.NewRandom()
	if err != nil {
		return "", err
	}
	return uuid.String(), nil
}
