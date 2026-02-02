#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python_root="${1:-$root/../dedalus-sdk-python/src/dedalus_labs}"
perl_root="$root/lib/Dedalus"
include_params="${2:-}"

if [[ ! -d "$python_root" ]]; then
  echo "Python SDK not found at $python_root" >&2
  exit 1
fi

if [[ ! -d "$perl_root" ]]; then
  echo "Perl SDK not found at $perl_root" >&2
  exit 1
fi

workdir="$(mktemp -d)"
cleanup() { rm -rf "$workdir"; }
trap cleanup EXIT

list_python_modules() {
  local base="$1"
  local filter_params="$2"
  find "$base" -type f -name "*.py" \
    | sed "s#^$base/##" \
    | sed 's#\.py$##' \
    | grep -v '__init__$' \
    | { if [[ "$filter_params" == "1" ]]; then grep -v '_params$'; else cat; fi; } \
    | grep -v '^shared_params/' \
    | perl -pe 'chomp; @p=split("/"); if (@p>=2 && $p[-1] eq $p[-2]) { pop @p; } $_=join("/", @p) . "\n";' \
    | tr 'A-Z' 'a-z' \
    | tr -d '_' \
    | sed -E 's#^chat/chatcompletion#chat/completion#' \
    | sed -E 's#^chat/streamchunk$#chat/completionchunk#'
}

list_perl_modules() {
  local base="$1"
  find "$base" -type f -name "*.pm" \
    | sed "s#^$base/##" \
    | sed 's#\.pm$##' \
    | tr 'A-Z' 'a-z' \
    | tr -d '_'
}

filter_params=1
if [[ "$include_params" == "--include-params" ]]; then
  filter_params=0
fi

list_python_modules "$python_root/types" "$filter_params" | sort > "$workdir/py_types"
list_perl_modules "$perl_root/Types" | sort > "$workdir/perl_types"

list_python_modules "$python_root/resources" 0 | sort > "$workdir/py_resources"
list_perl_modules "$perl_root/Resources" | sort > "$workdir/perl_resources"

echo "# Types parity"
if comm -23 "$workdir/py_types" "$workdir/perl_types" | grep -q .; then
  echo "Missing in Perl (types):"
  comm -23 "$workdir/py_types" "$workdir/perl_types"
else
  echo "Missing in Perl (types): none"
fi

if comm -13 "$workdir/py_types" "$workdir/perl_types" | grep -q .; then
  echo "Extra in Perl (types):"
  comm -13 "$workdir/py_types" "$workdir/perl_types"
else
  echo "Extra in Perl (types): none"
fi

echo

echo "# Resources parity"
if comm -23 "$workdir/py_resources" "$workdir/perl_resources" | grep -q .; then
  echo "Missing in Perl (resources):"
  comm -23 "$workdir/py_resources" "$workdir/perl_resources"
else
  echo "Missing in Perl (resources): none"
fi

if comm -13 "$workdir/py_resources" "$workdir/perl_resources" | grep -q .; then
  echo "Extra in Perl (resources):"
  comm -13 "$workdir/py_resources" "$workdir/perl_resources"
else
  echo "Extra in Perl (resources): none"
fi
