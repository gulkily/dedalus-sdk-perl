# Web Search Agent

> Create a web search agent using multiple search MCPs to find and analyze information from the web.

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
          input="""I need to research the latest developments in AI agents for 2024.
          Please help me:
          1. Find recent news articles about AI agent breakthroughs
          2. Search for academic papers on multi-agent systems
          3. Look up startup companies working on AI agents
          4. Find GitHub repositories with popular agent frameworks
          5. Summarize the key trends and provide relevant links

          Focus on developments from the past 6 months.""",
          model="openai/gpt-4.1",
          mcp_servers=[
              "joerup/exa-mcp",        # Semantic search engine
              "simon-liang/brave-search-mcp"  # Privacy-focused web search
          ]
      )

      print(f"Web Search Results:\n{result.final_output}")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus, { DedalusRunner } from 'dedalus-labs';
  import * as dotenv from 'dotenv';

  dotenv.config();

  async function main() {
    const client = new Dedalus({
      apiKey: process.env.DEDALUS_API_KEY
    });

    const runner = new DedalusRunner(client);

    const result = await runner.run({
      input: `I need to research the latest developments in AI agents for 2024.
      Please help me:
      1. Find recent news articles about AI agent breakthroughs
      2. Search for academic papers on multi-agent systems
      3. Look up startup companies working on AI agents
      4. Find GitHub repositories with popular agent frameworks
      5. Summarize the key trends and provide relevant links

      Focus on developments from the past 6 months.`,
      model: 'openai/gpt-4.1',
      mcpServers: [
        'joerup/exa-mcp',              // Semantic search engine
        'simon-liang/brave-search-mcp' // Privacy-focused web search
      ]
    });

    console.log(`Web Search Results:\n${result.finalOutput}`);
  }

  main();
  ```
</CodeGroup>

<Tip>
  This example uses multiple search MCP servers:

  * **Exa MCP** (`joerup/exa-mcp`): Semantic search, great for finding conceptually related content
  * **Brave Search MCP** (`simon-liang/brave-search-mcp`): Privacy-focused web search for current events and specific queries

  Together, they cover more ground than either alone—Exa finds related ideas while Brave handles current events.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt