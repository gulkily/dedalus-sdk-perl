# Dedalus Perl SDK

This repository hosts the in-progress Dedalus Perl SDK. The project mirrors the behavior of the Python SDK while using idiomatic Perl tooling.

## Status

Planning and scaffolding. See `PLAN.md`, `CHECKLIST.md`, and `METHODOLOGY.md` for progress tracking.

The first resource implemented is the `health` endpoint so we can exercise an end-to-end API call.

## Development

```
perl Makefile.PL
make test
```

> Tests currently rely on `Test2::V0`. Install dependencies listed in `cpanfile` or via `cpanm --installdeps .`.

## Quick API check

Set `DEDALUS_API_KEY` and run the example script:

```
export DEDALUS_API_KEY=sk-...
perl examples/health_check.pl
```

This script calls `GET /health` and prints the response status to confirm connectivity.

Additional details will be added as the SDK implementation evolves.
