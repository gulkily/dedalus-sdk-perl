# Streaming

> Display responses as they're generated

Streaming shows output token-by-token instead of waiting for the complete response. Users see progress immediately, which matters for longer outputs or interactive applications.

## Basic Streaming

Set `stream=True` and use the streaming helper:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus, DedalusRunner
  from dedalus_labs.utils.stream import stream_async
  from dotenv import load_dotenv

  load_dotenv()

  async def main():
      client = AsyncDedalus()
      runner = DedalusRunner(client)

      result = runner.run(
          input="Explain how neural networks learn",
          model="openai/gpt-4o-mini",
          stream=True
      )

      await stream_async(result)

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { DedalusRunner } from 'dedalus-labs';

  const client = new Dedalus();
  const runner = new DedalusRunner(client, true);

  async function main() {
    const result = await runner.run({
      input: 'Explain how neural networks learn',
      model: 'openai/gpt-4o-mini',
      stream: true,
    });

    if (Symbol.asyncIterator in result) {
      for await (const chunk of result) {
        if (chunk.choices?.[0]?.delta?.content) {
          process.stdout.write(chunk.choices[0].delta.content);
        }
      }
    }
  }

  main();
  ```
</CodeGroup>

Output appears character-by-character as the model generates it.

## Sync Streaming (Python)

For Python scripts that don't need async:

```python  theme={"theme":{"light":"github-light","dark":"github-dark"}}
from dedalus_labs import Dedalus, DedalusRunner
from dedalus_labs.utils.stream import stream_sync
from dotenv import load_dotenv

load_dotenv()

def main():
    client = Dedalus()
    runner = DedalusRunner(client)

    result = runner.run(
        input="Explain how neural networks learn",
        model="openai/gpt-4o-mini",
        stream=True
    )

    stream_sync(result)

if __name__ == "__main__":
    main()
```

## When to Stream

Stream when:

* Building chat interfaces where perceived latency matters
* Generating long-form content (articles, code, analysis)
* Running in terminals or logs where progress feedback helps

Don't stream when:

* You need to parse the complete response before displaying
* Using structured outputs with `.parse()`
* Response time is already fast enough

## Streaming with Tools

Streaming works with tool-calling workflows. You'll see the model's reasoning and tool results as they happen:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  result = runner.run(
      input="Search for AI news and summarize the top story",
      model="openai/gpt-4o-mini",
      mcp_servers=["tsion/brave-search-mcp"],
      stream=True
  )

  await stream_async(result)
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  const result = await runner.run({
    input: 'Search for AI news and summarize the top story',
    model: 'openai/gpt-4o-mini',
    mcpServers: ['tsion/brave-search-mcp'],
    stream: true,
  });

  if (Symbol.asyncIterator in result) {
    for await (const chunk of result) {
      if (chunk.choices?.[0]?.delta?.content) {
        process.stdout.write(chunk.choices[0].delta.content);
      }
    }
  }
  ```
</CodeGroup>

## Next Steps

* **[Structured Outputs](/sdk/structured-outputs)** — Type-safe streaming with `.stream()`
* **[Examples](/sdk/examples)** — More streaming patterns

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt