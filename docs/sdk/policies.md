# Policies

> Control agent behavior dynamically at runtime

Policies let you inject logic at each step of agent execution. Add instructions, modify behavior, enforce constraints—all based on runtime context like step count, previous outputs, or external state.

## Basic Policy

A policy is a function that receives context and returns modifications:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus, DedalusRunner
  from dedalus_labs.utils.stream import stream_async
  from dotenv import load_dotenv

  load_dotenv()

  def policy(ctx: dict) -> dict:
      step = ctx.get("step", 1)
      
      if step >= 3:
          # After step 3, tell the model to wrap up
          return {
              "message_prepend": [
                  {"role": "system", "content": "Provide your final answer now."}
              ],
              "max_steps": 4
          }
      
      return {}

  async def main():
      client = AsyncDedalus()
      runner = DedalusRunner(client)

      result = runner.run(
          input="Research the history of the internet and summarize key milestones",
          model="openai/gpt-4o-mini",
          mcp_servers=["tsion/brave-search-mcp"],
          stream=True,
          policy=policy
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

  function policy(ctx: { step?: number }): object {
    const step = ctx.step ?? 1;
    
    if (step >= 3) {
      return {
        messagePrepend: [
          { role: 'system', content: 'Provide your final answer now.' }
        ],
        maxSteps: 4,
      };
    }
    
    return {};
  }

  async function main() {
    const result = await runner.run({
      input: 'Research the history of the internet and summarize key milestones',
      model: 'openai/gpt-4o-mini',
      mcpServers: ['tsion/brave-search-mcp'],
      stream: true,
      policy: policy,
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

## Policy Context

The `ctx` dict contains:

| Field          | Type | Description                        |
| -------------- | ---- | ---------------------------------- |
| `step`         | int  | Current execution step (1-indexed) |
| `messages`     | list | Conversation history so far        |
| `tools_called` | list | Tools invoked in previous steps    |

## Policy Returns

Policies can return:

| Field                                | Effect                                    |
| ------------------------------------ | ----------------------------------------- |
| `message_prepend` / `messagePrepend` | Messages added before the next model call |
| `message_append` / `messageAppend`   | Messages added after the conversation     |
| `max_steps` / `maxSteps`             | Override the maximum step count           |
| `stop`                               | Boolean to halt execution early           |

## Use Cases

**Rate limiting**: Track API calls across steps, pause if limits approached.

**Guardrails**: Check outputs for policy violations, inject correction prompts.

**Dynamic instructions**: Change behavior based on intermediate results.

**Cost control**: Stop execution after a certain number of expensive operations.

## Tool Event Callbacks

Monitor tool execution with `on_tool_event`:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import json

  def on_tool(evt: dict) -> None:
      print(f"Tool called: {json.dumps(evt)}")

  result = runner.run(
      input="Calculate shipping costs for a 5kg package to London",
      model="openai/gpt-4o-mini",
      tools=[calculate_shipping],
      on_tool_event=on_tool,
      policy=policy
  )
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  function onTool(evt: object): void {
    console.log('Tool called:', JSON.stringify(evt));
  }

  const result = await runner.run({
    input: 'Calculate shipping costs for a 5kg package to London',
    model: 'openai/gpt-4o-mini',
    tools: [calculateShipping],
    onToolEvent: onTool,
    policy: policy,
  });
  ```
</CodeGroup>

## Next Steps

* [**Tools**](/sdk/tools) — Define the tools policies can control

<Tip>
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt