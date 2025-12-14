# Create Translation

> Translate audio into English.

Translates audio files in any supported language to English text using OpenAI's
Whisper model. Supports the same audio formats as transcription. Maximum file size
is 25 MB.

Args:
    file: Audio file to translate (required)
    model: Model ID to use (e.g., "openai/whisper-1")
    prompt: Optional text to guide the model's style
    response_format: Format of the output (json, text, srt, verbose_json, vtt)
    temperature: Sampling temperature between 0 and 1

Returns:
    Translation object with the English translation

## OpenAPI

````yaml openapi.json post /v1/audio/translations
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
  /v1/audio/translations:
    post:
      tags:
        - v1
        - audio
      summary: Create Translation
      description: >-
        Translate audio into English.


        Translates audio files in any supported language to English text using
        OpenAI's

        Whisper model. Supports the same audio formats as transcription. Maximum
        file size

        is 25 MB.


        Args:
            file: Audio file to translate (required)
            model: Model ID to use (e.g., "openai/whisper-1")
            prompt: Optional text to guide the model's style
            response_format: Format of the output (json, text, srt, verbose_json, vtt)
            temperature: Sampling temperature between 0 and 1

        Returns:
            Translation object with the English translation
      operationId: create_translation_v1_audio_translations_post
      requestBody:
        content:
          multipart/form-data:
            schema:
              $ref: >-
                #/components/schemas/Body_create_translation_v1_audio_translations_post
        required: true
      responses:
        '200':
          description: Successful Response
          content:
            application/json:
              schema:
                anyOf:
                  - $ref: '#/components/schemas/CreateTranslationResponseVerboseJson'
                  - $ref: '#/components/schemas/CreateTranslationResponseJson'
                title: Response Create Translation V1 Audio Translations Post
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
    Body_create_translation_v1_audio_translations_post:
      properties:
        file:
          type: string
          format: binary
          title: File
        model:
          type: string
          title: Model
        prompt:
          anyOf:
            - type: string
            - type: 'null'
          title: Prompt
        response_format:
          anyOf:
            - type: string
            - type: 'null'
          title: Response Format
        temperature:
          anyOf:
            - type: number
            - type: 'null'
          title: Temperature
      type: object
      required:
        - file
        - model
      title: Body_create_translation_v1_audio_translations_post
    CreateTranslationResponseVerboseJson:
      properties:
        language:
          type: string
          title: Language
          description: The language of the output translation (always `english`).
          x-order: 0
        duration:
          type: number
          title: Duration
          description: The duration of the input audio.
          x-order: 1
        text:
          type: string
          title: Text
          description: The translated text.
          x-order: 2
        segments:
          items:
            $ref: '#/components/schemas/TranscriptionSegment'
          type: array
          title: Segments
          description: Segments of the translated text and their corresponding details.
          x-order: 3
      type: object
      required:
        - language
        - duration
        - text
      title: CreateTranslationResponseVerboseJson
      description: |-
        Fields:
        - language (required): str
        - duration (required): float
        - text (required): str
        - segments (optional): list[TranscriptionSegment]
    CreateTranslationResponseJson:
      properties:
        text:
          type: string
          title: Text
          x-order: 0
      type: object
      required:
        - text
      title: CreateTranslationResponseJson
      description: |-
        Fields:
        - text (required): str
    HTTPValidationError:
      properties:
        detail:
          items:
            $ref: '#/components/schemas/ValidationError'
          type: array
          title: Detail
      type: object
      title: HTTPValidationError
    TranscriptionSegment:
      properties:
        id:
          type: integer
          title: Id
          description: Unique identifier of the segment.
          x-order: 0
        seek:
          type: integer
          title: Seek
          description: Seek offset of the segment.
          x-order: 1
        start:
          type: number
          title: Start
          description: Start time of the segment in seconds.
          x-order: 2
        end:
          type: number
          title: End
          description: End time of the segment in seconds.
          x-order: 3
        text:
          type: string
          title: Text
          description: Text content of the segment.
          x-order: 4
        tokens:
          items:
            type: integer
          type: array
          title: Tokens
          description: Array of token IDs for the text content.
          x-order: 5
        temperature:
          type: number
          title: Temperature
          description: Temperature parameter used for generating the segment.
          x-order: 6
        avg_logprob:
          type: number
          title: Avg Logprob
          description: >-
            Average logprob of the segment. If the value is lower than -1,
            consider the logprobs failed.
          x-order: 7
        compression_ratio:
          type: number
          title: Compression Ratio
          description: >-
            Compression ratio of the segment. If the value is greater than 2.4,
            consider the compression failed.
          x-order: 8
        no_speech_prob:
          type: number
          title: No Speech Prob
          description: >-
            Probability of no speech in the segment. If the value is higher than
            1.0 and the `avg_logprob` is below -1, consider this segment silent.
          x-order: 9
      type: object
      required:
        - id
        - seek
        - start
        - end
        - text
        - tokens
        - temperature
        - avg_logprob
        - compression_ratio
        - no_speech_prob
      title: TranscriptionSegment
      description: |-
        Fields:
        - id (required): int
        - seek (required): int
        - start (required): float
        - end (required): float
        - text (required): str
        - tokens (required): list[int]
        - temperature (required): float
        - avg_logprob (required): float
        - compression_ratio (required): float
        - no_speech_prob (required): float
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