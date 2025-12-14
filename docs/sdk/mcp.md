# MCP Servers

> Connect to any model to any MCP server

The Dedalus SDK is a full MCP client. Connect your agents to any server that implements the [Model Context Protocol](https://modelcontextprotocol.io), hosted by you, us, or anyone else.

## Quickstart

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus, DedalusRunner
  from dotenv import load_dotenv

  load_dotenv()

  async def main():
      client = AsyncDedalus()
      runner = DedalusRunner(client)

      result = await runner.run(
          input="Use your tools to tell me "
          "some cool facts dedalus-labs/dedalus-sdk-python",
          model="openai/gpt-5-nano",

          # Any public MCP URL!
          mcp_servers=["https://mcp.deepwiki.com/mcp"]
      )

      print(result.final_output)

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { DedalusRunner } from 'dedalus-labs';

  const client = new Dedalus();
  const runner = new DedalusRunner(client);

  async function main() {
    const result = await runner.run({
      input: 'What is React? Give me a brief overview.',
      model: 'openai/gpt-4o-mini',

      # Any public MCP URL!
      mcpServers: ['https://mcp.deepwiki.com/mcp'],
    });

    console.log(result.finalOutput);
  }

  main();
  ```
</CodeGroup>

The agent discovers the server's tools and uses them when relevant.

Public MCP endpoints work out of the box. Self-hosted servers work the same way. If it speaks MCP over streamable HTTP, your agent can use it.

## Next Steps

See [Tools](/sdk/tools) to combine MCP servers with local functions, or browse our [Examples](/sdk/examples) for more patterns.

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt