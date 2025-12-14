# Concert Planner

> Find concerts and venue information

Finding concert tickets involves checking dates, venues, seating options, and accessibility—information scattered across multiple pages on ticketing sites. An agent with access to Ticketmaster's API can consolidate this search.

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
          input="""I want to see Taylor Swift in New York City.

          Help me find:
          1. Upcoming concert dates
          2. Venue details
          3. Ticket price ranges
          4. Accessibility information
          5. Best seating options for the budget""",
          model="openai/gpt-4.1",
          mcp_servers=["windsor/ticketmaster-mcp"]
      )

      print(result.final_output)

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
      input: `I want to see Taylor Swift in New York City.

      Help me find:
      1. Upcoming concert dates
      2. Venue details
      3. Ticket price ranges
      4. Accessibility information
      5. Best seating options for the budget`,
      model: 'openai/gpt-4.1',
      mcpServers: ['windsor/ticketmaster-mcp']
    });

    console.log(result.finalOutput);
  }

  main();
  ```
</CodeGroup>

## Ticketmaster MCP

The `windsor/ticketmaster-mcp` server provides access to:

* Event search by artist, venue, or location
* Venue information and seating charts
* Ticket availability and pricing
* Event details and timing

## When to Use

This pattern works for any ticketed event: sports games, theater, festivals. The agent handles the search and comparison work, presenting options that match your criteria instead of making you browse through pages of results.


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt