---
description: Write and run tests for a feature, then give a final summary
argument-hint: <feature-name>
---
Feature under test: **$ARGUMENTS**

Run both steps in order. Do not skip step 1 even if tests already exist.

STEP 1 — use the test-writer subagent. Give it the feature name, its spec file, and
`git diff main...HEAD --name-only`. It must cover all seven categories. It writes only.

STEP 2 — use the test-runner subagent on those tests. It runs; it changes nothing.

FINAL SUMMARY — output exactly this:

### Test Summary — $ARGUMENTS
**Verdict:** PASS / FAIL

| Suite | Tests | Passed | Failed | Coverage |

**Seven-category coverage**
| Category | Covered | Test |
Happy path / Validation / Error semantics / Edge cases / Auth guard / Side effects /
Render states — each marked covered or NOT.

**Failures** name, expected vs actual, root cause, smallest fix
**Gas** any function that moved more than 2%
**Open questions** where the spec was ambiguous
**Next action** one sentence

If any category is uncovered, say so plainly. Do not lead with what passed.
Do not proceed to code review while tests are failing.
