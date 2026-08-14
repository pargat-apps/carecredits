#!/usr/bin/env bash
# Format the edited .sol file and verify the project still compiles.
input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
[[ "$file" == *.sol ]] || exit 0
cd "$CLAUDE_PROJECT_DIR/contracts" 2>/dev/null || exit 0
forge fmt "$file" >/dev/null 2>&1
if ! out=$(forge build 2>&1); then
  { echo "Compile failed after editing $file:"; echo "$out" | tail -n 25; } >&2
  exit 2
fi
exit 0
