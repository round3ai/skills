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
  ".claude-plugin/plugin.json:.icon"
  ".cursor-plugin/plugin.json:.logo"
  'plugin.json:.extensions["com.openai"].interface.logo'
  'plugin.json:.extensions["com.openai"].interface.composerIcon'
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

# Like read_field, but prints any JSON value (objects and arrays too) in a
# canonical form, so two files compare equal whatever their key order.
read_json() {
  local file=${1%%:*} path=${1#*:}
  if [ ! -f "$file" ]; then
    echo "$file: missing" >&2
    return 1
  fi
  if ! jq -ecS "$path // empty" "$file" 2>/dev/null; then
    echo "$file: no $path" >&2
    return 1
  fi
}

check_same_json() {
  local label=$1
  shift
  local expected="" source="" entry value
  for entry in "$@"; do
    if ! value=$(read_json "$entry"); then
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

# Codex reads the root plugin.json first when it declares the Agent Plugins
# schema, and .codex-plugin/plugin.json only as a fallback for older builds.
# Both must carry the same Codex settings.
check_same_json "Codex interface" \
  'plugin.json:.extensions["com.openai"].interface' \
  '.codex-plugin/plugin.json:.interface'
check_same_json "Codex onboardingSkill" \
  'plugin.json:.extensions["com.openai"].onboardingSkill' \
  '.codex-plugin/plugin.json:.extensions["com.openai"].onboardingSkill'
if onboarding=$(read_field 'plugin.json:.extensions["com.openai"].onboardingSkill'); then
  [ -f "${onboarding#./}" ] || fail "plugin.json: onboardingSkill points at $onboarding, which does not exist"
else
  status=1
fi

check_same_json "keywords" \
  "plugin.json:.keywords" \
  ".claude-plugin/plugin.json:.keywords" \
  ".cursor-plugin/plugin.json:.keywords" \
  ".codex-plugin/plugin.json:.keywords"

# Codex shows the model at most 240 characters of the description.
if description=$(read_field "plugin.json:.description"); then
  [ "${#description}" -le 240 ] || fail "plugin.json: description is ${#description} characters, over 240"
fi

# Limits from the Codex parser (defaultPrompt) and the OpenAI directory
# (displayName, shortDescription).
interface=plugin.json
jq -e '.extensions["com.openai"].interface | (.displayName | length) <= 30' "$interface" >/dev/null \
  || fail "$interface: interface.displayName is over 30 characters"
jq -e '.extensions["com.openai"].interface | (.shortDescription | length) <= 30' "$interface" >/dev/null \
  || fail "$interface: interface.shortDescription is over 30 characters"
jq -e '.extensions["com.openai"].interface.defaultPrompt | length <= 3' "$interface" >/dev/null \
  || fail "$interface: interface.defaultPrompt has more than 3 prompts"
jq -e '[.extensions["com.openai"].interface.defaultPrompt[] | length <= 128] | all' "$interface" >/dev/null \
  || fail "$interface: an interface.defaultPrompt entry is over 128 characters"

# The Agent Plugins schema allows only these top-level keys; Codex drops the rest.
extra=$(jq -r 'keys - ["$schema","name","version","description","author","homepage","repository","license","keywords","extensions"] | join(", ")' plugin.json)
[ -z "$extra" ] || fail "plugin.json: keys not allowed in an Agent Plugins manifest: $extra"

manifests=(
  plugin.json
  .claude-plugin/plugin.json
  .claude-plugin/marketplace.json
  .cursor-plugin/plugin.json
  .cursor-plugin/marketplace.json
  .codex-plugin/plugin.json
  .agents/plugins/marketplace.json
)

# The plugin no longer serves experiments or the AI Judge.
for file in "${manifests[@]}"; do
  if grep -qiE 'ai[ -]judge|experiment|evaluation' "$file"; then
    fail "$file: mentions a feature the plugin does not serve (AI Judge, experiment or evaluation)"
  fi
done

# Every URL-valued field must use https.
for file in "${manifests[@]}"; do
  while IFS= read -r url; do
    fail "$file: $url is not https"
  done < <(jq -r '.. | strings | select(test("^[a-z][a-z0-9+.-]*://")) | select(startswith("https://") | not)' "$file")
done

if [ "$status" -eq 0 ]; then
  echo "plugin manifests agree"
fi
exit "$status"
