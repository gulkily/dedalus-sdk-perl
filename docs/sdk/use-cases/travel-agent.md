# Travel Agent

> Creating a travel planning agent that can search for flights, hotels, and provide travel recommendations.

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
          input="""I'm planning a trip to Paris, France from San Francisco, CA
          for 3 days for Christmas in 2025. Can you help me find:
          1. Flight options and prices, give me the best option for the cheapest flight
          2. Hotel recommendations in central Paris
          3. Weather forecast for my travel dates
          4. Popular events during the Christmas season in Paris
          5. Give a quick summary of the trip and the results

          My budget is around $3000 total and I prefer mid-range accommodations. keep it succint in 300 words or less""",
          model="anthropic/claude-opus-4-5",
          mcp_servers=[
              "simon-liang/brave-search-mcp", # For travel information search
              "cathy-di/open-meteo-mcp",   # For weather at destination
              "windsor/ticketmaster-mcp"   # For events lookup
          ]
      )
      print(f"Travel Planning Results:\n{result.final_output}")

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
      input: `I'm planning a trip to Paris, France from San Francisco, CA
      for 3 days for Christmas in 2025. Can you help me find:
      1. Flight options and prices, give me the best option for the cheapest flight
      2. Hotel recommendations in central Paris
      3. Weather forecast for my travel dates
      4. Popular events during the Christmas season in Paris
      5. Give a quick summary of the trip and the results

      My budget is around $3000 total and I prefer mid-range accommodations. keep it succint in 300 words or less`,
      model: 'anthropic/claude-opus-4-5',
      mcpServers: [
        'simon-liang/brave-search-mcp', // For travel information search
        'cathy-di/open-meteo-mcp',      // For weather at destination
        'windsor/ticketmaster-mcp'      // For events lookup
      ]
    });

    console.log(`Travel Planning Results:\n${result.finalOutput}`);
  }

  main();
  ```
</CodeGroup>

<Tip>
  This travel agent example uses multiple MCP servers:

  * **Brave Search MCP** (`simon-liang/brave-search-mcp`): For finding current travel information, flight options, hotel reviews, and booking options
  * **Open Meteo MCP** (`cathy-di/open-meteo-mcp`): For weather forecasts at your destination
  * **Ticketmaster MCP** (`windsor/ticketmaster-mcp`): For finding concerts and events during your trip

  Try these servers out in your projects!
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt