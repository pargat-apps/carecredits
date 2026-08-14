#!/usr/bin/env bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
echo "=== CareCredits session context ==="
echo "Branch: $(git branch --show-current 2>/dev/null)"
echo "Uncommitted files: $(git status --porcelain 2>/dev/null | wc -l)"
echo "Last commit: $(git log -1 --oneline 2>/dev/null)"
echo
echo "--- Last SESSION-LOG entry ---"
tail -n 20 docs/SESSION-LOG.md 2>/dev/null || echo "(no log yet)"
exit 0
