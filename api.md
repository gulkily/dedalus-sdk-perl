# Dedalus Perl SDK API surface

This document will mirror the generated endpoints from the Python SDK once Perl resources are implemented.

- `health.check` — implemented, returns `Dedalus::Types::HealthCheckResponse` (status string)
- `chat.completions.create` — implemented for non-streaming calls, returns `Dedalus::Types::Chat::Completion`
- `embeddings.create` — implemented, returns `Dedalus::Types::CreateEmbeddingResponse`
- `models.list` — implemented, returns `Dedalus::Types::ListModelsResponse`
- `models.retrieve` — implemented, returns `Dedalus::Types::Model`
- `audio.transcriptions.create` — implemented, returns `Dedalus::Types::Audio::TranscriptionCreateResponse`
- `audio.translations.create` — implemented, returns `Dedalus::Types::Audio::TranslationCreateResponse`
- `audio.speech.create` — implemented, returns binary audio content
- `images.generate` — implemented, returns `Dedalus::Types::ImagesResponse`
- `images.edit` — implemented, returns `Dedalus::Types::ImagesResponse`
- `images.create_variation` — implemented, returns `Dedalus::Types::ImagesResponse`
- Remaining resources are pending porting from `PLAN.md` / Python template.

Update this file as new resource modules land to keep parity with `dedalus-sdk-python/api.md`.
