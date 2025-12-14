# Weather Forecaster

> Detailed weather analysis with recommendations

Weather APIs return data. Users want recommendations. An agent with access to weather data can translate forecasts into actionable advice for specific situations.

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
          input="""I'm planning an outdoor wedding in San Francisco next weekend.

          Please provide:
          1. Current weather conditions
          2. 7-day forecast with daily details
          3. Precipitation probability
          4. Temperature highs and lows
          5. Wind and UV conditions
          6. Specific recommendations for outdoor event planning""",
          model="openai/gpt-4.1",
          mcp_servers=["cathy-di/open-meteo-mcp"]
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
      input: `I'm planning an outdoor wedding in San Francisco next weekend.

      Please provide:
      1. Current weather conditions
      2. 7-day forecast with daily details
      3. Precipitation probability
      4. Temperature highs and lows
      5. Wind and UV conditions
      6. Specific recommendations for outdoor event planning`,
      model: 'openai/gpt-4.1',
      mcpServers: ['cathy-di/open-meteo-mcp']
    });

    console.log(result.finalOutput);
  }

  main();
  ```
</CodeGroup>

## Open Meteo Capabilities

The `cathy-di/open-meteo-mcp` server provides:

* Current conditions
* Multi-day forecasts (hourly and daily)
* Historical weather data
* Weather alerts
* Global coverage (no API key required)

## Beyond Raw Data

Any API can fetch weather. The agent interprets it: wind affecting outdoor events, rain probability suggesting backup plans, UV levels for guest safety, temperature changes through the day.

Same pattern applies to any data-to-advice task. Health metrics become fitness recommendations. Market data becomes investment suggestions. Sensor readings become maintenance alerts.


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt