# Continuation notes

Async coverage now includes models, health checks, files, and sample scripts for embeddings/images. Use this file as the hand-off loop: before you pause, summarize status + next steps here; when you resume, read and update it.

Current priorities (see `CHECKLIST.md` / `PLAN.md` / `README.md` / `api.md` for context):

1. Flesh out type coverage and validation helpers under `lib/Dedalus/Types/*` so request/response models match the Python SDK + mirrored docs (`docs/api/schemas.md`). That includes streaming chunks, responses structured outputs, and tool call payloads.
2. Port remaining resources from `dedalus-sdk-python` (assistants, threads, batches, vector stores, etc.) with async parity, referencing the local doc copies in `docs/api-reference/`.
3. Build out the testing strategy (behavior-driven coverage, golden fixtures, structured-output/SSE tests) and add CI + release tooling parity.

Recent progress: file upload helpers mirror `_files.py`, async/sync parity tests exist, CI + release docs are in place, the `responses` resource is available (example now falls back to chat completions if `/v1/responses` isn’t enabled on the current `DEDALUS_BASE_URL`), and `Dedalus::Util::Params` now handles array coercion / validation like `_models.py` (used by embeddings + responses).

Loop guidance:
- Run `git status` before/after each session (repo should be clean aside from personal assets like `examples/gdi_exclamation.wav`).
- Reference `PLAN.md`, `CHECKLIST.md`, `README.md`, and `api.md` each time you start a new chunk of work to stay aligned.
- Keep async + sync resources in lockstep; add tests/examples/docs for every new feature.
