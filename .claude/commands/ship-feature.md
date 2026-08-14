# `/ship-feature` — the one command

Runs the entire feature lifecycle: branch → spec → design → tasks → build → validate → test → review → verify → commit → push → PR → merge → cleanup.

**Stops at 11 gates and waits for your explicit approval before every single one.**

```bash
/ship-feature add-credits-flow
```

---

## 1. How the gating actually works

Three layers, because a prompt alone is not enforcement.

| Layer | Mechanism | What it guarantees |
|---|---|---|
| **1. The command** | A strict protocol with numbered gates | Claude asks before each phase and summarises what it's about to do |
| **2. Permissions** | `ask` rules in `.claude/settings.json` | Every git write, push, merge and PR command prompts you natively — even if the model forgets |
| **3. Hooks** | `guard-bash.sh` | Force-push, `rm -rf`, and secret-carrying commits are **blocked outright**, not merely questioned |

Layer 1 is politeness. Layers 2 and 3 are the actual controls. Set up all three.

### The approval token

Every gate requires you to reply with the literal word **`GO`**.

Not "ok", not "yes", not "sure". A single unambiguous token means Claude can never mistake a comment for consent.

| You type | Effect |
|---|---|
| `GO` | Proceed to the next phase |
| `FIX <note>` | Stay in this phase and address the note |
| `SKIP` | Skip this phase — only allowed on soft phases |
| `STOP` | Halt. Nothing further runs. |

### Hard stops — `GO` does not override these

1. Any test failing
2. Any Critical or High security finding
3. Any Must-fix quality finding
4. `verify.sh` failing
5. `commit-guard` returning BLOCK
6. A secret detected anywhere

These require a `FIX`. The command refuses to advance.

---

## 2. The command

📁 `.claude/commands/ship-feature.md`

```markdown
---
description: Full feature lifecycle with approval gates at every phase
argument-hint: <feature-name> [--from <phase>]
---

# SHIP FEATURE: $ARGUMENTS

You are running the full feature lifecycle. Follow this protocol exactly.

## PROTOCOL — read before starting

1. Execute ONE phase at a time. Never run two phases in one turn.
2. After each phase, print the GATE BLOCK and STOP. Say nothing after it.
3. Wait for the literal token `GO`. Anything else is not approval:
   - `GO`          proceed
   - `FIX <note>`  stay here, address the note, re-gate
   - `SKIP`        skip (soft phases only — 2, 3, 4)
   - `STOP`        halt immediately
4. HARD STOPS cannot be passed with GO. If one triggers, say so plainly,
   explain what must change, and wait for a FIX:
   - any failing test
   - any Critical or High security finding
   - any Must-fix quality finding
   - verify.sh failing
   - commit-guard returning BLOCK
   - any secret detected
5. Before any command that changes state, show the exact command first.
6. Record progress in docs/features/<name>/PROGRESS.md after every phase, so
   this survives /clear or a crash. Resume with --from <phase>.
7. If `--from <phase>` is given, skip straight to that phase.

## GATE BLOCK — print exactly this after every phase

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GATE n/11 — <phase name>
✅ Done:   <what just happened, 1–3 lines>
📋 Next:   <the exact next phase and commands>
⚠️  Risk:  <what could go wrong, or "none">
🔴 Blockers: <hard stops, or "none">

Reply GO · FIX <note> · SKIP · STOP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## PHASE 0 — Preflight (read-only, no changes)

Run and report:
  git status --porcelain
  git branch --show-current
  git log -1 --oneline
  git fetch origin --dry-run

Check:
- Working tree clean? If not, STOP and tell me what is uncommitted.
- On `main`? If not, ask whether to switch.
- Feature name valid? lowercase-with-hyphens, no spaces.
- Does branch feature/<name> already exist? If so, offer to resume.

Print the full 11-phase plan for this feature so I can see the whole path.
GATE 0.

## PHASE 1 — Branch

  git pull origin main
  git checkout -b feature/<name>
  mkdir -p docs/features/<name>
  (create PROGRESS.md with the phase checklist)

GATE 1.

## PHASE 2 — Spec  [soft]

Use the **spec-writer** subagent. Output specs/feature-<name>.md containing:
- Goal in one sentence
- In scope / out of scope
- Numbered functional requirements, each independently testable
- Security requirements and trust assumptions
- Acceptance criteria written AS TEST NAMES
- Open questions needing a human decision

Read docs/ARCHITECTURE.md first and stay consistent with it.
Print the spec in full. Do not write code.
GATE 2.

## PHASE 3 — Design  [soft]

No code. Answer:
- Which layer does this touch — contract, frontend, off-chain, or several?
- What changes on-chain? What deliberately stays off-chain, and why?
- New state, roles, events or errors?
- Does anything in docs/ARCHITECTURE.md need updating? Show the diff.
- Does this break any of the five invariants? Name each and say why not.
- What is the simplest version that satisfies the spec?

GATE 3.

## PHASE 4 — Tasks  [soft]

Break the work into an ordered list. Each task: one file, one concern,
independently verifiable. Estimate each. Flag risky ones.
GATE 4.

## PHASE 5 — Build

Implement in the smallest increments that compile. After each increment:
- state what you changed and why
- the sol-format-build and ts-typecheck hooks run automatically
- report compile status

Rules:
- Follow the solidity-house-style and viem-tx-lifecycle skills
- Add NOTHING the spec did not ask for
- Never modify a test to make code pass
- Explain each block before writing it
- Never install a package without asking

GATE 5.

## PHASE 6 — Validate

  cd contracts && forge fmt --check && forge build
  cd frontend && npx tsc --noEmit

Report each as pass/fail. Any failure is a HARD STOP.
GATE 6.

## PHASE 7 — Test  🔴 hard gate

Step A — use the **test-writer** subagent. All seven categories:
  happy path · validation · error semantics · edge cases · auth guard ·
  side effects · render states
Plus, where relevant: non-transferability, cap invariant, bigint/decimals,
accessibility, copy rules.

Step B — use the **test-runner** subagent. It runs; it changes nothing.

Then print the /test-feature summary format:
  verdict · suite table · seven-category coverage table · failures with root
  cause · gas deltas · open questions

HARD STOP if anything failed or any category is ❌.
GATE 7.

## PHASE 8 — Review  🔴 hard gate

Establish scope: git diff main...HEAD --name-only

Run BOTH in parallel:
- **security-reviewer** subagent
- **code-quality-reviewer** subagent

Print the /code-review-feature summary format:
  verdict · security findings table · quality findings table · accessibility
  with real contrast numbers · copy violations · top 3 fixes

HARD STOP on any Critical, High, or Must-fix.
GATE 8.

## PHASE 9 — Verify, log and commit  🔴 hard gate

1. ./scripts/verify.sh — any failure is a HARD STOP
2. **commit-guard** subagent on the staged diff — BLOCK is a HARD STOP
3. Append the SESSION-LOG entry per the session-handoff skill
4. Update docs/features/<name>/PROGRESS.md
5. Show `git status` and `git diff --cached --stat`
6. Propose ONE Conventional Commit message

Show the exact commit command. Do NOT run it until I approve.
GATE 9.

## PHASE 10 — Push and PR

Show, then run on approval:
  git push -u origin feature/<name>

Then create the PR. If `gh` is available:
  gh pr create --title "<type>: <summary>" --body-file <generated>

PR body must include: what changed, why, test summary, review summary,
known limitations, and a testnet-only note. Print it before creating.

If `gh` is unavailable, print the compare URL for me to open manually.
Report the PR URL and CI status.
GATE 10.

## PHASE 11 — Merge and clean up

Confirm CI is green first. If not, STOP.

Show, then run on approval:
  gh pr merge <n> --squash --delete-branch
  git switch main
  git pull origin main
  git branch -d feature/<name>

Confirm: on main, clean tree, branch gone, feature present in main.

## FINAL REPORT

### 🚢 Shipped — <name>
| Phase | Status | Notes |
(all 11 rows)

**Commit:** <sha> <message>
**PR:** <url>
**Tests:** n passed · coverage x%
**Security:** n findings — all resolved
**Gas:** any function that moved >2%
**Known limitations:** carried into docs/SECURITY-REVIEW.md
**Follow-ups:** anything deferred

Never say the feature is secure. Say what was reviewed and what was not.
```

---

## 3. Permission rules — the real enforcement

Add the `ask` block to `.claude/settings.json`. This makes Claude Code itself prompt you for every state-changing git command, independently of whether the model remembers to.

```json
{
  "permissions": {
    "ask": [
      "Bash(git checkout:*)",
      "Bash(git switch:*)",
      "Bash(git branch:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git merge:*)",
      "Bash(git pull:*)",
      "Bash(git rebase:*)",
      "Bash(git reset:*)",
      "Bash(gh pr:*)",
      "Bash(gh release:*)",
      "Bash(npm install:*)",
      "Bash(npm i:*)",
      "Bash(forge install:*)",
      "Bash(forge script:*)",
      "Bash(cast send:*)",
      "Bash(cast wallet:*)"
    ],
    "allow": [
      "Bash(forge build)",
      "Bash(forge test:*)",
      "Bash(forge fmt:*)",
      "Bash(forge coverage:*)",
      "Bash(forge snapshot:*)",
      "Bash(cast call:*)",
      "Bash(anvil:*)",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git fetch:*)",
      "Bash(npm run:*)",
      "Bash(npx tsc:*)",
      "Bash(npx vitest:*)"
    ],
    "deny": [
      "Read(./design/**/code.html)",
      "Read(./design/**/*.png)",
      "Read(./contracts/.env)",
      "Read(./frontend/.env.local)",
      "Read(./contracts/lib/**)",
      "Read(./**/out/**)",
      "Read(./**/cache/**)",
      "Read(./**/node_modules/**)"
    ]
  }
}
```

**Read the shape of that:**

- `allow` — read-only and test commands. No prompt, because they change nothing and prompting 40 times a session trains you to click yes without reading.
- `ask` — anything that changes git state, spends gas, or installs software. Always prompts.
- `deny` — never, no prompt offered.

Note `cast send` and `forge script` are in `ask`. Those spend gas. Note `cast call` is in `allow` — it's a free read.

---

## 4. Extra hook — protect `main`

Add to `guard-bash.sh`. Blocks the two mistakes that are genuinely hard to undo.

```bash
# --- append inside guard-bash.sh, before the final exit 0 ---

branch="$(git branch --show-current 2>/dev/null)"

# No direct commits to main
if [[ "$branch" == "main" && "$cmd" =~ (^|[^a-zA-Z])git[[:space:]]+commit ]]; then
  echo "BLOCKED: direct commit to main. Create a feature branch first." >&2
  exit 2
fi

# No pushing main from a local machine
if [[ "$branch" == "main" && "$cmd" =~ git[[:space:]]+push ]]; then
  echo "BLOCKED: pushing main directly. Merge through a PR." >&2
  exit 2
fi

# No deleting a branch that has not been merged
if [[ "$cmd" =~ git[[:space:]]+branch[[:space:]]+-D ]]; then
  echo "BLOCKED: -D force-deletes an unmerged branch. Use -d." >&2
  exit 2
fi
```

---

## 5. The progress file

Written after every phase so the run survives `/clear`, a crash, or you going to bed.

📁 `docs/features/<name>/PROGRESS.md`

```markdown
# Feature: add-credits-flow
Branch: feature/add-credits-flow
Started: 2026-08-14

| Phase | Status | Timestamp | Notes |
|---|---|---|---|
| 0 Preflight | ✅ | 09:12 | clean tree, on main |
| 1 Branch    | ✅ | 09:14 | branch created |
| 2 Spec      | ✅ | 09:31 | specs/feature-add-credits-flow.md |
| 3 Design    | ✅ | 09:40 | no architecture change |
| 4 Tasks     | ✅ | 09:45 | 6 tasks |
| 5 Build     | 🔄 | —     | 4/6 tasks done |
| 6 Validate  | ⬜ | | |
| 7 Test      | ⬜ | | |
| 8 Review    | ⬜ | | |
| 9 Verify    | ⬜ | | |
| 10 Push/PR  | ⬜ | | |
| 11 Merge    | ⬜ | | |

## Decisions
- Credits denominated in the token's 18 decimals; UI converts at the edge

## Open questions
- Should a partial redemption be allowed? Deferred to v2.
```

**Resume after a break:**

```bash
/ship-feature add-credits-flow --from 5
```

---

## 6. Prerequisites

```bash
# GitHub CLI, for the PR steps
sudo apt install -y gh
gh auth login          # choose HTTPS, authenticate in browser
gh auth status         # confirm

# jq, for the hooks
sudo apt install -y jq
```

If you'd rather not use `gh`, the command falls back to printing a compare URL you open yourself. Phases 10 and 11 then become manual — everything before them is unaffected.

---

## 7. What a run looks like

```
you  ▸ /ship-feature add-credits-flow

CC   ▸ PHASE 0 — Preflight
       Tree clean · on main · up to date with origin
       Plan: 11 phases, ~2h
       ━━━ GATE 0/11 — Preflight ━━━
       ✅ Done: preflight checks passed
       📋 Next: git pull origin main; git checkout -b feature/add-credits-flow
       ⚠️  Risk: none
       🔴 Blockers: none
       Reply GO · FIX <note> · SKIP · STOP

you  ▸ GO
       [Claude Code prompts natively for `git checkout` — you approve]

CC   ▸ PHASE 1 complete → GATE 1/11

you  ▸ GO

CC   ▸ PHASE 2 — Spec  (spec-writer subagent)
       [prints the full spec]
       ━━━ GATE 2/11 ━━━

you  ▸ FIX the cap check should reject exactly at cap, not above

CC   ▸ [revises] → GATE 2/11 again

you  ▸ GO
       ...

CC   ▸ PHASE 7 — Test
       ❌ FAIL — 11 passed, 1 failed
       test_Issue_RevertsWhen_AmountExceedsCap
         expected CapExceeded(500, 120), got CapExceeded(500, 121)
         Root cause: CODE — off-by-one in remainingIssuable()
       🔴 HARD STOP. GO will not advance this phase.

you  ▸ FIX correct the off-by-one

CC   ▸ [fixes, re-runs] ✅ 12 passed → GATE 7/11
```

---

## 8. Install checklist

- [ ] `.claude/commands/ship-feature.md`
- [ ] `ask` block added to `.claude/settings.json`
- [ ] `main`-protection rules appended to `.claude/hooks/guard-bash.sh`
- [ ] `gh` installed and authenticated
- [ ] `jq` installed
- [ ] `mkdir -p docs/features`
- [ ] Restart Claude Code (settings and hooks load at startup)
- [ ] Dry run: `/ship-feature test-run` → reply `STOP` at Gate 0
- [ ] Commit: `chore: add ship-feature workflow command with approval gates`

---

## 9. Two things to be honest about

**The command is a protocol, not a sandbox.** It tells Claude to ask. What *guarantees* it asks is the `ask` permission list and the hooks. Set up all three layers, or you have politeness where you wanted a control.

**Don't let `GO` become a reflex.** The whole value is in reading the gate block before you type it. Eleven gates you skim are worse than three you actually read — they give you the feeling of oversight without the substance. If you catch yourself typing `GO` without reading, move the soft phases (2, 3, 4) to `SKIP` and keep your attention for the hard gates: 7, 8, and 9.
