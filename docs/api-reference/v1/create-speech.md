# Create Speech

> Generate speech audio from text.

Generates audio from the input text using text-to-speech models. Supports multiple
voices and output formats including mp3, opus, aac, flac, wav, and pcm.

Returns streaming audio data that can be saved to a file or streamed directly to users.

## OpenAPI

````yaml openapi.json post /v1/audio/speech
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
  /v1/audio/speech:
    post:
      tags:
        - v1
        - audio
      summary: Create Speech
      description: >-
        Generate speech audio from text.


        Generates audio from the input text using text-to-speech models.
        Supports multiple

        voices and output formats including mp3, opus, aac, flac, wav, and pcm.


        Returns streaming audio data that can be saved to a file or streamed
        directly to users.
      operationId: create_speech_v1_audio_speech_post
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateSpeechRequest'
        required: true
      responses:
        '200':
          description: Audio file stream
          content:
            audio/mpeg:
              schema:
                type: string
                format: binary
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
    CreateSpeechRequest:
      properties:
        model:
          type: string
          title: Model
          description: >-
            One of the available [TTS
            models](https://platform.openai.com/docs/models#tts):
            `openai/tts-1`, `openai/tts-1-hd` or `openai/gpt-4o-mini-tts`.
          examples:
            - openai/tts-1
            - openai/tts-1-hd
        input:
          type: string
          title: Input
          description: >-
            The text to generate audio for. The maximum length is 4096
            characters.
          examples:
            - Hello, how are you today?
        voice:
          type: string
          enum:
            - alloy
            - ash
            - ballad
            - coral
            - echo
            - fable
            - onyx
            - nova
            - sage
            - shimmer
            - verse
          title: Voice
          description: >-
            The voice to use when generating the audio. Supported voices are
            `alloy`, `ash`, `ballad`, `coral`, `echo`, `fable`, `onyx`, `nova`,
            `sage`, `shimmer`, and `verse`. Previews of the voices are available
            in the [Text to speech
            guide](https://platform.openai.com/docs/guides/text-to-speech#voice-options).
          examples:
            - alloy
            - nova
        instructions:
          anyOf:
            - type: string
            - type: 'null'
          title: Instructions
          description: >-
            Control the voice of your generated audio with additional
            instructions. Does not work with `tts-1` or `tts-1-hd`.
        response_format:
          anyOf:
            - type: string
              enum:
                - mp3
                - opus
                - aac
                - flac
                - wav
                - pcm
            - type: 'null'
          title: Response Format
          description: >-
            The format to audio in. Supported formats are `mp3`, `opus`, `aac`,
            `flac`, `wav`, and `pcm`.
          examples:
            - mp3
            - wav
        speed:
          anyOf:
            - type: number
              maximum: 4
              minimum: 0.25
            - type: 'null'
          title: Speed
          description: >-
            The speed of the generated audio. Select a value from `0.25` to
            `4.0`. `1.0` is the default.
          examples:
            - 1
            - 1.5
        stream_format:
          anyOf:
            - type: string
              enum:
                - sse
                - audio
            - type: 'null'
          title: Stream Format
          description: >-
            The format to stream the audio in. Supported formats are `sse` and
            `audio`. `sse` is not supported for `tts-1` or `tts-1-hd`.
          examples:
            - sse
            - audio
      type: object
      required:
        - model
        - input
        - voice
      title: CreateSpeechRequest
      description: Request to generate audio from text.
    HTTPValidationError:
      properties:
        detail:
          items:
            $ref: '#/components/schemas/ValidationError'
          type: array
          title: Detail
      type: object
      title: HTTPValidationError
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