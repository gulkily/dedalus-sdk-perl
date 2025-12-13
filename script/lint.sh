#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

FILES=$(git ls-files '*.pm' '*.pl' '*.t')

if command -v perlcritic >/dev/null 2>&1; then
    perlcritic $FILES
else
    echo "perlcritic not installed; skipping" >&2
fi

if command -v perltidy >/dev/null 2>&1; then
    if [ -n "$FILES" ]; then
        perltidy --profile=.perltidyrc --assert-tidy $FILES
    fi
else
    echo "perltidy not installed; skipping" >&2
fi
