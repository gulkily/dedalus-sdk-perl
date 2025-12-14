# Tools

> Give agents the ability to take actions

Agents become useful when they can do things beyond generating text. Tools let them call functions, query databases, make API requests—anything you can express in code.

## How It Works

Define a function with type hints and a docstring. Pass it to `runner.run()`. The SDK extracts the schema automatically and handles execution when the model decides to use it.

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus, DedalusRunner
  from dotenv import load_dotenv

  load_dotenv()

  def add(a: int, b: int) -> int:
      """Add two numbers."""
      return a + b

  def multiply(a: int, b: int) -> int:
      """Multiply two numbers."""
      return a * b

  async def main():
      client = AsyncDedalus()
      runner = DedalusRunner(client)

      result = await runner.run(
          input="Calculate (15 + 27) * 2",
          model="openai/gpt-4.1",
          tools=[add, multiply]
      )

      print(result.final_output)

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { DedalusRunner } from 'dedalus-labs';

  const client = new Dedalus();
  const runner = new DedalusRunner(client, true);

  function add(a: number, b: number): number {
    return a + b;
  }

  function multiply(a: number, b: number): number {
    return a * b;
  }

  async function main() {
    const result = await runner.run({
      input: 'Calculate (15 + 27) * 2',
      model: 'openai/gpt-4o-mini',
      tools: [add, multiply],
    });

    console.log((result as any).finalOutput);
  }

  main();
  ```
</CodeGroup>

The model sees the tool schemas, decides which to call, and the Runner executes them. Multi-step reasoning happens automatically—if a calculation requires calling `add` then `multiply`, the Runner handles the loop.

## Tool Requirements

Good tools have:

* **Type hints** on all parameters and return values
* **Docstrings** that explain what the tool does (the model reads these)
* **Clear names** that indicate purpose

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  # Good: typed, documented, clear name
  def get_weather(city: str, units: str = "celsius") -> dict:
      """Get current weather for a city. Returns temperature and conditions."""
      return {"temp": 22, "conditions": "sunny"}

  # Bad: no types, no docs, unclear name
  def do_thing(x):
      return some_api_call(x)
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  // Good: typed, documented, clear name
  function getWeather(city: string, units: string = 'celsius'): object {
    // Get current weather for a city
    return { temp: 22, conditions: 'sunny' };
  }

  // Bad: no types, unclear name
  function doThing(x: any) {
    return someApiCall(x);
  }
  ```
</CodeGroup>

## Async Tools

Tools can be async. The Runner awaits them automatically:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  async def fetch_user(user_id: int) -> dict:
      """Fetch user profile from database."""
      async with db.connection() as conn:
          return await conn.fetchone("SELECT * FROM users WHERE id = $1", user_id)
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  async function fetchUser(userId: number): Promise<object> {
    // Fetch user profile from database
    const result = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
    return result.rows[0];
  }
  ```
</CodeGroup>

## Combining with MCP Servers

Local tools and MCP servers work together. Use local tools for custom logic, MCP servers for common capabilities:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  def calculate_discount(price: float, percentage: float) -> float:
      """Calculate discounted price."""
      return price * (1 - percentage / 100)

  result = await runner.run(
      input="Find the price of AirPods Pro and calculate a 15% discount",
      model="openai/gpt-4o-mini",
      tools=[calculate_discount],
      mcp_servers=["tsion/brave-search-mcp"]
  )
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  function calculateDiscount(price: number, percentage: number): number {
    return price * (1 - percentage / 100);
  }

  const result = await runner.run({
    input: 'Find the price of AirPods Pro and calculate a 15% discount',
    model: 'openai/gpt-4.1',
    tools: [calculateDiscount],
    mcpServers: ['tsion/brave-search-mcp'],
  });
  ```
</CodeGroup>

## Model Selection

Tool calling quality varies by model. For reliable multi-step tool use:

<Tip>
  `openai/gpt-4o-mini` and `openai/gpt-4.1` handle complex tool chains well. Older or smaller models may struggle with multi-step reasoning.
</Tip>

## Next Steps

* **[Structured Outputs](/sdk/structured-outputs)** — Combine tools with typed responses
* **[Policies](/sdk/policies)** — Control tool execution dynamically
* **[Examples](/sdk/examples)** — See tool chaining in action

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt