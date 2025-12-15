# Continuation notes

Async coverage now includes models, health checks, files, and sample scripts for embeddings/images. Use this file as the hand-off loop: before you pause, summarize status + next steps here; when you resume, read and update it.

Current priorities (see `CHECKLIST.md` / `PLAN.md` / `README.md` / `api.md` for context):

1. Finish any remaining types under `lib/Dedalus/Types/*`. Streaming chunks + response output blocks exist; next up are tool-call payloads, image/audio structured pieces, and other schemas from `docs/api/schemas.md`.
2. Then expand resource modules (responses streaming, assistants/threads/batches/vector stores, async wrappers) using the mirrored docs in `docs/api-reference/`.
3. Finally, extend the testing strategy (behavior-driven coverage, golden fixtures, structured-output/SSE tests) once types + resources are solid.

Recent progress: file upload helpers mirror `_files.py`, async/sync parity tests exist, CI + release docs are in place, the `responses` resource is available (example now falls back to chat completions if `/v1/responses` isn’t enabled on the current `DEDALUS_BASE_URL`), `Dedalus::Util::Params` now handles array coercion / validation like `_models.py`, chat streaming pushes `Dedalus::Types::Chat::CompletionChunk` objects, structured output items (`Dedalus::Types::Response::OutputItem`) power responses parsing, and `/v1/responses` now supports `stream => 1` returning typed `Dedalus::Types::Response::StreamEvent` chunks.

Loop guidance:
- Run `git status` before/after each session (repo should be clean aside from personal assets like `examples/gdi_exclamation.wav`).
- Reference `PLAN.md`, `CHECKLIST.md`, `README.md`, and `api.md` each time you start a new chunk of work to stay aligned.
- Keep async + sync resources in lockstep; add tests/examples/docs for every new feature.
