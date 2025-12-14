# Images & Vision

> Generate, edit, and analyze images

Generate images with DALL-E, create variations, apply edits, and analyze images with vision models. All through the same unified client.

<Tip>
  For image generation, use `openai/dall-e-3` for best quality. For vision tasks, `openai/gpt-4o-mini` provides excellent performance at lower cost.
</Tip>

## Image Generation

Generate images from text prompts using DALL-E models.

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv

  load_dotenv()

  async def generate_image():
      """Generate image from text."""
      client = AsyncDedalus()
      response = await client.images.generate(
          prompt="Dedalus flying through clouds",
          model="openai/dall-e-3",
      )
      print(response.data[0].url)

  if __name__ == "__main__":
      asyncio.run(generate_image())

  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import * as dotenv from 'dotenv';

  dotenv.config();

  async function generateImage() {
    const client = new Dedalus();
    const response = await client.images.generate({
      prompt: 'Dedalus flying through clouds',
      model: 'openai/dall-e-3',
    });
    console.log(response.data[0].url);
  }

  generateImage();
  ```
</CodeGroup>

## Image Editing

Edit existing images by providing a source image, mask, and prompt describing desired changes.

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  import httpx
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv

  load_dotenv()

  async def edit_image():
      """Edit image (using generated image as both source and mask)."""

      client = AsyncDedalus()

      # Generate a test image (DALL·E output is valid RGBA PNG)
      gen_response = await client.images.generate(
          prompt="A white cat on a cushion",
          model="openai/dall-e-2",
          size="512x512",
      )

      # Download generated image
      async with httpx.AsyncClient() as http:
          img_data = await http.get(gen_response.data[0].url)
          img_bytes = img_data.content

      # Use same image as both source and mask (just testing endpoint works)
      response = await client.images.edit(
          image=img_bytes,
          mask=img_bytes,
          prompt="A white cat with sunglasses",
          model="openai/dall-e-2",
      )
      print(response.data[0].url)

  if __name__ == "__main__":
      asyncio.run(edit_image())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus, { toFile } from 'dedalus-labs';
  import * as dotenv from 'dotenv';

  dotenv.config();

  async function editImage() {
    const client = new Dedalus();

    // Generate a test image (DALL·E output is valid RGBA PNG)
    const genResponse = await client.images.generate({
      prompt: 'A white cat on a cushion',
      model: 'openai/dall-e-2',
      size: '512x512',
    });

    // Download generated image
    const imageUrl = genResponse.data[0].url;
    if (!imageUrl) throw new Error('No image URL returned');
    const imageResponse = await fetch(imageUrl);
    const imgBytes = Buffer.from(await imageResponse.arrayBuffer());

    // Use same image as both source and mask (just testing endpoint works)
    const response = await client.images.edit({
      image: await toFile(imgBytes, 'source.png'),
      mask: await toFile(imgBytes, 'mask.png'),
      prompt: 'A white cat with sunglasses',
      model: 'openai/dall-e-2',
    });
    console.log(response.data[0].url);
  }

  editImage();
  ```
</CodeGroup>

## Image Variations

Create variations of an existing image.

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from pathlib import Path
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv

  load_dotenv()

  async def create_variations():
      """Create image variations."""
      client = AsyncDedalus()

      image_path = Path("image.png")
      if not image_path.exists():
          print("Skipped: image.png not found")
          return

      response = await client.images.create_variation(
          image=image_path.read_bytes(),
          model="openai/dall-e-2",
          n=2,
      )
      for img in response.data:
          print(img.url)

  if __name__ == "__main__":
      asyncio.run(create_variations())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus, { toFile } from 'dedalus-labs';
  import * as fs from 'fs';
  import * as path from 'path';
  import * as dotenv from 'dotenv';

  dotenv.config();

  async function createVariations() {
    const client = new Dedalus();

    const imagePath = path.join(process.cwd(), 'image.png');
    if (!fs.existsSync(imagePath)) {
      console.log('Skipped: image.png not found');
      return;
    }

    const response = await client.images.createVariation({
      image: await toFile(fs.readFileSync(imagePath), 'image.png'),
      model: 'openai/dall-e-2',
      n: 2,
    });
    for (const img of response.data) {
      console.log(img.url);
    }
  }

  createVariations();
  ```
</CodeGroup>

## Vision: Analyze Images from URL

Use vision models to analyze and describe images from URLs.

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv

  load_dotenv()

  async def vision_url():
      """Analyze image from URL."""
      client = AsyncDedalus()
      completion = await client.chat.completions.create(
          model="openai/gpt-4o-mini",
          messages=[
              {
                  "role": "user",
                  "content": [
                      {"type": "text", "text": "What's in this image?"},
                      {
                          "type": "image_url",
                          "image_url": {"url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"},
                      },
                  ],
              }
          ],
      )
      print(completion.choices[0].message.content)

  if __name__ == "__main__":
      asyncio.run(vision_url())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import * as dotenv from 'dotenv';

  dotenv.config();

  async function visionUrl() {
    const client = new Dedalus();
    const completion = await client.chat.completions.create({
      model: 'openai/gpt-4o-mini',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: "What's in this image?" },
            {
              type: 'image_url',
              image_url: {
                url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
              },
            },
          ],
        },
      ],
    });
    console.log(completion.choices[0].message.content);
  }

  visionUrl();
  ```
</CodeGroup>

## Vision: Analyze Local Images with Base64

Analyze local images by encoding them as base64.

<CodeGroup>
  ```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import asyncio
  import base64
  from pathlib import Path
  from dedalus_labs import AsyncDedalus
  from dotenv import load_dotenv

  load_dotenv()

  async def vision_base64():
      """Analyze local image via base64."""
      client = AsyncDedalus()

      image_path = Path("image.png")
      if not image_path.exists():
          print("Skipped: image.png not found")
          return

      b64 = base64.b64encode(image_path.read_bytes()).decode()
      completion = await client.chat.completions.create(
          model="openai/gpt-4o-mini",
          messages=[
              {
                  "role": "user",
                  "content": [
                      {"type": "text", "text": "Describe this image."},
                      {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}},
                  ],
              }
          ],
      )
      print(completion.choices[0].message.content)

  if __name__ == "__main__":
      asyncio.run(vision_base64())
  ```

  ```typescript TypeScript theme={"theme":{"light":"github-light","dark":"github-dark"}}
  import Dedalus from 'dedalus-labs';
  import * as fs from 'fs';
  import * as path from 'path';
  import * as dotenv from 'dotenv';

  dotenv.config();

  async function visionBase64() {
    const client = new Dedalus();

    const imagePath = path.join(process.cwd(), 'image.png');
    if (!fs.existsSync(imagePath)) {
      console.log('Skipped: image.png not found');
      return;
    }

    const b64 = fs.readFileSync(imagePath).toString('base64');
    const completion = await client.chat.completions.create({
      model: 'openai/gpt-4o-mini',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: 'Describe this image.' },
            { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${b64}` } },
          ],
        },
      ],
    });
    console.log(completion.choices[0].message.content);
  }

  visionBase64();
  ```
</CodeGroup>

## Advanced: Image Orchestration with DedalusRunner

Create complex image workflows by combining generation, editing, and vision capabilities using DedalusRunner.

```python Python theme={"theme":{"light":"github-light","dark":"github-dark"}}
import asyncio
import httpx
from dedalus_labs import AsyncDedalus, DedalusRunner
from dotenv import load_dotenv

load_dotenv()

class ImageToolSuite:
    """Helper that exposes image endpoints as DedalusRunner tools."""

    def __init__(self, client: AsyncDedalus):
        self._client = client

    async def generate_concept_art(
        self,
        prompt: str,
        model: str = "openai/dall-e-3",
        size: str = "1024x1024",
    ) -> str:
        """Create concept art and return the hosted image URL."""
        response = await self._client.images.generate(
            prompt=prompt,
            model=model,
            size=size,
        )
        return response.data[0].url

    async def edit_concept_art(
        self,
        prompt: str,
        reference_url: str,
        mask_url: str | None = None,
        model: str = "openai/dall-e-2",
    ) -> str:
        """Apply edits to the referenced image URL and return a new URL."""

        if not reference_url:
            raise ValueError("reference_url must be provided when editing an image.")

        async with httpx.AsyncClient() as http:
            base_image = await http.get(reference_url)
            mask_bytes = await http.get(mask_url) if mask_url else None

        edit_kwargs = {
            "image": base_image.content,
            "prompt": prompt,
            "model": model,
        }
        if mask_bytes:
            edit_kwargs["mask"] = mask_bytes.content

        response = await self._client.images.edit(**edit_kwargs)
        return response.data[0].url

    async def describe_image(
        self,
        image_url: str,
        question: str = "Describe this image.",
        model: str = "openai/gpt-4o-mini",
    ) -> str:
        """Run a lightweight vision pass against an existing image URL."""
        completion = await self._client.chat.completions.create(
            model=model,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": question},
                        {"type": "image_url", "image_url": {"url": image_url}},
                    ],
                }
            ],
        )
        return completion.choices[0].message.content

async def runner_storyboard():
    """Demonstrate DedalusRunner + agent-as-tool pattern for image workflows."""

    client = AsyncDedalus()
    runner = DedalusRunner(client, verbose=True)
    image_tools = ImageToolSuite(client)

    instructions = (
        "You are a creative director. Use the provided tools to generate concept art, "
        "optionally refine it, and then describe the final render. Always keep the "
        "main conversation on a text model and rely on the tools for image work."
    )

    result = await runner.run(
        instructions=instructions,
        input="Create a retro Dedalus mission patch, refine it with a neon palette, and describe it.",
        model="openai/gpt-4o-mini",
        tools=[
            image_tools.generate_concept_art,
            image_tools.edit_concept_art,
            image_tools.describe_image,
        ],
        max_steps=4,
        verbose=True,
        debug=False,
    )

    print("Runner final output:", result.final_output)
    print("Tools invoked:", result.tools_called)

if __name__ == "__main__":
    asyncio.run(runner_storyboard())
```

## Next Steps

* **[Structured Outputs](/sdk/structured-outputs)** — Combine vision with typed responses
* **[Tools](/sdk/tools)** — Build custom image processing tools
* **[Use Cases](/sdk/use-cases/data-analyst)** — See multimodal workflows

<Tip icon="terminal" iconType="regular">
  [Connect these docs programmatically](/contextual/use-these-docs) to Claude, VSCode, and more via MCP for real-time answers.
</Tip>


---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt