# Response Schemas

> Reference for all API response objects and their structure

This page documents all response schemas returned by the Dedalus API. All responses follow OpenAI-compatible formats.

***

## Dedalus Runner

<ResponseField name="RunResult" type="object">
  Response object returned by the `DedalusRunner` for non-streaming tool execution runs.

  <Expandable title="Properties">
    <ParamField path="final_output" type="string" required>
      Final text output from the conversation after all tool executions complete
    </ParamField>

    <ParamField path="tool_results" type="array" required>
      List of all tool execution results from the run

      <Expandable title="Tool Result Properties">
        <ParamField path="name" type="string">
          Name of the tool that was executed
        </ParamField>

        <ParamField path="result" type="any">
          The result returned by the tool execution
        </ParamField>

        <ParamField path="step" type="integer">
          The step number when this tool was executed
        </ParamField>

        <ParamField path="error" type="string">
          Error message if the tool execution failed
        </ParamField>
      </Expandable>
    </ParamField>

    <ParamField path="steps_used" type="integer" required>
      Total number of steps (LLM calls) used during the run
    </ParamField>

    <ParamField path="tools_called" type="array" required>
      List of tool names that were called during the run
    </ParamField>

    <ParamField path="messages" type="array" required>
      Full conversation history including system prompts, user messages, assistant responses, and tool calls/results. Useful for debugging, logging, or continuing conversations.
    </ParamField>

    <ParamField path="intents" type="array">
      Optional list of detected intents (when `return_intent=true`)
    </ParamField>

    <ParamField path="output" type="string">
      Alias for `final_output` (legacy compatibility)
    </ParamField>

    <ParamField path="content" type="string">
      Alias for `final_output` (legacy compatibility)
    </ParamField>
  </Expandable>

  <Expandable title="Methods">
    <ParamField path="to_input_list()" type="method">
      Returns a copy of the full conversation history (`messages`) for use in follow-up runs. Enables multi-turn conversations by passing the result to subsequent `runner.run()` calls.
    </ParamField>
  </Expandable>
</ResponseField>

```python Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
from dedalus_labs import Dedalus, DedalusRunner

client = Dedalus(api_key="YOUR_API_KEY")
runner = DedalusRunner(client)

def get_weather(location: str) -> str:
    """Get the current weather for a location."""
    return f"The weather in {location} is sunny and 72°F"

result = runner.run(
    input="What's the weather like in San Francisco?",
    tools=[get_weather],
    model="openai/gpt-5-nano",
    max_steps=5
)

# Access result properties
print(result.final_output)   # "The weather in San Francisco is sunny and 72°F"
print(result.steps_used)     # e.g., 2
print(result.tools_called)   # ["get_weather"]
print(result.tool_results)   # [{"name": "get_weather", "result": "The weather...", "step": 1}]
```

```python Accessing Message History theme={"theme":{"light":"github-light","dark":"github-dark"}}
import json

# Print the full conversation history
for msg in result.messages:
    role = msg.get("role")
    content = msg.get("content", "")
    
    if role == "user":
        print(f"User: {content}")
    elif role == "assistant":
        if msg.get("tool_calls"):
            tools = [tc["function"]["name"] for tc in msg["tool_calls"]]
            print(f"Assistant: [calling {', '.join(tools)}]")
        else:
            print(f"Assistant: {content}")
    elif role == "tool":
        print(f"Tool Result: {content[:100]}...")

# Store message history to JSON for logging/debugging
with open("conversation_log.json", "w") as f:
    json.dump(result.messages, f, indent=2)

# Continue the conversation with message history
follow_up = runner.run(
    messages=result.to_input_list(),  # Pass previous conversation
    input="What about New York?",      # Add new user message
    tools=[get_weather],
    model="openai/gpt-5-nano"
)
```

```json Example Response theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "final_output": "The weather in San Francisco is sunny and 72°F",
  "tool_results": [
    {
      "name": "get_weather",
      "result": "The weather in San Francisco is sunny and 72°F",
      "step": 1
    }
  ],
  "steps_used": 2,
  "tools_called": ["get_weather"],
  "messages": [
    {"role": "user", "content": "What's the weather like in San Francisco?"},
    {"role": "assistant", "tool_calls": [{"id": "call_abc123", "type": "function", "function": {"name": "get_weather", "arguments": "{\"location\": \"San Francisco\"}"}}]},
    {"role": "tool", "tool_call_id": "call_abc123", "content": "The weather in San Francisco is sunny and 72°F"},
    {"role": "assistant", "content": "The weather in San Francisco is sunny and 72°F"}
  ],
  "intents": null
}
```

***

## Chat Completions

<ResponseField name="ChatCompletion" type="object">
  The complete response object for non-streaming chat completions.

  <Expandable title="Properties">
    <ParamField path="id" type="string" required>
      Unique identifier for the chat completion
    </ParamField>

    <ParamField path="object" type="string" required>
      Object type, always `chat.completion`
    </ParamField>

    <ParamField path="created" type="integer" required>
      Unix timestamp (seconds) when the completion was created
    </ParamField>

    <ParamField path="model" type="string" required>
      The model used for completion (e.g., `openai/gpt-5-nano`)
    </ParamField>

    <ParamField path="choices" type="array" required>
      List of completion choices

      <Expandable title="Choice Properties">
        <ParamField path="index" type="integer">
          Index of this choice
        </ParamField>

        <ParamField path="message" type="object">
          The generated message

          <Expandable title="Message Properties">
            <ParamField path="role" type="string">
              Role of the message author (`assistant`, `tool`, etc.)
            </ParamField>

            <ParamField path="content" type="string">
              The content of the message
            </ParamField>

            <ParamField path="tool_calls" type="array">
              List of tool calls made by the model
            </ParamField>
          </Expandable>
        </ParamField>

        <ParamField path="finish_reason" type="string">
          Why the generation stopped: `stop`, `length`, `tool_calls`, `content_filter`
        </ParamField>

        <ParamField path="logprobs" type="object">
          Log probability information for tokens
        </ParamField>
      </Expandable>
    </ParamField>

    <ParamField path="usage" type="object" required>
      Token usage statistics

      <Expandable title="Usage Properties">
        <ParamField path="prompt_tokens" type="integer">
          Number of tokens in the prompt
        </ParamField>

        <ParamField path="completion_tokens" type="integer">
          Number of tokens in the completion
        </ParamField>

        <ParamField path="total_tokens" type="integer">
          Total tokens used (prompt + completion)
        </ParamField>
      </Expandable>
    </ParamField>

    <ParamField path="system_fingerprint" type="string">
      System fingerprint for reproducibility
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "openai/gpt-5-nano",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Hello! I'm doing well, thank you for asking."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 13,
    "completion_tokens": 12,
    "total_tokens": 25
  }
}
```

***

<ResponseField name="ChatCompletionChunk" type="object">
  Streamed response chunks for streaming completions (`stream=true`).

  <Expandable title="Properties">
    <ParamField path="id" type="string" required>
      Unique identifier for the chat completion
    </ParamField>

    <ParamField path="object" type="string" required>
      Object type, always `chat.completion.chunk`
    </ParamField>

    <ParamField path="created" type="integer" required>
      Unix timestamp when the chunk was created
    </ParamField>

    <ParamField path="model" type="string" required>
      The model being used
    </ParamField>

    <ParamField path="choices" type="array" required>
      List of chunk choices

      <Expandable title="Choice Properties">
        <ParamField path="index" type="integer">
          Index of this choice
        </ParamField>

        <ParamField path="delta" type="object">
          Incremental content delta

          <Expandable title="Delta Properties">
            <ParamField path="role" type="string">
              Role (only in first chunk)
            </ParamField>

            <ParamField path="content" type="string">
              Incremental content string
            </ParamField>

            <ParamField path="tool_calls" type="array">
              Incremental tool call updates
            </ParamField>
          </Expandable>
        </ParamField>

        <ParamField path="finish_reason" type="string">
          Reason for completion (only in final chunk): `stop`, `length`, `tool_calls`, `content_filter`, or `null`
        </ParamField>
      </Expandable>
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion.chunk",
  "created": 1677652288,
  "model": "openai/gpt-5-nano",
  "choices": [
    {
      "index": 0,
      "delta": {
        "content": "Hello"
      },
      "finish_reason": null
    }
  ]
}
```

***

## Embeddings

<ResponseField name="CreateEmbeddingResponse" type="object">
  Response object for embedding creation requests.

  <Expandable title="Properties">
    <ParamField path="object" type="string" required>
      Object type, always `list`
    </ParamField>

    <ParamField path="data" type="array" required>
      List of embedding objects

      <Expandable title="Embedding Properties">
        <ParamField path="object" type="string">
          Object type, always `embedding`
        </ParamField>

        <ParamField path="embedding" type="array">
          The embedding vector (array of floats)
        </ParamField>

        <ParamField path="index" type="integer">
          Index of this embedding
        </ParamField>
      </Expandable>
    </ParamField>

    <ParamField path="model" type="string" required>
      The model used to generate embeddings
    </ParamField>

    <ParamField path="usage" type="object" required>
      Token usage information

      <Expandable title="Usage Properties">
        <ParamField path="prompt_tokens" type="integer">
          Number of tokens in the input
        </ParamField>

        <ParamField path="total_tokens" type="integer">
          Total tokens processed
        </ParamField>
      </Expandable>
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [
        0.0023064255,
        -0.009327292,
        -0.0028842222
      ],
      "index": 0
    }
  ],
  "model": "openai/text-embedding-3-small",
  "usage": {
    "prompt_tokens": 8,
    "total_tokens": 8
  }
}
```

***

## Models

<ResponseField name="ListModelsResponse" type="object">
  Response object for listing available models.

  <Expandable title="Properties">
    <ParamField path="object" type="string" required>
      Object type, always `list`
    </ParamField>

    <ParamField path="data" type="array" required>
      List of model objects

      <Expandable title="Model Properties">
        <ParamField path="id" type="string">
          Model identifier (e.g., `openai/gpt-5-nano`, `anthropic/claude-3-5-sonnet`)
        </ParamField>

        <ParamField path="object" type="string">
          Object type, always `model`
        </ParamField>

        <ParamField path="created" type="integer">
          Unix timestamp when the model was created
        </ParamField>

        <ParamField path="owned_by" type="string">
          Organization owning the model (e.g., `openai`, `anthropic`, `google`)
        </ParamField>
      </Expandable>
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "object": "list",
  "data": [
    {
      "id": "openai/gpt-5-nano",
      "object": "model",
      "created": 1687882411,
      "owned_by": "openai"
    },
    {
      "id": "anthropic/claude-3-5-sonnet",
      "object": "model",
      "created": 1686935002,
      "owned_by": "anthropic"
    }
  ]
}
```

***

## Images

<ResponseField name="ImagesResponse" type="object">
  Response object for image generation requests.

  <Expandable title="Properties">
    <ParamField path="created" type="integer" required>
      Unix timestamp when the images were generated
    </ParamField>

    <ParamField path="data" type="array" required>
      List of generated image objects

      <Expandable title="Image Properties">
        <ParamField path="url" type="string">
          URL of the generated image (when `response_format="url"`)
        </ParamField>

        <ParamField path="b64_json" type="string">
          Base64-encoded image data (when `response_format="b64_json"`)
        </ParamField>

        <ParamField path="revised_prompt" type="string">
          The revised prompt used to generate the image (may differ from input for safety)
        </ParamField>
      </Expandable>
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "created": 1677652288,
  "data": [
    {
      "url": "https://images.example.com/abc123.png",
      "revised_prompt": "A cute baby sea otter floating on its back in calm blue water"
    }
  ]
}
```

***

## Audio

<ResponseField name="TranscriptionResponse" type="object">
  Response object for audio transcription requests.

  <Expandable title="Properties">
    <ParamField path="text" type="string" required>
      The transcribed text from the audio file
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "text": "Hello, this is a test of audio transcription."
}
```

***

<ResponseField name="TranslationResponse" type="object">
  Response object for audio translation requests (always translates to English).

  <Expandable title="Properties">
    <ParamField path="text" type="string" required>
      The translated text from the audio file (in English)
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "text": "Hello, this is a test of audio translation."
}
```

***

## Errors

<ResponseField name="ErrorResponse" type="object">
  All endpoints may return errors with this structure.

  <Expandable title="Properties">
    <ParamField path="error" type="object" required>
      Error information object

      <Expandable title="Error Properties">
        <ParamField path="message" type="string">
          Human-readable error message
        </ParamField>

        <ParamField path="type" type="string">
          Error type: `invalid_request_error`, `authentication_error`, `rate_limit_error`, `server_error`
        </ParamField>

        <ParamField path="code" type="string">
          Specific error code for programmatic handling
        </ParamField>

        <ParamField path="param" type="string">
          Parameter that caused the error (if applicable)
        </ParamField>
      </Expandable>
    </ParamField>
  </Expandable>
</ResponseField>

```json Example theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "error": {
    "message": "Invalid API key provided",
    "type": "authentication_error",
    "code": "invalid_api_key"
  }
}
```


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt