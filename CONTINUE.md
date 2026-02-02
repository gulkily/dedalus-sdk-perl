# Continuation notes

Async coverage now includes models, health checks, files, and sample scripts for embeddings/images. Use this file as the hand-off loop: before you pause, summarize status + next steps here; when you resume, read and update it.

Current priorities (see `CHECKLIST.md` / `PLAN.md` / `README.md` / `api.md` for context):

1. Finish any remaining types under `lib/Dedalus/Types/*`. Streaming chunks + response output blocks + tool-call payloads now exist; next up are image/audio structured pieces and any other schemas from `docs/api/schemas.md`.
2. Then expand resource modules (responses streaming, assistants/threads/batches/vector stores, async wrappers) using the mirrored docs in `docs/api-reference/`.
3. Finally, extend the testing strategy (behavior-driven coverage, golden fixtures, structured-output/SSE tests) once types + resources are solid.

Recent progress: file upload helpers mirror `_files.py`, async/sync parity tests exist, CI + release docs are in place, the `responses` resource is available (example now falls back to chat completions if `/v1/responses` isn’t enabled on the current `DEDALUS_BASE_URL`), `Dedalus::Util::Params` now handles array coercion / validation like `_models.py`, chat streaming pushes `Dedalus::Types::Chat::CompletionChunk` objects, structured output items (`Dedalus::Types::Response::OutputItem`) power responses parsing, `/v1/responses` supports `stream => 1` returning typed `Dedalus::Types::Response::StreamEvent` chunks, chat AND responses have golden fixtures, `/v1/images/generations` now supports streaming with `Dedalus::Types::Image::StreamEvent` chunks, audio transcription/translation responses now expose typed segments/words/logprobs/usage just like the Python SDK (plus new tests), `Dedalus::Types::RootGetResponse` models the `/` health check, new error/runner result types round out the schemas from `docs/api/schemas.md`, and sync/async clients now expose a `/` root resource backed by `Dedalus::Resources::Root` + tests.

Session update: runner streaming now finalizes on `[DONE]` events to avoid hangs in async/sync streams; response output content blocks parse image/audio fields; chat completion choices now parse logprobs plus service tier/system fingerprint; response format helper types added (text/json_object/json_schema) along with shared settings + Dedalus model helper types; parsed chat completion helper types now exist; chat model ID + models param helper types added; parity report script (`script/parity_report.sh`) added for Python↔Perl types/resources; parity matrix doc in `PARITY.md` tracks coverage; next focus is any remaining schemas from `docs/api/schemas.md` before moving on to resource parity.

Loop guidance:
- Run `git status` before/after each session (repo should be clean aside from personal assets like `examples/gdi_exclamation.wav`).
- Reference `PLAN.md`, `CHECKLIST.md`, `README.md`, and `api.md` each time you start a new chunk of work to stay aligned.
- Keep async + sync resources in lockstep; add tests/examples/docs for every new feature.
- Use a fresh git branch for each step and merge it after committing the step's changes.
