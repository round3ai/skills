#!/usr/bin/env bash
# Fails when the plugin manifests disagree: every client's manifest must name
# the same plugin, carry the same description, and point at files that exist.
set -euo pipefail

cd "$(dirname "$0")/.."

status=0
fail() {
  echo "$1" >&2
  status=1
}

names=(
  "plugin.json:.name"
  ".claude-plugin/plugin.json:.name"
  ".cursor-plugin/plugin.json:.name"
  ".codex-plugin/plugin.json:.name"
  ".claude-plugin/marketplace.json:.plugins[0].name"
  ".cursor-plugin/marketplace.json:.plugins[0].name"
  ".agents/plugins/marketplace.json:.plugins[0].name"
)
descriptions=(
  "plugin.json:.description"
  ".claude-plugin/plugin.json:.description"
  ".cursor-plugin/plugin.json:.description"
  ".codex-plugin/plugin.json:.description"
  ".claude-plugin/marketplace.json:.plugins[0].description"
  ".cursor-plugin/marketplace.json:.plugins[0].description"
)
pointers=(
  ".claude-plugin/plugin.json:.skills"
  ".claude-plugin/plugin.json:.mcpServers"
  ".cursor-plugin/plugin.json:.skills"
  ".cursor-plugin/plugin.json:.mcpServers"
  ".codex-plugin/plugin.json:.skills"
  ".codex-plugin/plugin.json:.mcpServers"
)

read_field() {
  local file=${1%%:*} path=${1#*:}
  if [ ! -f "$file" ]; then
    echo "$file: missing" >&2
    return 1
  fi
  if ! jq -er "$path // empty" "$file" 2>/dev/null; then
    echo "$file: no $path" >&2
    return 1
  fi
}

check_same() {
  local label=$1
  shift
  local expected="" source="" entry value
  for entry in "$@"; do
    if ! value=$(read_field "$entry"); then
      status=1
      continue
    fi
    if [ -z "$source" ]; then
      expected=$value
      source=${entry%%:*}
    elif [ "$value" != "$expected" ]; then
      fail "${entry%%:*}: $label differs from $source"
    fi
  done
}

check_same "plugin name" "${names[@]}"
check_same "plugin description" "${descriptions[@]}"

for entry in "${pointers[@]}"; do
  if ! target=$(read_field "$entry"); then
    status=1
    continue
  fi
  [ -e "$target" ] || fail "${entry%%:*}: ${entry#*:} points at $target, which does not exist"
done

if [ "$status" -eq 0 ]; then
  echo "plugin manifests agree"
fi
exit "$status"
