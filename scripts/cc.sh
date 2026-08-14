#!/usr/bin/env bash
# Launch a Claude Code session bound to a single spec.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ $# -lt 1 ]]; then
  echo "usage: ./scripts/cc.sh <session-id>"
  echo
  echo "Available sessions:"
  for f in specs/*.md; do
    [[ -e "$f" ]] || continue
    id="$(basename "$f" .md)"
    goal="$(grep -m1 '^goal:' "$f" 2>/dev/null | cut -d: -f2- | xargs || true)"
    printf "  %-24s %s\n" "$id" "$goal"
  done
  exit 1
fi

SESSION="$1"
SPEC="specs/${SESSION}.md"
[[ -f "$SPEC" ]] || { echo "error: no spec at $SPEC" >&2; exit 1; }

MODEL="$(grep -m1 '^model:' "$SPEC" | cut -d: -f2- | xargs || echo sonnet)"
MODE="$(grep  -m1 '^mode:'  "$SPEC" | cut -d: -f2- | xargs || echo default)"
GOAL="$(grep  -m1 '^goal:'  "$SPEC" | cut -d: -f2- | xargs || echo '')"
MCP="$(grep   -m1 '^mcp:'   "$SPEC" | cut -d: -f2- | xargs || echo none)"

BRANCH="session/${SESSION}"
git rev-parse --verify "$BRANCH" >/dev/null 2>&1 \
  && git switch "$BRANCH" \
  || git switch -c "$BRANCH"

echo "──────────────────────────────────────────────"
echo " SESSION : $SESSION"
echo " GOAL    : $GOAL"
echo " MODEL   : $MODEL"
echo " MODE    : $MODE"
echo " MCP     : $MCP"
echo " BRANCH  : $BRANCH"
echo "──────────────────────────────────────────────"
echo

ARGS=( --model "$MODEL" )
[[ "$MODE" == "plan" ]] && ARGS+=( --permission-mode plan )

exec claude "${ARGS[@]}" \
"Read @CLAUDE.md, @${SPEC}, and the LAST entry only of @docs/SESSION-LOG.md.

Do NOT read any other file yet.

Then give me:
1. The goal of this session in one sentence
2. A numbered plan, max 7 steps
3. Anything in the spec that is ambiguous

Wait for my approval before writing anything."
