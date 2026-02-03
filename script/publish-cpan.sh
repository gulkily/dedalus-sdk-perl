#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$script_dir/.." && pwd)"

if [[ -z "${PAUSE_ID:-}" || -z "${PAUSE_PASSWORD:-}" ]]; then
  echo "PAUSE_ID and PAUSE_PASSWORD must be set."
  exit 1
fi

cd "$root"
make dist

dist_file="$(ls -t Dedalus-Perl-SDK-*.tar.gz | head -n 1)"
if [[ -z "$dist_file" ]]; then
  echo "No dist tarball found."
  exit 1
fi

cpan-upload -u "$PAUSE_ID" -p "$PAUSE_PASSWORD" "$dist_file"
