# FAQ

> Frequently Asked Questions

<AccordionGroup>
  <Accordion icon="question" title="Why use Dedalus?" defaultOpen>
    * We make it easy to build complex AI agents with just 5 (or so) lines of code.
    * Agents built with our SDK can connect to any MCP server on our marketplace, switch between any model provider, and even execute locally-defined tools.
    * Don’t yet see an MCP you want to use on our marketplace? Upload any MCP server and we’ll host it for free.
  </Accordion>

  <Accordion icon="key" title="How do I get an API key?" defaultOpen>
    Log into your [dashboard](https://dedaluslabs.ai) and navigate to the "API Keys" section.
  </Accordion>

  <Accordion icon="key" title="Can I bring my own API key?" defaultOpen>
    Yes! However, you don't need to. With a `DEDALUS_API_KEY` in your environment, we take care of routing to any provider or model for you, including handoffs between models from different providers. For an example, see our [handoffs](/sdk/handoffs) page.
  </Accordion>

  <Accordion icon="code" title="What languages do you support?" defaultOpen>
    Our SDK is currently available for Python and TypeScript (beta), with plans for Go in the near future. We accept MCP servers written in Python and TypeScript. For best practices in writing MCP servers see our [server guidelines](/sdk/guides/server-guidelines).
  </Accordion>

  <Accordion icon="lock" title="Is authentication supported?" defaultOpen>
    Not yet, but it's coming soon! Until authentication is supported, please ensure your servers are stateless and do not require auth.
  </Accordion>

  <Accordion icon="envelope" title="How do I send feedback?" defaultOpen>
    Send us an email at [support@dedaluslabs.ai](mailto:support@dedaluslabs.ai) or send a message in our [Discord](https://discord.gg/K3SjuFXZJw).
  </Accordion>
</AccordionGroup>

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt