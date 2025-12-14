# Model Providers

> Mix and match models from supported providers.

<Note>
  We now support Claude Opus 4.5 (`anthropic/claude-opus-4-5`) - Anthropic's most powerful model in the 4.5 series!
</Note>

<CardGroup cols={3}>
  <Card title="OpenAI" icon="robot">
    `OPENAI_API_KEY`
  </Card>

  <Card title="Anthropic" icon="brain">
    `ANTHROPIC_API_KEY`
  </Card>

  <Card title="Google Gemini" icon="google">
    `GOOGLE_API_KEY`
  </Card>

  <Card title="Fireworks AI" icon="fire">
    `FIREWORKS_API_KEY`
  </Card>

  <Card title="xAI" icon="x">
    `XAI_API_KEY`
  </Card>

  <Card title="Perplexity" icon="circle-question">
    `PERPLEXITY_API_KEY`
  </Card>

  <Card title="DeepSeek" icon="magnifying-glass">
    `DEEPSEEK_API_KEY`
  </Card>

  <Card title="Groq" icon="bolt">
    `GROQ_API_KEY`
  </Card>

  <Card title="Cohere" icon="comments">
    `COHERE_API_KEY`
  </Card>

  <Card title="Together AI" icon="users">
    `TOGETHERAPI_KEY`
  </Card>

  <Card title="Cerebras" icon="microchip">
    `CEREBRAS_API_KEY`
  </Card>

  <Card title="Mistral" icon="wind">
    `MISTRAL_API_KEY`
  </Card>
</CardGroup>

## Model Recommendations by Use Case

Choosing the right model depends on your specific requirements. Here's a guide to help you select the best provider and model for your needs:

### Tool Calling & Function Use

**Best for:** Building agents and applications that need to call external tools or functions

* `anthropic/claude-opus-4-5` - Excellent tool calling reliability with structured outputs
* `anthropic/claude-sonnet-4-5-20250929` - Strong tool use with fast performance
* `openai/gpt-5` - Native function calling support with structured responses
* `openai/gpt-4o` - Reliable tool calling for production applications
* `deepseek/deepseek-chat` - Advanced tool use with multi-step reasoning

### Coding & Development

**Best for:** Code generation, debugging, and technical implementations

* `deepseek/deepseek-coder` - Purpose-built for coding tasks
* `openai/gpt-5-codex` - Specialized for code generation and completion
* `anthropic/claude-opus-4-5` - Strong code understanding and generation
* `anthropic/claude-sonnet-4-5-20250929` - Excellent coding with faster responses
* `xai/grok-code-fast-1` - Fast code-focused model

### Reasoning & Complex Problem Solving

**Best for:** Mathematical reasoning, logical analysis, and complex decision-making

* `anthropic/claude-opus-4-5` - Advanced reasoning capabilities
* `openai/o3` - Deep reasoning for complex problems
* `openai/o1` - Strong multi-step reasoning
* `deepseek/deepseek-reasoner` - Specialized reasoning model
* `xai/grok-4-fast-reasoning` - Optimized for reasoning tasks

### Speed & Efficiency

**Best for:** High-throughput applications requiring fast responses

* `anthropic/claude-haiku-4-5-20251001` - Fast performance at lower cost
* `google/gemini-2.5-flash` - Optimized for throughput and low latency
* `openai/gpt-5-mini` - Lightweight, fast model
* `openai/gpt-5-nano` - Ultra-fast for simple tasks
* `xai/grok-4-fast-non-reasoning` - Quick responses without extended reasoning

### Long Context Tasks

**Best for:** Processing large documents, codebases, or extended conversations

* `google/gemini-2.5-pro` - Up to 1M+ token context window
* `google/gemini-2.0-flash` - Large context with fast performance
* `anthropic/claude-opus-4-5` - Extended context for complex analysis
* `anthropic/claude-sonnet-4-5-20250929` - Strong long-context capabilities
* `openai/gpt-4-32k` - Extended 32K context window

### Vision & Multimodal

**Best for:** Image understanding, document analysis, and visual tasks

* `openai/gpt-4o` - Strong vision capabilities with chat
* `anthropic/claude-opus-4-5` - Advanced multimodal understanding
* `anthropic/claude-sonnet-4-5-20250929` - Multimodal with fast performance
* `google/gemini-2.5-pro` - Advanced vision and multimodal processing
* `xai/grok-2-vision-1212` - Multimodal understanding

<Tip>
  Many providers offer multiple model tiers (e.g., mini, standard, pro, opus) that balance cost, speed, and capability. Start with smaller models for testing and scale up based on your performance requirements.
</Tip>

## Supported Models

### OpenAI

#### Chat Models

* `openai/gpt-5.1`
* `openai/gpt-5`
* `openai/gpt-5-mini`
* `openai/gpt-5-nano`
* `openai/gpt-5-chat-latest`
* `openai/gpt-5-codex`
* `openai/gpt-5-pro`
* `openai/gpt-4.1`
* `openai/gpt-4.1-mini`
* `openai/gpt-4.1-nano`
* `openai/gpt-4o`
* `openai/gpt-4o-2024-05-13`
* `openai/gpt-4o-mini`
* `openai/gpt-4o-search-preview`
* `openai/gpt-4o-mini-search-preview`
* `openai/chatgpt-4o-latest`
* `openai/gpt-4-turbo`
* `openai/gpt-4-turbo-2024-04-09`
* `openai/gpt-4`
* `openai/gpt-4-0125-preview`
* `openai/gpt-4-1106-preview`
* `openai/gpt-4-1106-vision-preview`
* `openai/gpt-4-0613`
* `openai/gpt-4-0314`
* `openai/gpt-4-32k`
* `openai/gpt-3.5-turbo`
* `openai/gpt-3.5-turbo-0125`
* `openai/gpt-3.5-turbo-1106`
* `openai/gpt-3.5-turbo-0613`
* `openai/gpt-3.5-0301`
* `openai/gpt-3.5-turbo-instruct`
* `openai/gpt-3.5-turbo-16k-0613`

#### Reasoning Models

* `openai/o1`
* `openai/o1-pro`
* `openai/o1-mini`
* `openai/o1-preview`
* `openai/o3`
* `openai/o3-pro`
* `openai/o3-mini`
* `openai/o3-deep-research`
* `openai/o4-mini`
* `openai/o4-mini-deep-research`

#### Image Generation

* `openai/dall-e-3`

#### Audio Transcription

* `openai/whisper-1`

### Anthropic (Claude)

#### Claude 4.5 Series

* `anthropic/claude-opus-4-5`
* `anthropic/claude-haiku-4-5-20251001`
* `anthropic/claude-sonnet-4-5-20250929`

#### Claude 4 Series

* `anthropic/claude-opus-4-1-20250805`
* `anthropic/claude-opus-4-20250514`
* `anthropic/claude-sonnet-4-20250514`

#### Claude 3.7 Series

* `anthropic/claude-3-7-sonnet-20250219`

#### Claude 3.5 Series

* `anthropic/claude-3-5-sonnet-20241022`
* `anthropic/claude-3-5-haiku-20241022`

#### Claude 3 Series

* `anthropic/claude-3-opus-20240229`
* `anthropic/claude-3-sonnet-20240229`
* `anthropic/claude-3-haiku-20240307`

### Google (Gemini)

#### Gemini 3 Series

* `google/gemini-3-pro-preview`

#### Gemini 2.5 Series

* `google/gemini-2.5-pro`
* `google/gemini-2.5-flash`
* `google/gemini-2.5-flash-lite`

#### Gemini 2.0 Series

* `google/gemini-2.0-flash`
* `google/gemini-2.0-flash-exp`
* `google/gemini-2.0-flash-001`
* `google/gemini-2.0-flash-lite`

#### Gemini 1.5 Series

* `google/gemini-1.5-pro`
* `google/gemini-1.5-flash`

### xAI (Grok)

#### Grok 4 Series

* `xai/grok-4-fast-reasoning`
* `xai/grok-4-fast-non-reasoning`
* `xai/grok-code-fast-1`
* `xai/grok-4-0709`

#### Grok 3 Series

* `xai/grok-3`
* `xai/grok-3-mini`

#### Grok 2 Series

* `xai/grok-2`
* `xai/grok-2-1212`
* `xai/grok-2-vision-1212`

#### Legacy

* `xai/grok-beta`

### DeepSeek

* `deepseek/deepseek-chat`
* `deepseek/deepseek-reasoner`
* `deepseek/deepseek-coder`

### Mistral

* `mistral/mistral-large-latest`
* `mistral/mistral-medium-latest`
* `mistral/mistral-small-latest`
* `mistral/codestral-2508`
* `mistral/open-mistral-nemo-2407`
* `mistral/pixtral-12b`

### Fireworks AI

#### Meta Llama Models

* `fireworks_ai/accounts/fireworks/models/llama-v3p1-8b-instruct`


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt