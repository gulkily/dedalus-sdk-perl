# Create Image

> Generate images from text prompts.

Pure image generation models only (DALL-E, GPT Image).
For multimodal models like gemini-2.5-flash-image, use /v1/chat/completions.

## OpenAPI

````yaml openapi.json post /v1/images/generations
openapi: 3.1.0
info:
  title: Dedalus API
  description: >-
    MCP gateway for AI agents. Mix-and-match any model with any tool from our
    marketplace.


    ## Authentication

    Use Bearer token or X-API-Key header authentication:

    ```

    Authorization: Bearer your-api-key-here

    ```

    ```

    x-api-key: your-api-key-here

    ```


    ## Available Endpoints

    - **GET /v1/models**: list available models

    - **POST /v1/chat/completions**: Chat completions with MCP tools

    - **GET /health**: Service health check
  version: 0.1.0a10
servers:
  - url: https://api.dedaluslabs.ai
    description: Production server
security: []
paths:
  /v1/images/generations:
    post:
      tags:
        - v1
        - images
      summary: Create Image
      description: >-
        Generate images from text prompts.


        Pure image generation models only (DALL-E, GPT Image).

        For multimodal models like gemini-2.5-flash-image, use
        /v1/chat/completions.
      operationId: create_image_v1_images_generations_post
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ImageGenerateRequest'
        required: true
      responses:
        '200':
          description: Successful Response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ImagesResponse'
        '422':
          description: Validation Error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/HTTPValidationError'
      security:
        - Bearer: []
components:
  schemas:
    ImageGenerateRequest:
      properties:
        prompt:
          type: string
          title: Prompt
          description: >-
            A text description of the desired image(s). The maximum length is
            32000 characters for `gpt-image-1`, 1000 characters for `dall-e-2`
            and 4000 characters for `dall-e-3`.
          examples:
            - A white siamese cat
        model:
          anyOf:
            - type: string
            - type: 'null'
          title: Model
          description: >-
            The model to use for image generation. One of `openai/dall-e-2`,
            `openai/dall-e-3`, or `openai/gpt-image-1`. Defaults to
            `openai/dall-e-2` unless a parameter specific to `gpt-image-1` is
            used.
          examples:
            - openai/dall-e-3
            - openai/dall-e-2
            - openai/gpt-image-1
        'n':
          anyOf:
            - type: integer
              maximum: 10
              minimum: 1
            - type: 'null'
          title: 'N'
          description: >-
            The number of images to generate. Must be between 1 and 10. For
            `dall-e-3`, only `n=1` is supported.
          examples:
            - 1
            - 4
        quality:
          anyOf:
            - type: string
              enum:
                - auto
                - high
                - medium
                - low
                - hd
                - standard
            - type: 'null'
          title: Quality
          description: >-
            The quality of the image that will be generated.


            - `auto` (default value) will automatically select the best quality
            for the given model.

            - `high`, `medium` and `low` are supported for `gpt-image-1`.

            - `hd` and `standard` are supported for `dall-e-3`.

            - `standard` is the only option for `dall-e-2`.
          examples:
            - standard
            - hd
            - high
        response_format:
          anyOf:
            - type: string
              enum:
                - url
                - b64_json
            - type: 'null'
          title: Response Format
          description: >-
            The format in which generated images with `dall-e-2` and `dall-e-3`
            are returned. Must be one of `url` or `b64_json`. URLs are only
            valid for 60 minutes after the image has been generated. This
            parameter isn't supported for `gpt-image-1` which will always return
            base64-encoded images.
          examples:
            - url
            - b64_json
        output_format:
          anyOf:
            - type: string
              enum:
                - png
                - jpeg
                - webp
            - type: 'null'
          title: Output Format
          description: >-
            The format in which the generated images are returned. This
            parameter is only supported for `gpt-image-1`. Must be one of `png`,
            `jpeg`, or `webp`.
          examples:
            - png
            - webp
        output_compression:
          anyOf:
            - type: integer
              maximum: 100
              minimum: 0
            - type: 'null'
          title: Output Compression
          description: >-
            The compression level (0-100%) for the generated images. This
            parameter is only supported for `gpt-image-1` with the `webp` or
            `jpeg` output formats, and defaults to 100.
          examples:
            - 85
            - 100
        stream:
          anyOf:
            - type: boolean
            - type: 'null'
          title: Stream
          description: >-
            Generate the image in streaming mode. Defaults to `false`. See the

            [Image generation
            guide](https://platform.openai.com/docs/guides/image-generation) for
            more information.

            This parameter is only supported for `gpt-image-1`.
          examples:
            - true
            - false
        partial_images:
          anyOf:
            - type: integer
              maximum: 3
              minimum: 0
            - type: 'null'
          title: Partial Images
          description: >-
            The number of partial images to generate. This parameter is used for

            streaming responses that return partial images. Value must be
            between 0 and 3.

            When set to 0, the response will be a single image sent in one
            streaming event.


            Note that the final image may be sent before the full number of
            partial images

            are generated if the full image is generated more quickly.
          examples:
            - 0
            - 2
        size:
          anyOf:
            - type: string
              enum:
                - 256x256
                - 512x512
                - 1024x1024
                - 1536x1024
                - 1024x1536
                - 1792x1024
                - 1024x1792
                - auto
            - type: 'null'
          title: Size
          description: >-
            The size of the generated images. Must be one of `1024x1024`,
            `1536x1024` (landscape), `1024x1536` (portrait), or `auto` (default
            value) for `gpt-image-1`, one of `256x256`, `512x512`, or
            `1024x1024` for `dall-e-2`, and one of `1024x1024`, `1792x1024`, or
            `1024x1792` for `dall-e-3`.
          examples:
            - 1024x1024
            - 1792x1024
            - auto
        moderation:
          anyOf:
            - type: string
              enum:
                - low
                - auto
            - type: 'null'
          title: Moderation
          description: >-
            Control the content-moderation level for images generated by
            `gpt-image-1`. Must be either `low` for less restrictive filtering
            or `auto` (default value).
          examples:
            - auto
            - low
        background:
          anyOf:
            - type: string
              enum:
                - transparent
                - opaque
                - auto
            - type: 'null'
          title: Background
          description: >-
            Allows to set transparency for the background of the generated
            image(s).

            This parameter is only supported for `gpt-image-1`. Must be one of

            `transparent`, `opaque` or `auto` (default value). When `auto` is
            used, the

            model will automatically determine the best background for the
            image.


            If `transparent`, the output format needs to support transparency,
            so it

            should be set to either `png` (default value) or `webp`.
          examples:
            - transparent
            - opaque
            - auto
        style:
          anyOf:
            - type: string
              enum:
                - vivid
                - natural
            - type: 'null'
          title: Style
          description: >-
            The style of the generated images. This parameter is only supported
            for `dall-e-3`. Must be one of `vivid` or `natural`. Vivid causes
            the model to lean towards generating hyper-real and dramatic images.
            Natural causes the model to produce more natural, less hyper-real
            looking images.
          examples:
            - vivid
            - natural
        user:
          anyOf:
            - type: string
            - type: 'null'
          title: User
          description: >-
            A unique identifier representing your end-user, which can help
            OpenAI to monitor and detect abuse. [Learn
            more](https://platform.openai.com/docs/guides/safety-best-practices#end-user-ids).
      type: object
      required:
        - prompt
      title: ImageGenerateRequest
      description: Request to generate images.
    ImagesResponse:
      properties:
        created:
          type: integer
          title: Created
          description: Unix timestamp when images were created
        data:
          items:
            $ref: '#/components/schemas/Image'
          type: array
          title: Data
          description: List of generated images
      type: object
      required:
        - created
        - data
      title: ImagesResponse
      description: Response from image generation.
    HTTPValidationError:
      properties:
        detail:
          items:
            $ref: '#/components/schemas/ValidationError'
          type: array
          title: Detail
      type: object
      title: HTTPValidationError
    Image:
      properties:
        url:
          anyOf:
            - type: string
            - type: 'null'
          title: Url
          description: URL of the generated image (if response_format=url)
        b64_json:
          anyOf:
            - type: string
            - type: 'null'
          title: B64 Json
          description: Base64-encoded image data (if response_format=b64_json)
        revised_prompt:
          anyOf:
            - type: string
            - type: 'null'
          title: Revised Prompt
          description: Revised prompt used for generation (dall-e-3)
      type: object
      title: Image
      description: Single image object.
    ValidationError:
      properties:
        loc:
          items:
            anyOf:
              - type: string
              - type: integer
          type: array
          title: Location
        msg:
          type: string
          title: Message
        type:
          type: string
          title: Error Type
      type: object
      required:
        - loc
        - msg
        - type
      title: ValidationError
  securitySchemes:
    Bearer:
      type: http
      description: API key authentication using Bearer token
      scheme: bearer

````

---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt