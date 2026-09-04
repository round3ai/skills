#!/usr/bin/env bash
# Refreshes the docs pages vendored under skills/three-dev/references/ from
# docs.three.dev. Run it, review the diff, commit. Never edit those files by
# hand; edit the docs and re-run this.
#
# All pages are fetched before any file is written, so a failure leaves the
# references untouched.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
out_dir="$repo_root/skills/three-dev/references"
base_url="https://docs.three.dev"

pages=(
  "sending-requests/sending-requests"
  "sending-requests/ai-providers-integration"
  "sending-requests/supported-paths"
  "api-reference/report-metric"
  "getting-started/planning-your-integration"
)

staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT

for page in "${pages[@]}"; do
  name=$(basename "$page")
  url="$base_url/$page.md"
  body=$(curl --fail --silent --show-error --location "$url")

  # GitBook answers a missing page with HTTP 200 and a "Page Not Found" body.
  if printf '%s\n' "$body" | head -n 3 | grep -q '^# Page Not Found'; then
    echo "error: $url returned the docs 404 page" >&2
    exit 1
  fi

  {
    printf '<!-- Synced from %s by scripts/sync-references.sh. Do not edit; the live page wins. -->\n\n' "$url"
    printf '%s\n' "$body" \
      | sed '1{/^> For the complete documentation index/d;}' \
      | sed '1{/^$/d;}' \
      | sed "s#](/#](${base_url}/#g"
  } > "$staging/$name.md"
done
# The first sed drops the blockquote GitBook prefixes to every .md page, the
# second the blank line under it, the third turns the docs' root-relative
# links into absolute ones so they still resolve from a local copy.

for page in "${pages[@]}"; do
  name=$(basename "$page")
  cp "$staging/$name.md" "$out_dir/$name.md"
  echo "synced $name.md"
done
