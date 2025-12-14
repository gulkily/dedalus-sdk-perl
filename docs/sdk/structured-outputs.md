# Structured Outputs

> Type-safe JSON responses with Pydantic/Zod schemas

LLMs generate text. Applications need data structures. Structured outputs bridge this gap—define a schema (Pydantic in Python, Zod in TypeScript), and the SDK ensures responses conform with full type safety.

This is essential for building reliable applications. Instead of parsing free-form text and hoping for the best, you get validated objects that your code can trust.

## Client API

The client provides three methods for structured outputs:

* **`.parse()`** - Non-streaming with type-safe schemas
* **`.stream()`** - Streaming with type-safe schemas (context manager)
* **`.create()`** - Dict-based schemas only

### Basic Usage with .parse()

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class PersonInfo(BaseModel):
      name: str
      age: int
      occupation: str
      skills: list[str]

  async def main():
      client = AsyncDedalus()

      completion = await client.chat.completions.parse(
          model="openai/gpt-4o-mini",
          messages=[
              {"role": "user", "content": "Profile for Alice, 28, software engineer"}
          ],
          response_format=PersonInfo,
      )

      # Access parsed Pydantic model
      person = completion.choices[0].message.parsed
      print(f"{person.name}, {person.age}")
      print(f"Skills: {', '.join(person.skills)}")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const client = new Dedalus();

  const PersonInfo = z.object({
    name: z.string(),
    age: z.number(),
    occupation: z.string(),
    skills: z.array(z.string()),
  });

  async function main() {
    const completion = await client.chat.completions.parse({
      model: 'openai/gpt-4o-mini',
      messages: [
        { role: 'user', content: 'Profile for Alice, 28, software engineer' }
      ],
      response_format: zodResponseFormat(PersonInfo, 'person_info'),
    });

    // Access parsed object (type-safe)
    const person = completion.choices[0]?.message.parsed;
    console.log(`${person?.name}, ${person?.age}`);
    console.log(`Skills: ${person?.skills.join(', ')}`);
  }

  main();
  ```
</CodeGroup>

### Streaming with .stream()

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class PersonInfo(BaseModel):
      name: str
      age: int
      occupation: str
      skills: list[str]

  async def main():
      client = AsyncDedalus()

      # Use context manager for streaming
      async with client.chat.completions.stream(
          model="openai/gpt-4o-mini",
          messages=[{"role": "user", "content": "Profile for Bob, 32, data scientist"}],
          response_format=PersonInfo,
      ) as stream:
          # Process events as they arrive
          async for event in stream:
              if event.type == "content.delta":
                  print(event.delta, end="", flush=True)
              elif event.type == "content.done":
                  # Snapshot available at content.done
                  print(f"\nSnapshot: {event.parsed.name}")

          # Get final parsed result
          final = await stream.get_final_completion()
          person = final.choices[0].message.parsed
          print(f"\nFinal: {person.name}, {person.age}")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { DedalusRunner } from 'dedalus-labs';

  const client = new Dedalus();

  async function main() {
    const runner = new DedalusRunner(client, true);

    const result = await runner.run({
      model: 'openai/gpt-4o-mini',
      input: 'Count from 1 to 5, explaining each number briefly.',
      maxSteps: 1,
      stream: true,
    });

    // Check if result is streamable
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

### Optional Fields

Use `Optional[T]` in Python or `.nullable()` in Zod for nullable fields:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from typing import Optional
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class PartialInfo(BaseModel):
      name: str
      age: Optional[int] = None
      occupation: Optional[str] = None

  async def main():
      client = AsyncDedalus()

      completion = await client.chat.completions.parse(
          model="openai/gpt-4o-mini",
          messages=[{"role": "user", "content": "Just name: Dave"}],
          response_format=PartialInfo,
      )

      person = completion.choices[0].message.parsed
      print(f"Name: {person.name}")
      print(f"Age: {person.age or 'unknown'}")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const client = new Dedalus();

  const PartialInfo = z.object({
    name: z.string(),
    age: z.number().nullable(),
    email: z.string().nullable(),
  });

  async function main() {
    const completion = await client.chat.completions.parse({
      model: 'openai/gpt-4o-mini',
      messages: [
        { role: 'user', content: 'Extract: John Doe is a software engineer. Age unknown.' }
      ],
      response_format: zodResponseFormat(PartialInfo, 'person'),
    });

    const person = completion.choices[0]?.message.parsed;
    console.log(`Name: ${person?.name}`);
    console.log(`Age: ${person?.age ?? 'unknown'}`);
    console.log(`Email: ${person?.email ?? 'not provided'}`);
  }

  main();
  ```
</CodeGroup>

## Nested Models

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class Skill(BaseModel):
      name: str
      years_experience: int

  class DetailedProfile(BaseModel):
      name: str
      age: int
      skills: list[Skill]

  async def main():
      client = AsyncDedalus()

      completion = await client.chat.completions.parse(
          model="openai/gpt-4o-mini",
          messages=[{
              "role": "user",
              "content": "Profile for expert developer Alice, 28, with 5 years Python and 3 years Rust"
          }],
          response_format=DetailedProfile,
      )

      profile = completion.choices[0].message.parsed
      print(f"{profile.name}: {len(profile.skills)} skills")
      for skill in profile.skills:
          print(f"  - {skill.name}: {skill.years_experience}y")
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const client = new Dedalus();

  const OrderSchema = z.object({
    order_id: z.string(),
    customer: z.object({
      name: z.string(),
      email: z.string(),
    }),
    items: z.array(
      z.object({
        product: z.string(),
        quantity: z.number(),
        price: z.number(),
      }),
    ),
    total: z.number(),
  });

  async function main() {
    const completion = await client.chat.completions.parse({
      model: 'openai/gpt-4o-mini',
      messages: [{
        role: 'user',
        content: 'Create an order: Customer Alice (alice@example.com) bought 2 laptops at $999 each and 1 mouse at $25. Order ID: ORD-001',
      }],
      response_format: zodResponseFormat(OrderSchema, 'order'),
    });

    const order = completion.choices[0]?.message.parsed;
    console.log(`Order ID: ${order?.order_id}`);
    console.log(`Customer: ${JSON.stringify(order?.customer)}`);
    console.log(`Items: ${order?.items.length}`);
    console.log(`Total: $${order?.total}`);
  }

  main();
  ```
</CodeGroup>

## Structured Tool Calls

Define type-safe tools with automatic argument parsing:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class WeatherInfo(BaseModel):
      location: str
      temperature: int
      conditions: str

  async def main():
      client = AsyncDedalus()

      tools = [
          {
              "type": "function",
              "function": {
                  "name": "get_weather",
                  "description": "Get weather for a location",
                  "parameters": {
                      "type": "object",
                      "properties": {
                          "location": {"type": "string"}
                      },
                      "required": ["location"],
                      "additionalProperties": False,
                  },
                  "strict": True,
              }
          }
      ]

      completion = await client.chat.completions.parse(
          model="openai/gpt-4o-mini",
          messages=[{"role": "user", "content": "What's the weather in Paris?"}],
          tools=tools,
          response_format=WeatherInfo,
      )

      message = completion.choices[0].message
      if message.tool_calls:
          print(f"Tool called: {message.tool_calls[0].function.name}")
      elif message.parsed:
          print(f"Weather: {message.parsed.location}, {message.parsed.temperature}°C")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodFunction } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const client = new Dedalus();

  const CalculatorTool = zodFunction({
    name: 'calculator',
    parameters: z.object({
      operation: z.enum(['add', 'subtract', 'multiply', 'divide']),
      a: z.number(),
      b: z.number(),
    }),
    description: 'Perform basic arithmetic',
    function: (args) => {
      let result: number = 0;
      switch (args.operation) {
        case 'add': result = args.a + args.b; break;
        case 'subtract': result = args.a - args.b; break;
        case 'multiply': result = args.a * args.b; break;
        case 'divide': result = args.a / args.b; break;
      }
      return JSON.stringify({ result });
    },
  });

  async function main() {
    const completion = await client.chat.completions.parse({
      model: 'openai/gpt-4o-mini',
      messages: [{ role: 'user', content: 'Calculate 15 + 27' }],
      tools: [CalculatorTool],
    });

    const toolCall = completion.choices[0]?.message.tool_calls?.[0];
    if (toolCall) {
      console.log(`Tool called: ${toolCall.function.name}`);
      console.log(`Arguments: ${JSON.stringify(toolCall.function.parsed_arguments)}`);
    }
  }

  main();
  ```
</CodeGroup>

## Enums and Unions

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from typing import Literal
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class Task(BaseModel):
      title: str
      priority: Literal["low", "medium", "high", "urgent"]
      status: Literal["todo", "in_progress", "done"]
      assignee: str | None = None

  async def main():
      client = AsyncDedalus()

      completion = await client.chat.completions.parse(
          model="openai/gpt-4o-mini",
          messages=[{
              "role": "user",
              "content": "Create a high priority task: Fix authentication bug. Status: in progress. No assignee yet."
          }],
          response_format=Task,
      )

      task = completion.choices[0].message.parsed
      print(f"Task: {task.title}")
      print(f"Priority: {task.priority}, Status: {task.status}")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const client = new Dedalus();

  const TaskSchema = z.object({
    title: z.string(),
    priority: z.enum(['low', 'medium', 'high', 'urgent']),
    status: z.union([z.literal('todo'), z.literal('in_progress'), z.literal('done')]),
    assignee: z.string().nullable(),
  });

  async function main() {
    const completion = await client.chat.completions.parse({
      model: 'openai/gpt-4o-mini',
      messages: [{
        role: 'user',
        content: 'Create a high priority task: Fix authentication bug. Status: in progress. No assignee yet.',
      }],
      response_format: zodResponseFormat(TaskSchema, 'task'),
    });

    const task = completion.choices[0]?.message.parsed;
    console.log(`Task: ${task?.title}`);
    console.log(`Priority: ${task?.priority}, Status: ${task?.status}`);
  }

  main();
  ```
</CodeGroup>

## DedalusRunner API

The Runner supports `response_format` with automatic schema conversion:

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus, DedalusRunner
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class WeatherResponse(BaseModel):
      location: str
      temperature: int
      summary: str

  async def get_weather(location: str) -> str:
      """Get weather for a location."""
      return f"Sunny, 72°F in {location}"

  async def main():
      client = AsyncDedalus()
      runner = DedalusRunner(client)

      result = await runner.run(
          input="What's the weather in Paris?",
          model="openai/gpt-4o-mini",
          tools=[get_weather],
          response_format=WeatherResponse,
          max_steps=5,
      )

      print(result.final_output)

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { DedalusRunner } from 'dedalus-labs';

  const client = new Dedalus();

  function getCurrentTime() {
    return new Date().toISOString();
  }

  async function main() {
    const runner = new DedalusRunner(client, true);

    const result = await runner.run({
      model: 'openai/gpt-4o-mini',
      input: 'What time is it?',
      tools: [getCurrentTime],
      maxSteps: 2,
      stream: true,
      autoExecuteTools: true,
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

## .create() vs .parse() vs .stream()

| Method      | Schema Support | Streaming | Use Case                |
| ----------- | -------------- | --------- | ----------------------- |
| `.create()` | Dict only      | ✓         | Manual JSON schemas     |
| `.parse()`  | Pydantic/Zod   | ❌         | Type-safe non-streaming |
| `.stream()` | Pydantic/Zod   | ✓         | Type-safe streaming     |

<Note>
  `.create()` will throw a `TypeError` if you pass a Pydantic/Zod model directly. Use `.parse()` or `.stream()` for type-safe schemas.
</Note>

## Error Handling

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv
  from pydantic import BaseModel

  load_dotenv()

  class PersonInfo(BaseModel):
      name: str
      age: int

  async def main():
      client = AsyncDedalus()

      completion = await client.chat.completions.parse(
          model="openai/gpt-4o-mini",
          messages=[{"role": "user", "content": "Generate harmful content"}],
          response_format=PersonInfo,
      )

      message = completion.choices[0].message
      if message.refusal:
          print(f"Model refused: {message.refusal}")
      elif message.parsed:
          print(f"Parsed: {message.parsed.name}")
      else:
          print("No response or parsing failed")

  if __name__ == "__main__":
      asyncio.run(main())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const client = new Dedalus();

  const PersonSchema = z.object({
    name: z.string(),
    age: z.number(),
  });

  async function main() {
    try {
      const completion = await client.chat.completions.parse({
        model: 'openai/gpt-4o-mini',
        messages: [{ role: 'user', content: 'Profile for Alice, 28' }],
        response_format: zodResponseFormat(PersonSchema, 'person'),
      });

      const person = completion.choices[0]?.message.parsed;
      if (person) {
        console.log(`Parsed: ${person.name}, ${person.age}`);
      }
    } catch (error) {
      console.error('Request failed:', error);
    }
  }

  main();
  ```
</CodeGroup>

## Supported Models

The SDK's `.parse()` and `.stream()` methods work across all providers. Schema enforcement varies:

**Strict Enforcement** (CFG-based, schema guarantees):

* ✓ `openai/*` - Context-free grammar compilation
* ✓ `xai/*` - Native schema validation
* ✓ `fireworks_ai/*` - Native schema validation (select models)
* ✓ `deepseek/*` - Native schema validation (select models)

**Best-Effort** (schema sent for guidance, no guarantees):

* 🟡 `google/*` - Schema forwarded to `generationConfig.responseSchema`
* 🟡 `anthropic/*` - Prompt-based JSON generation (\~85-90% success rate)

<Warning>
  For `google/*` and `anthropic/*` models, always validate parsed output and implement retry logic.
</Warning>

## Provider Examples

Same code, different models. Swap the model string and everything else stays the same.

### Python

<CodeGroup>
  ```python OpenAI theme={"theme":{"light":"github-light","dark":"github-dark"}}
  from dedalus_labs import AsyncDedalus
  from pydantic import BaseModel

  class PersonInfo(BaseModel):
      name: str
      age: int
      occupation: str

  client = AsyncDedalus()
  result = await client.chat.completions.parse(
      model="openai/gpt-4o-mini",
      messages=[{"role": "user", "content": "Profile for Alice, 28, engineer"}],
      response_format=PersonInfo,
  )
  print(result.choices[0].message.parsed)
  ```

  ```python xAI theme={"theme":{"light":"github-light","dark":"github-dark"}}
  from dedalus_labs import AsyncDedalus
  from pydantic import BaseModel

  class PersonInfo(BaseModel):
      name: str
      age: int
      occupation: str

  client = AsyncDedalus()
  result = await client.chat.completions.parse(
      model="xai/grok-2-1212",
      messages=[{"role": "user", "content": "Profile for Alice, 28, engineer"}],
      response_format=PersonInfo,
  )
  print(result.choices[0].message.parsed)
  ```

  ```python DeepSeek theme={"theme":{"light":"github-light","dark":"github-dark"}}
  from dedalus_labs import AsyncDedalus
  from pydantic import BaseModel

  class PersonInfo(BaseModel):
      name: str
      age: int
      occupation: str

  client = AsyncDedalus()
  result = await client.chat.completions.parse(
      model="deepseek/deepseek-chat",
      messages=[{"role": "user", "content": "Profile for Alice, 28, engineer"}],
      response_format=PersonInfo,
  )
  print(result.choices[0].message.parsed)
  ```
</CodeGroup>

### TypeScript

<CodeGroup>
  ```typescript OpenAI theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const PersonInfo = z.object({
    name: z.string(),
    age: z.number(),
    occupation: z.string(),
  });

  const client = new Dedalus();
  const result = await client.chat.completions.parse({
    model: 'openai/gpt-4o-mini',
    messages: [{ role: 'user', content: 'Profile for Alice, 28, engineer' }],
    response_format: zodResponseFormat(PersonInfo, 'person'),
  });
  console.log(result.choices[0]?.message.parsed);
  ```

  ```typescript xAI theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const PersonInfo = z.object({
    name: z.string(),
    age: z.number(),
    occupation: z.string(),
  });

  const client = new Dedalus();
  const result = await client.chat.completions.parse({
    model: 'xai/grok-2-1212',
    messages: [{ role: 'user', content: 'Profile for Alice, 28, engineer' }],
    response_format: zodResponseFormat(PersonInfo, 'person'),
  });
  console.log(result.choices[0]?.message.parsed);
  ```

  ```typescript DeepSeek theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
  import { z } from 'zod';

  const PersonInfo = z.object({
    name: z.string(),
    age: z.number(),
    occupation: z.string(),
  });

  const client = new Dedalus();
  const result = await client.chat.completions.parse({
    model: 'deepseek/deepseek-chat',
    messages: [{ role: 'user', content: 'Profile for Alice, 28, engineer' }],
    response_format: zodResponseFormat(PersonInfo, 'person'),
  });
  console.log(result.choices[0]?.message.parsed);
  ```
</CodeGroup>

## Quick Reference

### Python (Pydantic)

```python  theme={"theme":{"light":"github-light","dark":"github-dark"}}
from dedalus_labs import AsyncDedalus
from pydantic import BaseModel

class MyModel(BaseModel):
    field: str

client = AsyncDedalus()
result = await client.chat.completions.parse(
    model="openai/gpt-4o-mini",
    messages=[...],
    response_format=MyModel,
)
parsed = result.choices[0].message.parsed
```

### TypeScript (Zod)

```typescript  theme={"theme":{"light":"github-light","dark":"github-dark"}}
import Dedalus from 'dedalus-labs';
import { zodResponseFormat } from 'dedalus-labs/helpers/zod';
import { z } from 'zod';

const MySchema = z.object({ field: z.string() });

const client = new Dedalus();
const result = await client.chat.completions.parse({
  model: 'openai/gpt-4o-mini',
  messages: [...],
  response_format: zodResponseFormat(MySchema, 'my_schema'),
});
const parsed = result.choices[0]?.message.parsed;
```

### Zod Helpers

```typescript  theme={"theme":{"light":"github-light","dark":"github-dark"}}
import { zodResponseFormat, zodFunction } from 'dedalus-labs/helpers/zod';

// For response schemas
zodResponseFormat(MyZodSchema, 'schema_name')

// For tool definitions
zodFunction({
  name: 'tool_name',
  description: 'What the tool does',
  parameters: z.object({ ... }),
  function: (args) => { ... },
})
```

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt