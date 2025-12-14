# Handoffs

> Route tasks to different models based on their strengths

Different models excel at different tasks. GPT handles reasoning and tool use well. Claude writes better prose. Specialized models exist for code, math, and domain-specific work. Handoffs let agents route subtasks to the right model.

## How It Works

Pass a list of models instead of a single model. The agent can hand off to any model in the list based on what the task requires:

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
          input="Research the latest SpaceX launch, then write a creative blog post about it",
          model=["openai/gpt-4o-mini", "anthropic/claude-sonnet-4-20250514"],
          mcp_servers=["simon-liang/brave-search-mcp"]
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
      input: 'Research the latest SpaceX launch, then write a creative blog post about it',
      model: ['openai/gpt-4o-mini', 'anthropic/claude-sonnet-4-20250514'],
      mcpServers: ['simon-liang/brave-search-mcp'],
    });

    console.log((result as any).finalOutput);
  }

  main();
  ```
</CodeGroup>

The first model handles research (tool calling, information gathering). When it's time to write, it can hand off to Claude for the creative work.

## When to Use Handoffs

Handoffs shine when a task has distinct phases requiring different capabilities:

* **Research → Writing**: GPT gathers information, Claude writes the final piece
* **Analysis → Code**: A reasoning model plans the approach, a code model implements it
* **Triage → Specialist**: A general model routes to domain-specific models

For simple tasks where one model handles everything, stick to a single model.

## Model Strengths

A rough guide to model selection:

| Task                    | Good Models                                           |
| ----------------------- | ----------------------------------------------------- |
| Tool calling, reasoning | `openai/gpt-4o-mini`, `openai/gpt-4.1`                |
| Writing, creative work  | `anthropic/claude-sonnet-4-20250514`                  |
| Code generation         | `anthropic/claude-sonnet-4-20250514`, `openai/gpt-4o` |
| Fast, cheap responses   | `openai/gpt-4o-mini`                                  |

<Tip>
  Claude models use the format `anthropic/claude-sonnet-4-20250514`. Check the [providers guide](/guides/providers) for available models.
</Tip>

## Next Steps

* **[Policies](/sdk/policies)** — Control handoff logic dynamically
* **[Use Cases](/sdk/use-cases/data-analyst)** — See multi-capability workflows

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt