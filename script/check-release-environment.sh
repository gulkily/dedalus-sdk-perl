#!/usr/bin/env bash
set -euo pipefail

errors=()

if [[ -z "${PAUSE_ID:-}" ]]; then
  errors+=("PAUSE_ID is not set. Export your PAUSE username.")
fi

if [[ -z "${PAUSE_PASSWORD:-}" ]]; then
  errors+=("PAUSE_PASSWORD is not set. Export your PAUSE password.")
fi

if [[ "${#errors[@]}" -gt 0 ]]; then
  echo "Found the following errors in the release environment:"
  for error in "${errors[@]}"; do
    echo "- $error"
  done
  exit 1
fi

echo "Release environment looks good."
