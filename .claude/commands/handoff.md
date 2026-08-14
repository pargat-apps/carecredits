---
description: Close out this session — verify, log, and commit
---
Follow the session-handoff skill exactly.

1. Run ./scripts/verify.sh. If it fails, stop and tell me.
2. Use the commit-guard subagent on the staged changes. If BLOCK, stop and tell me.
3. Append a dated entry to docs/SESSION-LOG.md in the skill's format:
   session id and goal · exit criteria MET/NOT MET · files changed with reasons ·
   decisions made and why · known gaps · what the next session must know.
4. Propose ONE Conventional Commit message. Do not commit until I approve.
