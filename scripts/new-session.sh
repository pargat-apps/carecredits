#!/usr/bin/env bash
# Scaffold a new session spec from a template.
# usage: ./scripts/new-session.sh <session-id> "<one line goal>"
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ $# -lt 1 ]]; then
  echo "usage: ./scripts/new-session.sh <session-id> \"<goal>\""
  echo
  echo "Existing sessions:"
  for f in specs/*.md; do
    [[ -e "$f" ]] || continue
    printf "  %s\n" "$(basename "$f" .md)"
  done
  exit 1
fi

ID="$1"
GOAL="${2:-TODO: one line goal}"
SPEC="specs/${ID}.md"

if [[ -f "$SPEC" ]]; then
  echo "error: $SPEC already exists" >&2
  exit 1
fi

cat > "$SPEC" <<TEMPLATE
---
id: ${ID}
goal: ${GOAL}
model: sonnet
mode: default
mcp: none
---

# Session ${ID}

## Role

TODO one paragraph: what this session is responsible for, and what it explicitly is not.

## Isolation rules

- **Write only** inside the OWNS list. If a task needs a path outside it, stop and tell me.
- \`docs/SESSION-LOG.md\` is append-only.
- \`CLAUDE.md\`, \`docs/ARCHITECTURE.md\`, \`docs/REQUIREMENTS.md\` are read-only.
- Never install a package without asking.

### OWNS
\`\`\`
TODO
docs/SESSION-LOG.md      (append)
\`\`\`

### READS
\`\`\`
CLAUDE.md
TODO
\`\`\`

### MUST NOT TOUCH
\`\`\`
TODO
\`\`\`

---

## Tasks

### 1. TODO

---

## Exit criteria

- [ ] TODO
- [ ] Nothing outside the OWNS list was modified

## Handoff

Append to \`docs/SESSION-LOG.md\`, then propose:

\`\`\`
type: TODO conventional commit message
\`\`\`

Tell the next session: TODO what it needs to know.
TEMPLATE

echo "Created $SPEC"
echo "Edit it, then run:  ./scripts/cc.sh ${ID}"
