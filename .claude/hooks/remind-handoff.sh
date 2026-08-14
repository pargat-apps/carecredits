#!/usr/bin/env bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  count=$(git status --porcelain | wc -l)
  echo "{\"systemMessage\":\"$count uncommitted file(s). Run /handoff before ending this session.\"}"
fi
exit 0
