# Python SDK audit notes

Record findings from `~/dedalus-sdk-python`. For each entry, include date, component, summary, and action items.

## Template
```
## YYYY-MM-DD — Component name
- Files: path(s)
- Observations: ...
- Actions/Questions: ...
```

## Entries

## 2025-12-12 — Repository overview & README
- Files: README.md, src/dedalus_labs/, src/dedalus_labs/resources/, src/dedalus_labs/types/
- Observations:
  - SDK exposes both sync `Dedalus` and async `AsyncDedalus` clients using httpx, with optional aiohttp backend; README documents environment selection, streaming via SSE, file uploads, retries/timeouts, logging via `DEDALUS_LOG`, and raw response access (`with_raw_response`, `with_streaming_response`).
  - Error hierarchy rooted at `APIError` with connection/status subclasses, default headers (`User-Agent`, `X-SDK-Version`), automatic retries (2 attempts, covering connection/timeout/429/5xx).
  - Repo structure includes shared helpers (`_constants`, `_files`, `_qs`, `_streaming`, `_response`, `_models`, `_exceptions`), resources (audio, chat, embeddings, health, images, models, root), and typed models under `types/` (per resource plus shared/shared_params).
- Actions/Questions:
  - Mirror README coverage in Perl docs (sync/async usage, streaming, file uploads, retries/timeouts, logging env var, raw responses, extra params support).
  - Ensure Perl SDK has equivalents for `_files`, `_qs`, `_streaming`, `_response`, and the resource/type namespace split.
  - Need to inspect `api.md` and per-resource modules to capture endpoints + request/response schemas next.
## 2025-12-12 — API surface inventory (api.md)
- Files: api.md
- Observations:
  - High-level resources: root (`GET /`), health (`GET /health`), models (`GET /v1/models`, `GET /v1/models/{id}`), embeddings (`POST /v1/embeddings`), audio (speech/transcriptions/translations endpoints), images (generate/edit/variation), chat completions (`POST /v1/chat/completions`).
  - Shared type exports include model metadata (`DedalusModel`, `DedalusModelChoice`), response format wrappers, etc., meaning Perl types should expose similar aggregating module for ergonomic imports.
  - Binary response for audio speech create; other endpoints return structured types defined in `dedalus_labs.types.*`.
- Actions/Questions:
  - Need to audit each referenced resource module + params/response types to capture required fields, streaming support (chat completions), and binary handling for `audio.speech.create`.
  - Ensure Perl checklist covers shared type re-export convenience similar to `dedalus_labs.types` package.
## 2025-12-12 — Resource modules & type patterns
- Files: src/dedalus_labs/resources/root.py, health.py, models.py, embeddings.py, audio/*, images.py, chat/completions.py; src/dedalus_labs/types/**
- Observations:
  - Every resource exposes sync + async classes inheriting `SyncAPIResource` / `AsyncAPIResource`, each with `.with_raw_response` and `.with_streaming_response` helpers via `_response` wrappers plus `make_request_options` for `extra_headers`, `extra_query`, `extra_body`, request-level `timeout`, and optional `idempotency_key` on mutating calls.
  - Non-trivial resources (chat completions, audio, images) rely on `_utils.maybe_transform` / `async_maybe_transform` to coerce kwargs into typed dataclasses defined under `types.*_params`, plus `required_args` validation, `extract_files` + `deepcopy_minimal` for multipart bodies, and SSE helpers from `_streaming.Stream` / `AsyncStream` and `lib.streaming.chat.ChatCompletionStreamManager`.
  - `chat.completions.create` supports both regular and streaming returns (`Completion` vs `Stream[StreamChunk]`), handles hundreds of params, performs tool validation via `lib._parsing`, accepts `idempotency_key`, and exposes `with_streaming_response`; this complexity needs dedicated Perl abstractions (typed params coercion, SSE stream manager, union return type, tool parsing helpers).
  - Audio speech endpoint sets `Accept: audio/mpeg` and returns `BinaryAPIResponse` / `AsyncBinaryAPIResponse`, while transcriptions/translations/uploads send multipart form data assembled with `_files.extract_files` and `FileTypes` union.
  - Images endpoints (generate/edit/variation) share multipart helpers and enumerated options (size, quality, style, response format, stream toggle), suggesting Perl SDK needs shared file-handling + option validation modules to avoid duplication.
  - `dedalus_labs.types` re-exports key response/param types; resource-specific subpackages (e.g., `types.chat`, `types.audio`) include `__init__` aggregators. Request params use `TypedDict` (for compile-time checking) while responses/events are `pydantic.BaseModel` classes with nested enums/TypeAlias definitions (`DedalusModel`, `ResponseFormat*`, etc.).
- Actions/Questions:
  - Design Perl equivalents for `_utils.maybe_transform`, `extract_files`, SSE `Stream`/`AsyncStream`, and parsing/validation helpers referenced in chat streaming.
  - Mirror the sync/async resource structure plus `with_raw_response` / `with_streaming_response` wrappers so parity claims hold.
  - Need deeper dive into `types.chat` structures (stream chunks, logprobs) and shared helpers under `lib/` to plan Perl type system + streaming manager.
