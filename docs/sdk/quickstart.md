# Quickstart

> Get up and running with the Dedalus SDK in minutes

Install the SDK and make your first request.

## Installation

<CodeGroup>
  ```bash Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  pip install dedalus-labs
  ```

  ```bash npm theme={"theme":{"light":"github-light","dark":"github-dark"}}
  npm install dedalus-labs
  ```

  ```bash yarn theme={"theme":{"light":"github-light","dark":"github-dark"}}
  yarn add dedalus-labs
  ```

  ```bash pnpm theme={"theme":{"light":"github-light","dark":"github-dark"}}
  pnpm add dedalus-labs
  ```

  ```bash bun theme={"theme":{"light":"github-light","dark":"github-dark"}}
  bun add dedalus-labs
  ```
</CodeGroup>

## Set Your API Key

Get your API key from the [dashboard](https://dedaluslabs.ai/dashboard) and set it as an environment variable:

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
export DEDALUS_API_KEY="your-api-key"
```

Or use a `.env` file:

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
DEDALUS_API_KEY=your-api-key
```

## Your First Request

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus, DedalusRunner
  from dotenv import load_dotenv

  load_dotenv()

  async def main():
      client = AsyncDedalus()
      runner = DedalusRunner(client)

      response = await runner.run(
          input="What's the capital of France?",
          model="openai/gpt-4o-mini"
      )

      print(response.final_output)

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { DedalusRunner } from 'dedalus-labs';

  const client = new Dedalus();
  const runner = new DedalusRunner(client);

  async function main() {
    const response = await runner.run({
      input: "What's the capital of France?",
      model: 'openai/gpt-4o-mini',
    });

    console.log(response.finalOutput);
  }

  main();
  ```
</CodeGroup>

## Add MCP Servers

Connect to hosted MCP servers for web search, databases, and more:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  response = await runner.run(
      input="Who won Wimbledon 2025?",
      model="openai/gpt-4o-mini",
      mcp_servers=["tsion/brave-search-mcp"]
  )
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  const response = await runner.run({
    input: 'Who won Wimbledon 2025?',
    model: 'openai/gpt-4o-mini',
    mcpServers: ['tsion/brave-search-mcp'],
  });
  ```
</CodeGroup>

## Add Local Tools

Pass functions directly—the SDK handles schema generation:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  def add(a: int, b: int) -> int:
      """Add two numbers."""
      return a + b

  response = await runner.run(
      input="What's 15 + 27?",
      model="openai/gpt-4o-mini",
      tools=[add]
  )
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  function add(a: number, b: number): number {
    return a + b;
  }

  const response = await runner.run({
    input: "What's 15 + 27?",
    model: 'openai/gpt-4o-mini',
    tools: [add],
  });
  ```
</CodeGroup>

## Next Steps

You're ready to build. Explore the features:

* **[Tools](/sdk/tools)** — Define and execute local functions
* **[Structured Outputs](/sdk/structured-outputs)** — Type-safe JSON with Pydantic/Zod
* **[Streaming](/sdk/streaming)** — Real-time response streaming
* **[Images](/sdk/images)** — Generate and analyze images
* **[Handoffs](/sdk/handoffs)** — Multi-model routing
* **[Policies](/sdk/policies)** — Dynamic behavior control

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt