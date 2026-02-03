# Continuation notes

Async coverage now includes models, health checks, files, and sample scripts for embeddings/images. Use this file as the hand-off loop: before you pause, summarize status + next steps here; when you resume, read and update it.

Current priorities (see `CHECKLIST.md` / `PLAN.md` / `README.md` / `api.md` for context):

1. Types + resources are complete for the current Python template; keep them in sync if docs/templates expand.
2. Extend the testing strategy (behavior-driven coverage, mirror remaining Python regressions) now that core APIs are stable.
3. Tackle release tooling parity with Python (version bump/publish automation scripts).

Recent progress: file upload helpers mirror `_files.py`, async/sync parity tests exist, CI + release docs are in place, the `responses` resource is available (example now falls back to chat completions if `/v1/responses` isn’t enabled on the current `DEDALUS_BASE_URL`), `Dedalus::Util::Params` now handles array coercion / validation like `_models.py`, chat streaming pushes `Dedalus::Types::Chat::CompletionChunk` objects, structured output items (`Dedalus::Types::Response::OutputItem`) power responses parsing, `/v1/responses` supports `stream => 1` returning typed `Dedalus::Types::Response::StreamEvent` chunks, chat AND responses have golden fixtures, `/v1/images/generations` now supports streaming with `Dedalus::Types::Image::StreamEvent` chunks, audio transcription/translation responses now expose typed segments/words/logprobs/usage just like the Python SDK (plus new tests), `Dedalus::Types::RootGetResponse` models the `/` health check, new error/runner result types round out the schemas from `docs/api/schemas.md`, and sync/async clients now expose a `/` root resource backed by `Dedalus::Resources::Root` + tests.

Session update: runner streaming now finalizes on `[DONE]` events to avoid hangs in async/sync streams; response output content blocks parse image/audio fields; chat completion choices now parse logprobs plus service tier/system fingerprint; response format helper types added (text/json_object/json_schema) along with shared settings + Dedalus model helper types; parsed chat completion helper types now exist; chat model ID + models param helper types added; parity report script (`script/parity_report.sh`) added for Python↔Perl types/resources with `--check`; parity matrix doc in `PARITY.md` tracks coverage; querystring serializer now mirrors `_qs.py` and backs HTTP query building (including error cases); added multipart file upload + querystring + file-extraction edge cases/errors + array leaf + deepcopy + SSE parser (streaming edge cases + CRLF) + HTTP query build + require_params (invalid input) + params utility edge cases + file upload (error cases + defaults + content type) + MIME type + multipart error (tuple/hash content types) + config (environments copy) + HTTP retry + stream + HTTP error mapping + HTTP response parsing regression tests; types/resources are complete for the current Python template. Next focus: mirror remaining Python regression coverage and release tooling parity.

Loop guidance:
- Run `git status` before/after each session (repo should be clean aside from personal assets like `examples/gdi_exclamation.wav`).
- Reference `PLAN.md`, `CHECKLIST.md`, `README.md`, and `api.md` each time you start a new chunk of work to stay aligned.
- Keep async + sync resources in lockstep; add tests/examples/docs for every new feature.
- Use a fresh git branch for each step and merge it after committing the step's changes.
