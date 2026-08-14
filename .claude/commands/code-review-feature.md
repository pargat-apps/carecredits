---
description: Security and code-quality review of a feature, then a final summary
argument-hint: <feature-name>
---

Feature under review: **$ARGUMENTS**

Establish scope first: `git diff main...HEAD --name-only`.
Then run both reviews. They are independent — run them in parallel.

## Review A — security-reviewer
Use the **security-reviewer** subagent on the changed files.
Solidity: access control, state integrity, supply, reentrancy, arithmetic,
input validation, events, MEV, immutability.
Frontend: UI-only security decisions, network guard, simulate-before-write,
secrets in client code, unsanitised input.

## Review B — code-quality-reviewer
Use the **code-quality-reviewer** subagent on the same files.
Conventions, structure, dead code, accessibility, UX copy, test quality.

## Final summary — output exactly this

### 🔍 Code Review Summary — $ARGUMENTS

**Verdict:** ✅ SHIP / ⚠️ SHIP WITH FIXES / ❌ DON'T SHIP

**Files reviewed:** n · **Not reviewed:** (say what and why)

#### 🔒 Security
| # | Severity | File:line | Finding | Exploit path |
|---|---|---|---|---|

Critical: n · High: n · Medium: n · Low: n · Info: n

#### 🧹 Code quality
| # | Priority | File:line | Issue | Suggested change |
|---|---|---|---|---|

Must fix: n · Should fix: n · Nice to have: n

#### ♿ Accessibility
Contrast ratios, target sizes, focus, keyboard — with actual numbers.

#### ✍️ Copy
Any banned jargon found, with the replacement.

**Top 3 things to fix before merging**
1.
2.
3.

**One sentence:** would you merge this into main today, yes or no, and why.

Never say the feature is secure. Say what was reviewed and what was not.