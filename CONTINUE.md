# Continuation notes

Async coverage now includes models, health checks, files, and sample scripts for embeddings/images. Use this file as the hand-off loop: before you pause, summarize status + next steps here; when you resume, read and update it.

Current priorities (see `CHECKLIST.md` / `PLAN.md` / `README.md` / `api.md` for context):

1. Flesh out type coverage and validation helpers under `lib/Dedalus/Types/*` so request/response models match the Python SDK (`_models.py`).
2. Port remaining resources from `dedalus-sdk-python` (assistants, threads, responses, fine-tuning/batches/vector stores, etc.) with async parity.
3. Build out the testing strategy (behavior-driven coverage, golden fixtures, streaming tests) and add CI + release tooling parity.

Recent progress: file upload helpers now mirror `_files.py` (via `Dedalus::FileUpload`), async/sync parity tests cover embeddings plus streaming chat payloads, CI now runs lint + tests across Perl 5.36/5.38, and the release process is documented in `RELEASE.md` + `Changes`.

Loop guidance:
- Run `git status` before/after each session (repo should be clean aside from personal assets like `examples/gdi_exclamation.wav`).
- Reference `PLAN.md`, `CHECKLIST.md`, `README.md`, and `api.md` each time you start a new chunk of work to stay aligned.
- Keep async + sync resources in lockstep; add tests/examples/docs for every new feature.
