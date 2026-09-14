#!/usr/bin/env bash
# Fails when a relative Markdown link in README.md points at a file or
# directory that does not exist in the repository.
set -euo pipefail

cd "$(dirname "$0")/.."

status=0
count=0
while IFS= read -r target; do
  path=${target%%#*}
  [ -n "$path" ] || continue
  count=$((count + 1))
  if [ ! -e "$path" ]; then
    echo "README.md: link to $target does not resolve" >&2
    status=1
  fi
done < <(grep -oE '\]\([^)]+\)' README.md | sed -E 's/^\]\(([^ )]+).*\)$/\1/' | grep -vE '^(https?:|mailto:|#)')

if [ "$status" -eq 0 ]; then
  echo "all $count relative links in README.md resolve"
fi
exit "$status"
