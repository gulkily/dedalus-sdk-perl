# Quickstart

> Unified API for chat completions, embeddings, audio, and image generation across multiple AI providers

## Welcome to the Dedalus API

The Dedalus API provides a unified interface to interact with multiple AI model providers through a single, OpenAI-compatible API. Connect to models from OpenAI, Anthropic, Google, xAI, Mistral, DeepSeek, and more.

## Base URL

```
https://api.dedaluslabs.ai
```

## Authentication

All API endpoints require authentication using Bearer tokens. Include your API key in the `Authorization` header:

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
Authorization: Bearer YOUR_API_KEY
```

Or use the `X-API-Key` header:

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
X-API-Key: YOUR_API_KEY
```

Get your API key from the [Dedalus Dashboard](https://dedaluslabs.ai/dashboard).

## Key Features

* **Multi-Provider Support**: Access models from OpenAI, Anthropic, Google, xAI, and more through a single API
* **MCP Integration**: Connect to Model Context Protocol servers for enhanced tool calling
* **Streaming Support**: Real-time response streaming for all chat endpoints
* **Tool Calling**: Execute functions and tools during conversations
* **Multi-Model Routing**: Intelligent handoffs between different models

## SDKs

Use our official SDKs for easy integration:

<CardGroup cols={2}>
  <Card title="Python SDK" icon="python" href="/sdk/quickstart">
    Install with `pip install dedalus-labs`
  </Card>

  <Card title="TypeScript SDK" icon="js" href="/sdk/quickstart">
    Install with `npm install dedalus-labs`
  </Card>
</CardGroup>

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt