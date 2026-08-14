---
description: Security and code-quality review of a feature, then a final summary
argument-hint: <feature-name>
---
Feature under review: **$ARGUMENTS**

Establish scope first: `git diff main...HEAD --name-only`.
Then run BOTH reviews in parallel — they are independent.

REVIEW A — security-reviewer subagent on the changed files.
REVIEW B — code-quality-reviewer subagent on the same files.

FINAL SUMMARY — output exactly this:

### Code Review Summary — $ARGUMENTS
**Verdict:** SHIP / SHIP WITH FIXES / DON'T SHIP
**Files reviewed:** n · **Not reviewed:** what and why

#### Security
| # | Severity | File:line | Finding | Exploit path |
Critical: n · High: n · Medium: n · Low: n · Info: n

#### Code quality
| # | Priority | File:line | Issue | Suggested change |
Must fix: n · Should fix: n · Nice to have: n

#### Accessibility
Contrast ratios, target sizes, focus, keyboard — with actual numbers.

#### Copy
Any banned jargon found, with the replacement.

**Top 3 to fix before merging**
**One sentence:** would you merge this into main today, yes or no, and why.

Never say the feature is secure. Say what was reviewed and what was not.
