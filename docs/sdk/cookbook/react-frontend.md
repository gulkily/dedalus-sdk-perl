# useChat React Hook

> Use the dedalus-react hook with a Python backend for streaming and client-side tool execution

Use the [`dedalus-react`](https://www.npmjs.com/package/dedalus-react) `useChat` hook with a Python backend. This pattern enables real-time streaming, client-side tool execution, and model selection.

<Note>
  The `dedalus-react` package was created by [Colby Gilbert](https://www.npmjs.com/~colbygilbert95). See the [npm package](https://www.npmjs.com/package/dedalus-react) for full documentation.
</Note>

## Architecture

```
┌─────────────────────┐     SSE Stream      ┌─────────────────────┐
│   Python Backend    │ ──────────────────> │   React Frontend    │
│   (FastAPI)         │                     │   (dedalus-react)   │
│                     │                     │                     │
│   DedalusRunner     │     POST + JSON     │   useChat hook      │
│   .run(stream=True) │ <────────────────── │   sendMessage()     │
└─────────────────────┘                     └─────────────────────┘
```

The Python SDK streams OpenAI-compatible chunks. The React hook consumes them via Server-Sent Events (SSE).

## Setup

### Install Dependencies

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
# Backend
pip install fastapi uvicorn dedalus-labs python-dotenv

# Frontend
pnpm add dedalus-react dedalus-labs react
```

## Python Backend (FastAPI)

Create a streaming endpoint that wraps `DedalusRunner` output as SSE:

```python  theme={"theme":{"light":"github-light","dark":"github-dark"}}
# server.py
import json
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from dedalus_labs import AsyncDedalus
from dedalus_labs.lib.runner import DedalusRunner

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["POST"],
    allow_headers=["*"],
)

client = AsyncDedalus()
runner = DedalusRunner(client)


@app.post("/api/chat")
async def chat(request: Request):
    body = await request.json()
    messages = body.get("messages", [])
    model = body.get("model", "openai/gpt-4o-mini")

    stream = runner.run(
        messages=messages,
        model=model,
        stream=True,
    )

    async def generate():
        async for chunk in stream:
            yield f"data: {chunk.model_dump_json()}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        },
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## React Frontend

Use the `useChat` hook to manage messages and streaming:

```tsx  theme={"theme":{"light":"github-light","dark":"github-dark"}}
// App.tsx
import { useChat } from "dedalus-react";
import { useState } from "react";

function Chat() {
  const [input, setInput] = useState("");

  const { messages, sendMessage, status, stop } = useChat({
    transport: { api: "http://localhost:8000/api/chat" },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    sendMessage(input);
    setInput("");
  };

  return (
    <div>
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i} className={`message ${msg.role}`}>
            <strong>{msg.role}:</strong> {msg.content}
          </div>
        ))}
      </div>

      <form onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Type a message..."
          disabled={status === "streaming"}
        />
        <button type="submit" disabled={status === "streaming"}>
          Send
        </button>
        {status === "streaming" && (
          <button type="button" onClick={stop}>
            Stop
          </button>
        )}
      </form>
    </div>
  );
}

export default Chat;
```

## Client-Side Tool Execution

The `useChat` hook supports executing tools on the client via `onToolCall` and `addToolResult`:

```tsx  theme={"theme":{"light":"github-light","dark":"github-dark"}}
import { useChat } from "dedalus-react";

function ChatWithTools() {
  const { messages, sendMessage, addToolResult } = useChat({
    transport: { api: "/api/chat" },

    // Called when model requests a tool
    onToolCall: async ({ toolCall }) => {
      if (toolCall.function.name === "get_user_location") {
        // Execute client-side (e.g., browser geolocation)
        const position = await new Promise<GeolocationPosition>((resolve) =>
          navigator.geolocation.getCurrentPosition(resolve)
        );

        addToolResult({
          toolCallId: toolCall.id,
          result: {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          },
        });
      }
    },

    // Auto-continue after tool results
    sendAutomaticallyWhen: ({ messages }) => {
      const last = messages[messages.length - 1];
      return last?.role === "assistant" &&
             last.tool_calls?.length > 0;
    },
  });

  // ... rest of component
}
```

### How It Works

1. **Model requests tool** - Backend streams `tool_calls` in the response
2. **Hook invokes callback** - `onToolCall` fires for each tool call
3. **Client executes** - Your code runs the tool (API call, browser API, user prompt, etc.)
4. **Result sent back** - `addToolResult` adds a `tool` message to history
5. **Auto-continue** - If `sendAutomaticallyWhen` returns true, another request is made with the tool result

The Python backend doesn't need any special handling—it just receives messages including `role: "tool"` entries and continues the conversation.

## Model Selection

Pass additional data via the transport body:

```tsx  theme={"theme":{"light":"github-light","dark":"github-dark"}}
const [model, setModel] = useState("openai/gpt-4o-mini");

const { messages, sendMessage } = useChat({
  transport: {
    api: "/api/chat",
    body: { model },  // Merged into every request
  },
});
```

Update the backend to read it:

```python  theme={"theme":{"light":"github-light","dark":"github-dark"}}
@app.post("/api/chat")
async def chat(request: Request):
    body = await request.json()
    messages = body.get("messages", [])
    model = body.get("model", "openai/gpt-4o-mini")  # Read from body

    stream = runner.run(messages=messages, model=model, stream=True)
    # ...
```

## Running the Example

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
# Terminal 1: Start backend
python server.py

# Terminal 2: Start frontend
cd frontend && pnpm dev
```

## Production Considerations

| Concern        | Solution                                          |
| -------------- | ------------------------------------------------- |
| CORS           | Configure allowed origins for your domain         |
| Authentication | Add JWT/session middleware, pass token in headers |
| Rate limiting  | Implement per-user throttling                     |
| Error handling | Wrap stream in try/catch, surface errors to UI    |

<Tip icon="terminal" iconType="regular">
  See the [dedalus-react examples](https://github.com/dedalus-labs/dedalus-react/tree/main/example) for complete Next.js and Express setups.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt