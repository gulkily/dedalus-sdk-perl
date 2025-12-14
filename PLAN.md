# Dedalus Perl SDK implementation plan

This plan mirrors the structure and functionality of `~/dedalus-sdk-python` while adapting it to idiomatic Perl tooling and packaging. The work is grouped into phases so that we can deliver incremental, testable artifacts.

## 1. Audit the Python template and capture requirements
- Read `README.md`, `api.md`, `pyproject.toml`, and the contents of `src/dedalus_labs` to inventory supported resources (chat, audio, files, etc.), sync/async clients, streaming, file uploads, environment selection, and exception taxonomy.
- Enumerate every public API described in `api.md` (or generated sources under `src/dedalus_labs/resources`) and classify shared request/response models that must exist in the Perl version.
- Note cross-cutting behaviors such as automatic retries, idempotency headers, multipart helpers (`_files.py`), and query-string serialization (`_qs.py`) so we can design matching abstractions.

## 2. Bootstrap the Perl distribution skeleton
- Initialize a standard CPAN-friendly layout inside this repo (e.g., `lib/Dedalus.pm`, `lib/Dedalus/Client.pm`, `lib/Dedalus/Async.pm`, `lib/Dedalus/Types/*`, `t/` for tests, `script/` for helper CLIs, `examples/`, `README.md`, `Changes`).
- Choose build tooling (`ExtUtils::MakeMaker` or `Dist::Zilla`) and dependency management (`cpanfile`). Capture metadata (name, version, abstract, author, license) equivalent to the Python `pyproject`.
- Port relevant docs from the Python README (installation, sync/async usage, streaming) into a Perl-centric `README.md` and stub `api.md` so clients know what is coming.

## 3. Core configuration, auth, and environment handling
- Create `Dedalus::Config` to load API key from `DEDALUS_API_KEY`, select the API environment (`production` vs `development`), set default base URLs mirroring `src/dedalus_labs/_constants.py`, and expose user-agent/version info (version pulled from `lib/Dedalus/Version.pm`).
- Add a `Dedalus::Exception` hierarchy equivalent to `src/dedalus_labs/_exceptions.py` (e.g., `APIError`, `AuthenticationError`, `RateLimitError`, etc.) with JSON body parsing and helpful error messages.

## 4. HTTP client abstraction
- Build a synchronous HTTP layer (e.g., `Dedalus::HTTP::Sync`) around `HTTP::Tiny` or `Furl`, providing request signing, JSON encoding/decoding (`Cpanel::JSON::XS`), query serialization (port logic from `_qs.py`), multipart boundaries, and timeout configuration.
- Mirror Python’s retry/backoff behavior (if any) and expose hooks for custom user agents or proxies.
- Define a thin `Dedalus::Client` wrapper that instantiates the HTTP layer, exposes `resources` accessors, and normalizes responses into Perl data structures or typed objects.

## 5. Data models and serialization utilities
- Translate the shared request/response types present under `src/dedalus_labs/types` (and documented in `docs/api/schemas.md`) into Perl packages (likely using `Moo` + `Types::Standard`) housed in `lib/Dedalus/Types/*`. Cover chat completions, streaming chunks, responses structured outputs, audio/image payloads, etc.
- Provide helpers equivalent to `_models.py` for coercing hashrefs into typed objects, deep copying, validation of required params, and file abstractions (`Dedalus::FileUpload`).
- Document the mapping rules between JSON payloads and Perl objects so future regeneration from Stainless/OpenAPI is straightforward. Cite mirrored docs in `docs/` when describing schemas.

## 6. Resource modules (API surface)
- For each resource directory in the Python template (`resources/chat`, `resources/audio`, `resources/files`, `resources/responses`, etc.), create a mirrored Perl namespace (e.g., `Dedalus::Resources::Chat`).
- Implement methods for each endpoint described in `api.md` / `docs/api-reference/v1/*`, ensuring method signatures (required/optional params) and return structures stay consistent with the Python SDK / canonical docs.
- Support nested sub-resources (e.g., `chat.completions.create`, `responses.stream`) via composable classes or method chaining so the calling style matches `Dedalus->new->chat->completions->create(...)`. Expose raw/streaming wrappers similar to the Python SDK.

## 7. Streaming & async support
- Implement Server-Sent Events streaming similar to `src/dedalus_labs/_streaming.py`, likely using `Mojo::UserAgent` or `AnyEvent::HTTP` to yield incremental chunks while decoding event payloads (see `docs/sdk/streaming.md`).
- Provide `Dedalus::Async` built on `Mojo::Promise`/`Future::AsyncAwait` so async consumers can await the same resource methods (mirroring `AsyncDedalus` in the Python template). Share serialization code between sync and async clients to avoid drift.
- Extend streaming helpers beyond chat (e.g., responses streaming once documented) and ensure SSE chunk parsing matches the schemas captured in `docs/api-reference/v1/create-chat-completion.md`.

## 8. File uploads and multipart handling
- Port the logic from `_files.py` to detect file-like params, stream bodies from disk/handles, and include filenames + content types in multipart requests (done via `Dedalus::FileUpload`).
- Add high-level helpers for reading from scalar refs or tempfiles, ensuring compatibility with Perl’s IO handles. Reference `docs/api-reference/v1/create-transcription.md` / `create-translation.md` for accepted formats and metadata.

## 9. Testing strategy
- Recreate the behavior-driven tests that exist under `tests/` in the Python repo using `Test2::V0`/`Test::More`. Cover client initialization, parameter validation, query serialization, streaming iteration, error translation, and multipart boundaries.
- Stub HTTP interactions with `Test::HTTP::LocalServer` or `Test::Mojo` fixtures so tests remain offline and deterministic.
- Provide smoke tests for sync and async clients, plus golden tests for request bodies derived from fixtures that match `tests/api_resources/*` in the Python template.
- Add structured-output fixtures (responses/tool calling), SSE chunk snapshots, and environment override tests per the docs.

## 10. Tooling, CI, and release automation
- Configure linting/formatting (`Perl::Critic`, `perltidy`) similar to how the Python repo uses `nox` sessions.
- Add GitHub Actions (or similar) that run lint, test, and packaging pipelines, echoing the template’s release scripts under `bin/`.
- Document the release process (version bump in `Changes`, tag, upload to PAUSE/CPAN) paralleling the Python `publish-pypi` workflow.

Deliverables at the end of each phase: runnable code/tests plus updated docs, so progress is measurable and regressions are caught early.
