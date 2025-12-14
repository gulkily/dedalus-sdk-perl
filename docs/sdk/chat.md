# Chat

> Send messages and get responses from any model

The core of the SDK: send a message, get a response. Works with any model from any provider.

## Hello World

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

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt