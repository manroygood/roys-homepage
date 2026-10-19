#!/usr/bin/env bash
# Build the site the way Netlify does and fail if Hugo reports any error.
# Run by the pre-push hook in .githooks/ (enable once with `git config core.hooksPath .githooks`)
# and by the add-paper skill. Usage: scripts/check-build.sh
set -u
cd "$(dirname "$0")/.."

out=$(mktemp -d)
log=$(mktemp)
trap 'rm -rf "$out" "$log"' EXIT

if ! command -v hugo >/dev/null; then
  echo "check-build: hugo not found" >&2
  exit 1
fi

# Same flags as netlify.toml, minus the debug logging.
hugo --gc --minify -b https://roygoodman.net/ -d "$out" >"$log" 2>&1
status=$?

# Hugo sometimes logs an ERROR line without exiting non-zero, so check both.
if [ $status -ne 0 ] || grep -q '^ERROR' "$log"; then
  echo "check-build: the site does not build. Hugo said:" >&2
  if grep -q '^ERROR' "$log"; then grep '^ERROR' "$log" >&2; else tail -20 "$log" >&2; fi
  echo "check-build: fix the error above (or push with --no-verify to skip this check)." >&2
  exit 1
fi

echo "check-build: site builds cleanly ($(hugo version | awk '{print $2}'))."
