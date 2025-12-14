# Session Management

> Persist multi-turn conversations using JSON

Build conversational agents that remember context across messages. This pattern persists conversation history to JSON, enabling chatbots, assistants, and any multi-turn interaction.

## How It Works

The SDK's `runner.run()` accepts a `messages` array instead of a single `input` string. By loading history before each call and saving after, you get persistent conversations:

1. **Load** the conversation history from storage
2. **Append** the new user message
3. **Run** the model with the full history
4. **Save** the updated history using `result.to_input_list()`

## Key Concepts

### Message Format

The SDK uses the OpenAI message format:

```python  theme={"theme":{"light":"github-light","dark":"github-dark"}}
[
    {"role": "user", "content": "Hello"},
    {"role": "assistant", "content": "Hi! How can I help?"},
    {"role": "user", "content": "What did I just say?"},
]
```

### Persistence with `to_input_list()`

After each `runner.run()`, call `result.to_input_list()` to get the complete conversation history including tool calls and assistant responses. This preserves the full context for the next turn.

### Session Isolation

Each session ID maps to a separate conversation. Users can switch between sessions without losing context.

## Complete Example

An interactive CLI demonstrating session management with model switching and MCP server support:

```python  theme={"theme":{"light":"github-light","dark":"github-dark"}}
import asyncio
import json
from pathlib import Path

from dotenv import load_dotenv
from dedalus_labs import AsyncDedalus, DedalusRunner

load_dotenv()

SESSIONS_FILE = Path(__file__).parent / "sessions.json"

MODELS = [
    "openai/gpt-5.1",
    "anthropic/claude-opus-4-5-20251101",
    "google/gemini-3-pro-preview",
]


def load_sessions() -> dict:
    if SESSIONS_FILE.exists():
        return json.loads(SESSIONS_FILE.read_text())
    return {}


def save_sessions(sessions: dict):
    SESSIONS_FILE.write_text(json.dumps(sessions, indent=2))


def get_session(session_id: str) -> list[dict]:
    sessions = load_sessions()
    return sessions.get(session_id, [])


def save_session(session_id: str, messages: list[dict]):
    sessions = load_sessions()
    sessions[session_id] = messages
    save_sessions(sessions)


async def chat(
    session_id: str,
    user_input: str,
    model: str,
    mcp_servers: list[str] | None = None,
) -> str:
    client = AsyncDedalus()
    runner = DedalusRunner(client)

    history = get_session(session_id)

    # Append user message to history (runner ignores `input` when `messages` is passed)
    history.append({"role": "user", "content": user_input})

    kwargs = {
        "messages": history,
        "model": model,
    }
    if mcp_servers:
        kwargs["mcp_servers"] = mcp_servers

    result = await runner.run(**kwargs)
    save_session(session_id, result.to_input_list())

    return result.final_output


async def demo():
    print("=" * 60)
    print("  Dedalus Session Management Demo")
    print("=" * 60)
    print("\nCommands:")
    print("  /new <name>   - Start new session")
    print("  /list         - List sessions")
    print("  /load <name>  - Load session")
    print("  /clear        - Clear current session")
    print("  /model        - List available models")
    print("  /model <num>  - Switch model")
    print("  /mcp <url>    - Add MCP server")
    print("  /mcp clear    - Clear MCP servers")
    print("  /mcp          - List active MCP servers")
    print("  /status       - Show current config")
    print("  /quit         - Exit")
    print()

    current_session = "default"
    current_model = MODELS[0]
    mcp_servers: list[str] = []

    print(f"Session: {current_session}")
    print(f"Model: {current_model}")
    print()

    while True:
        try:
            user_input = input(f"[{current_session}] You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break

        if not user_input:
            continue

        if user_input.startswith("/"):
            parts = user_input.split(maxsplit=1)
            cmd = parts[0].lower()
            arg = parts[1].strip() if len(parts) > 1 else ""

            if cmd == "/quit":
                print("Goodbye!")
                break

            elif cmd == "/new":
                current_session = arg or "default"
                save_session(current_session, [])
                print(f"Started new session: {current_session}")

            elif cmd == "/list":
                sessions = load_sessions()
                print(f"Sessions: {list(sessions.keys()) or ['(none)']}")

            elif cmd == "/load":
                current_session = arg or "default"
                history = get_session(current_session)
                print(f"Loaded session: {current_session} ({len(history)} messages)")

            elif cmd == "/clear":
                save_session(current_session, [])
                print(f"Cleared session: {current_session}")

            elif cmd == "/model":
                if not arg:
                    print("Available models:")
                    for i, m in enumerate(MODELS, 1):
                        marker = "*" if m == current_model else " "
                        print(f"  {marker} {i}. {m}")
                elif arg.isdigit() and 1 <= int(arg) <= len(MODELS):
                    current_model = MODELS[int(arg) - 1]
                    print(f"Switched to: {current_model}")
                else:
                    current_model = arg
                    print(f"Switched to: {current_model}")

            elif cmd == "/mcp":
                if not arg:
                    print(f"Active MCP servers: {mcp_servers or 'None'}")
                elif arg == "clear":
                    mcp_servers = []
                    print("Cleared MCP servers")
                else:
                    mcp_servers.append(arg)
                    print(f"Added MCP server: {arg}")

            elif cmd == "/status":
                print(f"Session: {current_session}")
                print(f"Model: {current_model}")
                print(f"MCP Servers: {mcp_servers or 'None'}")
                history = get_session(current_session)
                print(f"Messages: {len(history)}")

            else:
                print(f"Unknown command: {cmd}")

            continue

        print("Assistant: ", end="", flush=True)
        response = await chat(
            current_session,
            user_input,
            model=current_model,
            mcp_servers=mcp_servers if mcp_servers else None,
        )
        print(response)
        print()


if __name__ == "__main__":
    asyncio.run(demo())
```

## Storage Options

The JSON file approach works for prototyping. For production:

| Storage    | Use Case                       |
| ---------- | ------------------------------ |
| JSON file  | Local development, single user |
| SQLite     | Local apps, moderate scale     |
| Redis      | High-performance, distributed  |
| PostgreSQL | Production, with JSONB columns |

## Why This Works

The SDK handles the complexity of tool calls, model responses, and message formatting. Your job is just storing and loading the message array. The pattern scales from CLI tools to production chatbots.

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt