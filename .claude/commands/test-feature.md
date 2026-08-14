---
description: Write and run tests for a feature, then give a final summary
argument-hint: <feature-name>
---

Feature under test: **$ARGUMENTS**

Run these two steps in order. Do not skip step 1 even if tests already exist.

## Step 1 — test-writer
Use the **test-writer** subagent.
Give it: the feature name, its spec file, and the list of files changed
(`git diff main...HEAD --name-only`).
It must cover all seven categories: happy path, validation, error semantics,
edge cases, auth guard, side effects, render states.
It writes tests only. It does not run them.

## Step 2 — test-runner
Use the **test-runner** subagent on the tests just written.
It runs them and reports. It changes nothing.

## Final summary — output exactly this

### 🧪 Test Summary — $ARGUMENTS

**Verdict:** ✅ PASS / ❌ FAIL

| Suite | Tests | Passed | Failed | Coverage |
|---|---|---|---|---|

**Coverage of the seven categories**
| Category | Covered | Test |
|---|---|---|
| Happy path | ✅/❌ | |
| Validation | ✅/❌ | |
| Error semantics | ✅/❌ | |
| Edge cases | ✅/❌ | |
| Auth guard | ✅/❌ | |
| Side effects | ✅/❌ | |
| Render states | ✅/❌ | |

**Failures** — name, expected vs actual, root cause, smallest fix
**Gas** — any function that moved more than 2%
**Open questions** — where the spec was ambiguous
**Next action** — one sentence

If any category is ❌, say so plainly. Do not lead with what passed.
Do not proceed to code review while tests are failing.