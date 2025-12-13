# Dedalus Perl SDK

This repository hosts the in-progress Dedalus Perl SDK. The project mirrors the behavior of the Python SDK while using idiomatic Perl tooling.

## Status

Planning and scaffolding. See `PLAN.md`, `CHECKLIST.md`, and `METHODOLOGY.md` for progress tracking.

The first resource implemented is the `health` endpoint so we can exercise an end-to-end API call.

## Development

```
perl Makefile.PL
make test
```

> Tests currently rely on `Test2::V0`. Install dependencies listed in `cpanfile` or via `cpanm --installdeps .`.

## Quick API check

Set `DEDALUS_API_KEY` and run the example script:

```
export DEDALUS_API_KEY=sk-...
perl examples/health_check.pl
```

This script calls `GET /health` and prints the response status to confirm connectivity.

### Chat completion example

After the health check works, try a simple chat completion:

```
export DEDALUS_API_KEY=sk-...
perl examples/chat_completion.pl
```

The script sends a `chat.completions.create` request and prints the assistant's response. Set `DEDALUS_MODEL` to target a specific model ID if needed.

### Streaming chat completions

```
export DEDALUS_API_KEY=sk-...
perl examples/chat_stream_live.pl "Hello, how do you feel today?"
```

Chunks print as soon as they arrive. The underlying `Dedalus::Stream` object yields decoded SSE payloads until the `[DONE]` sentinel is reached.

### Listing models

```
export DEDALUS_API_KEY=sk-...
perl examples/list_models.pl
```

Use `models->retrieve($id)` to inspect capabilities and defaults for a specific model.

### Creating embeddings

```
export DEDALUS_API_KEY=sk-...
perl examples/create_embedding.pl
```

Override `DEDALUS_EMBEDDING_MODEL` or `DEDALUS_EMBEDDING_INPUT` to customize the request. The script prints the embedding dimensions returned by the API.

### Audio transcription

```
export DEDALUS_API_KEY=sk-...
perl examples/audio_transcription.pl /path/to/audio.wav
```

Set `DEDALUS_AUDIO_FILE` or pass the file path as the first argument. Override `DEDALUS_TRANSCRIPTION_MODEL` to choose a different Whisper-compatible ID. The script prints the transcript returned by the API.

### Audio translation

Use the same API entry point but target `/audio/translations` when you need English output:

```
export DEDALUS_API_KEY=sk-...
perl examples/audio_translation.pl /path/to/audio.wav
```

### Text-to-speech

```
export DEDALUS_API_KEY=sk-...
perl examples/text_to_speech.pl "Hello Dedalus" output.mp3
```

Set `response_format` to `mp3`, `wav`, etc., as needed. The return value is a hash with `content`, `headers`, and `status` so you can write the binary blob to disk.

### Image generation

```
export DEDALUS_API_KEY=sk-...
perl examples/image_generate.pl "A watercolor portrait of Stephen Dedalus"
```

Set `DEDALUS_IMAGE_PROMPT`, `DEDALUS_IMAGE_MODEL`, or `DEDALUS_IMAGE_OUTPUT` to customize the request. If the API returns base64 data the script writes it to disk; otherwise it prints the image URL for manual download.

Additional details will be added as the SDK implementation evolves.
