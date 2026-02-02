# Python ↔ Perl Parity

This document tracks parity between `dedalus-sdk-python` and this Perl SDK.
Use it alongside `CHECKLIST.md` and `script/parity_report.sh`.

## How to check parity

Run the parity report script from the repo root:

```
script/parity_report.sh
```

Optional args:

```
script/parity_report.sh /path/to/dedalus-sdk-python/src/dedalus_labs --include-params
```

You can also fail CI or pre-commit checks when parity is missing:

```
script/parity_report.sh --check
```

Interpretation tips:
- "Missing in Perl" is the actionable list.
- "Extra in Perl" often reflects finer-grained type classes (expected).

## Resource parity snapshot

Resource | Python | Perl | Status | Notes
---|---|---|---|---
Root | get `/` | root.get | ok |
Health | health.check | health.check | ok |
Models | list/retrieve | list/retrieve | ok |
Embeddings | create | create | ok |
Audio | speech/transcriptions/translations | speech/transcriptions/translations | ok |
Images | generate/edit/variation | generate/edit/variation | ok |
Chat | completions.create (+stream) | completions.create (+stream) | ok |
Files | not in Python API docs | list/retrieve/upload/delete/content | ok | Perl supports file mgmt endpoints
Responses | not in Python API docs | create/retrieve/stream | ok | Perl includes responses helpers

## Type parity

All Python response types tracked in `docs/api/schemas.md` are present in Perl.
The Perl SDK additionally exposes granular helper types (audio segments/words,
response output blocks, etc.) for convenience.

## Update policy

- Update this file when new resources/types land.
- Update `CHECKLIST.md` whenever parity status changes.
- Keep `script/parity_report.sh` aligned with the latest Python SDK layout.
