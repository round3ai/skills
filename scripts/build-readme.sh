#!/usr/bin/env bash
# Regenerates the skills table in README.md, between the SKILLS:START and
# SKILLS:END markers, from the frontmatter of every skills/*/SKILL.md.
# Everything outside the markers is hand-written.
#
#   scripts/build-readme.sh          rewrite README.md
#   scripts/build-readme.sh --check  exit 1 if README.md is out of date
#
# The publish workflow runs this after copying the skill directories, so the
# table always matches what ships.
set -euo pipefail

cd "$(dirname "$0")/.."

start='<!-- SKILLS:START -->'
end='<!-- SKILLS:END -->'
readme=README.md

# Prints the single-line value of a top-level frontmatter key, without
# surrounding quotes. Block scalars (">" or "|") are not supported.
frontmatter_field() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit 2 }
    /^---$/ { fence++; next }
    fence == 1 && index($0, key ":") == 1 {
      sub("^" key ":[ ]*", "")
      if ($0 ~ /^[>|]/) exit 3
      if ($0 ~ /^".*"$/ || $0 ~ /^'"'"'.*'"'"'$/) $0 = substr($0, 2, length($0) - 2)
      print
      exit
    }
  ' "$1" || case $? in
    2) echo "$1: does not start with a frontmatter fence" >&2; exit 1 ;;
    3) echo "$1: '$2' uses a block scalar; write it on one line" >&2; exit 1 ;;
    *) exit 1 ;;
  esac
}

rows=""
while IFS= read -r dir; do
  skill="skills/$dir/SKILL.md"
  [ -f "$skill" ] || continue
  name=$(frontmatter_field "$skill" name)
  description=$(frontmatter_field "$skill" description)
  if [ "$name" != "$dir" ]; then
    echo "$skill: name '$name' does not match directory '$dir'" >&2
    exit 1
  fi
  if [ -z "$description" ]; then
    echo "$skill: missing description" >&2
    exit 1
  fi
  summary="${description%%. *}"
  summary="${summary%.}."
  summary="${summary//|/\\|}"
  rows+="| [\`$name\`](skills/$name/SKILL.md) | $summary |"$'\n'
done < <(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | LC_ALL=C sort)

if [ -z "$rows" ]; then
  echo "no skills found under skills/, refusing to write an empty table" >&2
  exit 1
fi

start_line=$(grep -nxF "$start" "$readme" | head -n 1 | cut -d: -f1 || true)
end_line=$(grep -nxF "$end" "$readme" | head -n 1 | cut -d: -f1 || true)
if [ -z "$start_line" ] || [ -z "$end_line" ] || [ "$start_line" -ge "$end_line" ]; then
  echo "$readme needs a $start line followed by a $end line" >&2
  exit 1
fi

block=$(printf '%s\n\n| Skill | What it does |\n| --- | --- |\n%s\n%s' "$start" "$rows" "$end")

generated=$(
  if [ "$start_line" -gt 1 ]; then head -n "$((start_line - 1))" "$readme"; fi
  printf '%s\n' "$block"
  tail -n "+$((end_line + 1))" "$readme"
)

if [ "${1:-}" = "--check" ]; then
  if ! diff -u "$readme" <(printf '%s\n' "$generated"); then
    echo "$readme is out of date; run scripts/build-readme.sh" >&2
    exit 1
  fi
  echo "$readme is up to date"
  exit 0
fi

printf '%s\n' "$generated" > "$readme"
echo "wrote $(printf '%s' "$rows" | grep -c .) skills into $readme"
