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

### Chat completion example

After the health check works, try a simple chat completion:

```
export DEDALUS_API_KEY=sk-...
perl examples/chat_completion.pl
```

The script sends a `chat.completions.create` request and prints the assistant's response. Set `DEDALUS_MODEL` to target a specific model ID if needed.

### Listing models

```
export DEDALUS_API_KEY=sk-...
perl -Ilib -e 'use Dedalus; my $c = Dedalus->new; my $models = $c->models->list; print scalar(@{$models->data}), " models available\n";'
```

Use `models->retrieve($id)` to inspect capabilities and defaults for a specific model.

### Creating embeddings

```
export DEDALUS_API_KEY=sk-...
perl examples/create_embedding.pl
```

Override `DEDALUS_EMBEDDING_MODEL` or `DEDALUS_EMBEDDING_INPUT` to customize the request. The script prints the embedding dimensions returned by the API.

Additional details will be added as the SDK implementation evolves.
