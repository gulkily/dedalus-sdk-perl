# Dedalus Perl SDK API surface

This document mirrors the generated endpoints from the Python SDK for the current template. The Perl SDK also includes a few convenience endpoints (files and responses) that are not listed in the Python API docs.

- `root.get` — implemented, returns `Dedalus::Types::RootGetResponse`
- `health.check` — implemented, returns `Dedalus::Types::HealthCheckResponse` (status string)
- `chat.completions.create` — implemented for non-streaming calls, returns `Dedalus::Types::Chat::Completion`
- `chat.completions.create(stream => 1)` — returns `Dedalus::Stream` of incremental SSE events
- `embeddings.create` — implemented, returns `Dedalus::Types::CreateEmbeddingResponse`
- `models.list` — implemented, returns `Dedalus::Types::ListModelsResponse`
- `models.retrieve` — implemented, returns `Dedalus::Types::Model`
- `audio.transcriptions.create` — implemented, returns `Dedalus::Types::Audio::TranscriptionCreateResponse`
- `audio.translations.create` — implemented, returns `Dedalus::Types::Audio::TranslationCreateResponse`
- `audio.speech.create` — implemented, returns binary audio content
- `images.generate` — implemented, returns `Dedalus::Types::ImagesResponse`
- `images.edit` — implemented, returns `Dedalus::Types::ImagesResponse`
- `images.create_variation` — implemented, returns `Dedalus::Types::ImagesResponse`
- `files.list` — implemented, returns `Dedalus::Types::ListFilesResponse`
- `files.retrieve` — implemented, returns `Dedalus::Types::FileObject`
- `files.upload` — implemented, returns `Dedalus::Types::FileObject`
- `files.delete` — implemented, returns deletion metadata hash
- `files.content.retrieve` — implemented, returns `{ status, headers, content }`
- `responses.create` — implemented, returns `Dedalus::Types::Response`
- `responses.retrieve` — implemented, returns `Dedalus::Types::Response`
- `responses.create(stream => 1)` — returns `Dedalus::Stream` of `Dedalus::Types::Response::StreamEvent`
- `images.generate(stream => 1)` — returns `Dedalus::Stream` of `Dedalus::Types::Image::StreamEvent`

All resources in the current Python template are implemented; update this list if new endpoints appear upstream.

Update this file as new resource modules land to keep parity with `dedalus-sdk-python/api.md`.
