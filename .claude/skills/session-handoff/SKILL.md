---
name: session-handoff
description: Use when finishing a session's work and closing it out — verifying, appending to docs/SESSION-LOG.md, and proposing a commit. Use whenever the user runs /handoff or asks to wrap up.
---

# Session Handoff

## Why the next session starts empty
Each of the 16 sessions in `docs/SESSIONS.md` runs in isolation and reads only
`specs/<current>.md` plus the last `SESSION-LOG` entry (CLAUDE.md "How I work").
Nothing in your context carries forward — only what's written down. A vague
handoff note is a bug the next session inherits silently.

## The four ordered steps — never reorder, never skip one
1. **Verify.** Run `./scripts/verify.sh`. It checks: no `.env` tracked, no
   secret-shaped string, no build output staged, `forge fmt --check`, `forge build`,
   `forge test`, frontend typecheck. If it fails, stop and report — do not commit,
   and do not narrow what verify checks to make it pass.
2. **Commit-guard.** Run the `commit-guard` subagent on the staged diff. It checks
   for secrets, junk files, and scope creep. If it returns BLOCK, stop and tell the
   user — do not commit anyway, and do not silently unstage the flagged file and
   commit the rest without asking.
3. **Log entry.** Append one entry to `docs/SESSION-LOG.md` — append-only, never
   edit or delete an earlier entry, even to "fix" it. That entry belongs to another
   session.
4. **Propose one commit.** Write a single Conventional Commits message. Do not run
   `git commit` until the user approves it — proposing is not committing.

## SESSION-LOG entry format
Match Session 01's structure exactly:
```markdown
## Session NN — <short title> (YYYY-MM-DD)

**Goal:** <one sentence, matches the session's spec>

**Completed:**
- <concrete, past tense, one line per item>

**Exit criteria met:**
- ✅ <criterion from the session's spec, verified not assumed>
- ❌ <criterion NOT met — say so, don't omit it>

**Handoff notes for Session NN+1:**
- <anything the next session must know that isn't obvious from the diff>
```
Bad: "Did the thing, works fine, handoff notes: n/a"
Good: "OpenZeppelin version installed: v5.7.0" — a fact the next session cannot
rediscover without reading `lib/`.

Exit criteria are checked, not assumed — if `forge build` wasn't actually run this
session, the box stays unchecked, even if the code "should" compile.

## Conventional Commits
`<type>(<scope>): <description>`, imperative mood, describes what changed, not what
you did.
Types: `feat`, `fix`, `test`, `docs`, `chore`, `refactor`.
Bad: `updated stuff` / `wip` / `fixed the thing`
Good: `feat(contracts): add issue() with cap-bounded minting`

## Never
- Never commit when `verify.sh` failed — fix it or report it, don't route around it.
- Never commit when commit-guard returns BLOCK, or when a `.env`, keystore, or
  64-hex string is staged.
- Never edit or delete an earlier `SESSION-LOG.md` entry.
- Never run `git commit` without the user's explicit approval of the proposed message.
- Never leave "handoff notes" empty when a real decision was made this session —
  the next session needs the reason, not just the result.
- Never mark an exit criterion met without having actually run the check.
