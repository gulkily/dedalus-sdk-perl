# Create Transcription

> Transcribe audio into text.

Transcribes audio files using OpenAI's Whisper model. Supports multiple audio formats
including mp3, mp4, mpeg, mpga, m4a, wav, and webm. Maximum file size is 25 MB.

Args:
    file: Audio file to transcribe (required)
    model: Model ID to use (e.g., "openai/whisper-1")
    language: ISO-639-1 language code (e.g., "en", "es") - improves accuracy
    prompt: Optional text to guide the model's style
    response_format: Format of the output (json, text, srt, verbose_json, vtt)
    temperature: Sampling temperature between 0 and 1

Returns:
    Transcription object with the transcribed text

## OpenAPI

````yaml openapi.json post /v1/audio/transcriptions
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
  /v1/audio/transcriptions:
    post:
      tags:
        - v1
        - audio
      summary: Create Transcription
      description: >-
        Transcribe audio into text.


        Transcribes audio files using OpenAI's Whisper model. Supports multiple
        audio formats

        including mp3, mp4, mpeg, mpga, m4a, wav, and webm. Maximum file size is
        25 MB.


        Args:
            file: Audio file to transcribe (required)
            model: Model ID to use (e.g., "openai/whisper-1")
            language: ISO-639-1 language code (e.g., "en", "es") - improves accuracy
            prompt: Optional text to guide the model's style
            response_format: Format of the output (json, text, srt, verbose_json, vtt)
            temperature: Sampling temperature between 0 and 1

        Returns:
            Transcription object with the transcribed text
      operationId: create_transcription_v1_audio_transcriptions_post
      requestBody:
        content:
          multipart/form-data:
            schema:
              $ref: >-
                #/components/schemas/Body_create_transcription_v1_audio_transcriptions_post
        required: true
      responses:
        '200':
          description: Successful Response
          content:
            application/json:
              schema:
                anyOf:
                  - $ref: >-
                      #/components/schemas/CreateTranscriptionResponseVerboseJson
                  - $ref: '#/components/schemas/CreateTranscriptionResponseJson'
                title: Response Create Transcription V1 Audio Transcriptions Post
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
    Body_create_transcription_v1_audio_transcriptions_post:
      properties:
        file:
          type: string
          format: binary
          title: File
        model:
          type: string
          title: Model
        language:
          anyOf:
            - type: string
            - type: 'null'
          title: Language
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
      title: Body_create_transcription_v1_audio_transcriptions_post
    CreateTranscriptionResponseVerboseJson:
      properties:
        language:
          type: string
          title: Language
          description: The language of the input audio.
          x-order: 0
        duration:
          type: number
          title: Duration
          description: The duration of the input audio.
          x-order: 1
        text:
          type: string
          title: Text
          description: The transcribed text.
          x-order: 2
        words:
          items:
            $ref: '#/components/schemas/TranscriptionWord'
          type: array
          title: Words
          description: Extracted words and their corresponding timestamps.
          x-order: 3
        segments:
          items:
            $ref: '#/components/schemas/TranscriptionSegment'
          type: array
          title: Segments
          description: Segments of the transcribed text and their corresponding details.
          x-order: 4
        usage:
          $ref: '#/components/schemas/TranscriptTextUsageDuration'
          description: Usage statistics for models billed by audio input duration.
          x-order: 5
      type: object
      required:
        - language
        - duration
        - text
      title: CreateTranscriptionResponseVerboseJson
      description: >-
        Represents a verbose json transcription response returned by model,
        based on the provided input.


        Fields:
          - language (required): str
          - duration (required): float
          - text (required): str
          - words (optional): list[TranscriptionWord]
          - segments (optional): list[TranscriptionSegment]
          - usage (optional): TranscriptTextUsageDuration
    CreateTranscriptionResponseJson:
      properties:
        text:
          type: string
          title: Text
          description: The transcribed text.
          x-order: 0
        logprobs:
          items:
            $ref: '#/components/schemas/LogprobsItem'
          type: array
          title: Logprobs
          description: >-
            The log probabilities of the tokens in the transcription. Only
            returned with the models `gpt-4o-transcribe` and
            `gpt-4o-mini-transcribe` if `logprobs` is added to the `include`
            array.
          x-order: 1
        usage:
          oneOf:
            - $ref: '#/components/schemas/TranscriptTextUsageTokens'
            - $ref: '#/components/schemas/TranscriptTextUsageDuration'
          title: Usage
          description: Token usage statistics for the request.
          discriminator:
            propertyName: type
            mapping:
              duration: '#/components/schemas/TranscriptTextUsageDuration'
              tokens: '#/components/schemas/TranscriptTextUsageTokens'
          x-order: 2
      type: object
      required:
        - text
      title: CreateTranscriptionResponseJson
      description: >-
        Represents a transcription response returned by model, based on the
        provided input.


        Fields:
          - text (required): str
          - logprobs (optional): list[LogprobsItem]
          - usage (optional): Usage
    HTTPValidationError:
      properties:
        detail:
          items:
            $ref: '#/components/schemas/ValidationError'
          type: array
          title: Detail
      type: object
      title: HTTPValidationError
    TranscriptionWord:
      properties:
        word:
          type: string
          title: Word
          description: The text content of the word.
          x-order: 0
        start:
          type: number
          title: Start
          description: Start time of the word in seconds.
          x-order: 1
        end:
          type: number
          title: End
          description: End time of the word in seconds.
          x-order: 2
      type: object
      required:
        - word
        - start
        - end
      title: TranscriptionWord
      description: |-
        Fields:
        - word (required): str
        - start (required): float
        - end (required): float
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
    TranscriptTextUsageDuration:
      properties:
        type:
          type: string
          const: duration
          title: Type
          description: The type of the usage object. Always `duration` for this variant.
          x-order: 0
        seconds:
          type: number
          title: Seconds
          description: Duration of the input audio in seconds.
          x-order: 1
      type: object
      required:
        - type
        - seconds
      title: TranscriptTextUsageDuration
      description: |-
        Usage statistics for models billed by audio input duration.

        Fields:
          - type (required): Literal['duration']
          - seconds (required): float
    LogprobsItem:
      properties:
        token:
          type: string
          title: Token
          description: The token in the transcription.
          x-order: 0
        logprob:
          type: number
          title: Logprob
          description: The log probability of the token.
          x-order: 1
        bytes:
          items:
            type: number
          type: array
          title: Bytes
          description: The bytes of the token.
          x-order: 2
      type: object
      title: LogprobsItem
      description: |-
        Fields:
        - token (optional): str
        - logprob (optional): float
        - bytes (optional): list[float]
    TranscriptTextUsageTokens:
      properties:
        type:
          type: string
          const: tokens
          title: Type
          description: The type of the usage object. Always `tokens` for this variant.
          x-order: 0
        input_tokens:
          type: integer
          title: Input Tokens
          description: Number of input tokens billed for this request.
          x-order: 1
        input_token_details:
          $ref: '#/components/schemas/InputTokenDetails'
          description: Details about the input tokens billed for this request.
          x-order: 2
        output_tokens:
          type: integer
          title: Output Tokens
          description: Number of output tokens generated.
          x-order: 3
        total_tokens:
          type: integer
          title: Total Tokens
          description: Total number of tokens used (input + output).
          x-order: 4
      type: object
      required:
        - type
        - input_tokens
        - output_tokens
        - total_tokens
      title: TranscriptTextUsageTokens
      description: |-
        Usage statistics for models billed by token usage.

        Fields:
          - type (required): Literal['tokens']
          - input_tokens (required): int
          - input_token_details (optional): InputTokenDetails
          - output_tokens (required): int
          - total_tokens (required): int
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
    InputTokenDetails:
      properties:
        text_tokens:
          type: integer
          title: Text Tokens
          description: Number of text tokens billed for this request.
          x-order: 0
        audio_tokens:
          type: integer
          title: Audio Tokens
          description: Number of audio tokens billed for this request.
          x-order: 1
      type: object
      title: InputTokenDetails
      description: |-
        Details about the input tokens billed for this request.

        Fields:
          - text_tokens (optional): int
          - audio_tokens (optional): int
  securitySchemes:
    Bearer:
      type: http
      description: API key authentication using Bearer token
      scheme: bearer

````

---

> To find navigation and other pages in this documentation, fetch the llms.txt file at: https://docs.dedaluslabs.ai/llms.txt