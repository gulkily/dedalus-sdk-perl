# Use docs programmatically

> Connect Dedalus documentation to your AI tools and workflows

We want to make our documentation as accessible as possible. We've included several ways for you to use these docs programmatically through AI assistants, code editors, and direct integrations, such as Model Context Protocol (MCP).

## Quick access options

On any page in our documentation, you'll find a contextual menu dropdown in the top right corner with quick access options including our `llms.txt`, MCP server connection, and other integrations such as ChatGPT and Claude.

<Frame>
  <img src="https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=0a087fbf0abe5306d67310802531a146" alt="Quick access menu showing Copy page, View as Markdown, Open in ChatGPT, Open in Claude, and Copy MCP Server options" data-og-width="1710" width="1710" data-og-height="844" height="844" data-path="contextual/quick-access-menu.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?w=280&fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=d67a054fd814859e0f73fd224e79c078 280w, https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?w=560&fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=4bd8cc63ee76f04280d4f8d6e2700b66 560w, https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?w=840&fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=2e04f7a888b0b1f9d611b9d0f6b202d1 840w, https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?w=1100&fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=f8ae638c46fb6688cf4dabfca925487d 1100w, https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?w=1650&fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=1f227cc497939b68fd3fbaf31f61a2e3 1650w, https://mintcdn.com/dedaluslabs/wxLflLy7C39UqrRl/contextual/quick-access-menu.png?w=2500&fit=max&auto=format&n=wxLflLy7C39UqrRl&q=85&s=a00ff0fe6c2baa0a9c1fe2088471656c 2500w" />
</Frame>

## Use our MCP server

Our documentation includes a built-in **Model Context Protocol (MCP) server** that lets AI applications query the latest docs in real-time.

The Dedalus docs MCP server is available at:

```txt  theme={"theme":{"light":"github-light","dark":"github-dark"}}
https://docs.dedaluslabs.ai/mcp
```

Once connected, you can ask your AI assistant questions about Dedalus SDK, MCP servers, and our platform, and it will search our documentation to provide accurate, current answers.

### Connect with Claude Code

If you're using Claude Code, run this command in your terminal to add the server to your current project:

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
claude mcp add --transport http docs-dedalus https://docs.dedaluslabs.ai/mcp
```

<Note>
  **Project (local) scoped**

  The command above adds the MCP server only to your current project/working directory. To add the MCP server globally and access it in all projects, add the user scope by adding `--scope user` to the command:

  ```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
  claude mcp add --transport http docs-dedalus --scope user https://docs.dedaluslabs.ai/mcp
  ```
</Note>

### Connect with Claude Desktop

1. Open Claude Desktop
2. Go to **Settings** → **Developer** → **Connectors**
3. Click **Add MCP Server**
4. Add our MCP server URL: `https://docs.dedaluslabs.ai/mcp`

### Connect with Codex CLI

If you're using OpenAI Codex CLI, run this command in your terminal to add the server globally:

```bash  theme={"theme":{"light":"github-light","dark":"github-dark"}}
codex mcp add dedalus-docs --url https://docs.dedaluslabs.ai/mcp
```

### Connect with Cursor or VS Code

Add the following to your MCP settings configuration file:

```json  theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "mcpServers": {
    "docs-dedalus": {
      "url": "https://docs.dedaluslabs.ai/mcp"
    }
  }
}
```

### Connect with Antigravity

Add the following to your MCP settings configuration file:

```json  theme={"theme":{"light":"github-light","dark":"github-dark"}}
{
  "mcpServers": {
    "docs-dedalus": {
      "serverUrl": "https://docs.dedaluslabs.ai/mcp"
    }
  }
}
```

## Learn more

Have questions or feedback? Join our [Discord community](https://discord.gg/K3SjuFXZJw) or [email us](mailto:support@dedaluslabs.ai).

***


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt