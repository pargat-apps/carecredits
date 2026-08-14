#!/usr/bin/env bash
# Block destructive commands and secret-leaking commits.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
branch="$(git branch --show-current 2>/dev/null)"

if [[ "$cmd" =~ git[[:space:]]+push.*(--force|-f([[:space:]]|$)) ]]; then
  echo "BLOCKED: force push is not allowed in this project." >&2; exit 2; fi

if [[ "$cmd" =~ rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f ]]; then
  echo "BLOCKED: rm -rf is not allowed. Remove files individually." >&2; exit 2; fi

if [[ "$cmd" =~ git[[:space:]]+branch[[:space:]]+-D ]]; then
  echo "BLOCKED: -D force-deletes an unmerged branch. Use -d." >&2; exit 2; fi

if [[ "$branch" == "main" && "$cmd" =~ (^|[^a-zA-Z])git[[:space:]]+commit ]]; then
  echo "BLOCKED: direct commit to main. Create a session branch first." >&2; exit 2; fi

if [[ "$cmd" =~ (^|[^a-zA-Z])git[[:space:]]+commit ]]; then
  if git diff --cached --name-only 2>/dev/null | grep -qE '(^|/)\.env($|\.)'; then
    echo "BLOCKED: a .env file is staged. Unstage it before committing." >&2; exit 2; fi
  if git diff --cached -U0 2>/dev/null | grep -qE '0x[a-fA-F0-9]{64}'; then
    echo "BLOCKED: staged diff contains a 64-hex string that looks like a private key." >&2; exit 2; fi
  if git diff --cached --name-only 2>/dev/null | grep -qE '^(contracts/)?(out|cache|broadcast)/'; then
    echo "BLOCKED: build output is staged. These belong in .gitignore." >&2; exit 2; fi
fi
exit 0
