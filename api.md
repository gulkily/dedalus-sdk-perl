# Dedalus Perl SDK API surface

This document will mirror the generated endpoints from the Python SDK once Perl resources are implemented.

- `health.check` — implemented, returns `Dedalus::Types::HealthCheckResponse` (status string)
- `chat.completions.create` — implemented for non-streaming calls, returns `Dedalus::Types::Chat::Completion`
- Remaining resources are pending porting from `PLAN.md` / Python template.

Update this file as new resource modules land to keep parity with `dedalus-sdk-python/api.md`.
