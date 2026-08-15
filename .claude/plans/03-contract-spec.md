# Session 03 — Contract specification

## Context

Sessions 01 and 02 built the repo skeleton, design tokens, and the six project Skills.
`contracts/src/` is still empty on purpose. Before any Solidity exists, every rule the
CareCredits token must obey has to be settled and written down in a testable form —
otherwise Session 04 (tests) and Session 05 (implementation) each invent their own
version of the truth.

This session produces **one document and nothing else**:
`specs/contract/carecredits-token.md`. No `.sol`, no tests, no pseudocode.
Six blocking decisions (D-1…D-6) must be answered by the user first, because each one
changes what the acceptance-criteria table says, and that table is the binding contract
with Session 04.

Per `specs/03-contract-spec.md`, writes are limited to `specs/contract/**` and an append
to `docs/SESSION-LOG.md`. `contracts/**`, `frontend/**`, all other `docs/*.md`, and the
other session briefs are off limits.

## Plan

1. **Read the source material.**
   `docs/REQUIREMENTS.md` §4 (FR-C-01…24), §11, §13, §17 and `docs/ARCHITECTURE.md`
   §6, §7, §11, §13, §18, §19. Also read `.claude/skills/foundry-test-patterns.md` to
   recover the names of the "seven test categories" the exit criteria demand (the brief
   never lists them). Report every place the two docs disagree — do not silently pick one.

2. **Put the six decisions to the user, one at a time.**
   D-1 symbol · D-2 cap · D-3 partial redemption · D-4 one funder / many recipients ·
   D-5 who holds `PROVIDER_ROLE` · D-6 non-zero `serviceRef`. Two or three lines of
   trade-off, my recommendation, then wait. No assumptions.

3. **Draft the acceptance-criteria table first, and show it before the prose.**
   One row per FR-C-01…24: requirement → test function name → test category. This is the
   highest-risk artifact in the session; getting it reviewed before the document is
   generated is cheaper than regenerating.

4. **Invoke the `spec-writer` subagent** to write `specs/contract/carecredits-token.md`
   (under 200 lines) with the sections the brief mandates: Identity, Roles,
   Non-transferability, Issuance, Redemption, Errors, Events, Constructor, Invariants,
   Trust assumptions, Known limitations, Acceptance criteria.

5. **Cross-check the written document** against: all 24 FR-C requirements present in the
   table; every criterion has a concrete test function name; all seven categories appear
   or their absence is justified in writing; each of the five invariants has an explicit
   assertion; trust assumptions stated without softening.

6. **Report unresolved open questions** rather than guessing. An invented requirement
   becomes an invented test and then invented code.

7. **Hand off.** Use the `session-handoff` skill: append the Session 03 entry to
   `docs/SESSION-LOG.md` (final cap and symbol, the six decisions and how each was
   settled, the acceptance-criteria count, any requirement that resisted a test name),
   then propose the commit `docs: add contract specification and acceptance criteria`.

## Ambiguities flagged before starting

1. The **seven test categories** are never enumerated in the brief — recover them from
   `.claude/skills/foundry-test-patterns.md`, or ask.
2. **Section references contradict the READS allowlist**: READS permits ARCHITECTURE §6,
   §11, §18; Task 1 adds §7; Task 3 cites §13 and §19.
3. The **five invariants** are attributed to ARCHITECTURE §13 but also stated in
   `CLAUDE.md`. If the lists differ, stop and ask — do not merge.
4. **D-5 contradicts itself**: "operator only" plus "grant one demo provider address".
   Also unstated whether the demo grant is a constructor parameter, a deploy-script step,
   or documentation only — which changes the constructor signature.
5. **`_update` does not cover `approve`** in OpenZeppelin 5.x (`approve` routes through
   `_approve`). Specify `_update` as the choke point for value movement *plus* explicit
   reverting overrides on `transfer` / `transferFrom` / `approve`.
6. **`redeem`'s caller and signature are never stated.** `CLAUDE.md` implies a pull —
   operator or provider burning from a recipient's balance, since the parent never signs.
   Confirm from REQUIREMENTS §4 or raise as a decision.
7. **`docs/SESSIONS.md`** is listed read-only but is not in the repo layout — likely a
   stale name for `SESSION-LOG.md`.
8. The **200-line cap** may be tight against 24 acceptance rows plus twelve mandated
   sections. Use terse tables; report rather than drop content if it does not fit.

Minor: D-6 covers `serviceRef` on `redeem` but nothing says whether `issue` needs its own
reference; the proposed commit message is `docs:` while the file lands under `specs/`.

## Verification

- `git status` shows changes only under `specs/contract/` and `docs/SESSION-LOG.md`
- `git diff --name-only` contains no `.sol` file anywhere
- `wc -l specs/contract/carecredits-token.md` is under 200
- Grep the spec for `FR-C-` and confirm 24 distinct identifiers appear in the table
- Every acceptance-criteria row has a test function name in `test_*` / `testFuzz_*` /
  `invariant_*` form matching `.claude/skills/foundry-test-patterns.md`
