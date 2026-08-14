---
id: 03-contract-spec
goal: Decide and document every contract rule before any Solidity exists
model: opus
mode: plan
mcp: none
---

# Session 03 — Contract specification

## Role

You are the **specification author**. You settle every rule the contract must obey,
and you write it down in a form that can be tested.

**You write no code this session.** Not Solidity, not tests, not pseudocode. Your output
is a document. Sessions 04 and 05 are both held to it.

You run in **plan mode**: you may read and think, but you cannot write until I approve.

## Isolation rules

- **Write only** to `specs/contract/**` and `docs/SESSION-LOG.md` (append).
- `CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/REQUIREMENTS.md`, `docs/DESIGN-SYSTEM.md`,
  `docs/SESSIONS.md` are **read-only**.
- **Do NOT read `contracts/src/`.** It is empty, and reading an implementation to derive
  a spec is backwards. You specify what SHOULD be true.
- Do not modify `specs/01-*.md` or `specs/02-*.md` — those are other sessions' briefs.

### OWNS
```
specs/contract/**
docs/SESSION-LOG.md      (append)
```

### READS
```
CLAUDE.md
docs/ARCHITECTURE.md     §6 contract architecture, §11 trust boundaries, §18 ADRs
docs/REQUIREMENTS.md     §4 FR-C-01..24, §11 business rules, §13 exclusions, §17 open questions
```

### MUST NOT TOUCH
```
contracts/**
frontend/**
docs/*.md                except SESSION-LOG.md
specs/*.md               the session briefs
```

---

## Decisions I must make in this session

Six open questions block the spec. **Ask me each one, present the trade-off in two or
three lines, give your recommendation, and wait for my answer.** Do not assume.

**D-1 · Token symbol.** Requirements propose `CARE`.
→ Recommendation: accept unless you find a reason not to.

**D-2 · Supply cap.** Requirements propose **10,000,000 CARE** = $10M CAD of outstanding
service liability. Large enough to be realistic for a pilot, small enough that the cap
actually constrains something. **This is immutable once deployed — it cannot be changed.**
→ Recommendation: 10,000,000 with 18 decimals.

**D-3 · Partial redemption.** If a booking costs 35 credits and the recipient has 20,
does `redeem` revert, or burn what is available?
→ Recommendation: **revert.** Partial payment for a completed service creates a debt the
contract cannot represent. Availability is checked off-chain before dispatch.

**D-4 · One funder, many recipients.** Can one funder address fund several parents?
→ Recommendation: **yes, implicitly.** The contract only knows addresses and balances —
it has no concept of a funder. Nothing needs to change. Confirm this is intended.

**D-5 · Who holds `PROVIDER_ROLE` in the demo.** ADR-004 says the operator holds it in
v1, not individual providers, because a malicious provider could over-redeem.
→ Recommendation: **operator only.** Grant one demo provider address as well so the
provider UI has something real to show, and document both in the trust assumptions.

**D-6 · Does `redeem` require a non-zero `serviceRef`?**
→ Recommendation: **yes.** A redemption with no booking reference is unauditable.
Revert with `InvalidServiceRef()` on `bytes32(0)`.

---

## Tasks

### 1. Read the source material
`docs/REQUIREMENTS.md` §4 (FR-C-01 to FR-C-24), §11, §13, §17.
`docs/ARCHITECTURE.md` §6, §7, §11, §18.

Report anything where those two documents disagree. Do not silently pick one.

### 2. Put the six decisions to me
One at a time. Trade-off, recommendation, then wait.

### 3. Write the spec

Use the **spec-writer** subagent. Output: `specs/contract/carecredits-token.md`.

It must cover, at minimum:

**Identity** — name, symbol, decimals, cap, and that the cap is `immutable`

**Roles** — `DEFAULT_ADMIN_ROLE`, `ISSUER_ROLE`, `PROVIDER_ROLE`. For each: exactly what
it may do, and explicitly what it may NOT do.

**Non-transferability** — which functions revert and with which error. Cover `transfer`,
`transferFrom`, `approve`. State that enforcement is via the `_update` override, so any
future path is covered by the same choke point.

**Issuance** — who, bounds, cap enforcement, zero-address and zero-amount rejection,
the event emitted.

**Redemption** — who initiates, the balance check, what is burned, the `serviceRef`
requirement, the event emitted. State the ADR-004 trust assumption plainly.

**Errors** — every custom error named, with its parameters and when it fires.

**Events** — every event with its `indexed` fields and why those fields are indexed.

**Constructor** — parameters, validation, what the deployer does and does not receive.

**Invariants** — the five from ARCHITECTURE §13, each with the assertion that checks it.

**Trust assumptions** — including the completion oracle and the operator's redemption
power. Do not soften these.

**Known limitations** — carried forward from REQUIREMENTS §13 and ARCHITECTURE §19.

**Acceptance criteria** — a table mapping every requirement to a test function name and
one of the seven categories. This table is the contract with Session 04.

### 4. Cross-check against FR-C-01 … FR-C-24

Every one of the 24 contract requirements in `docs/REQUIREMENTS.md` §4 must appear in
your acceptance criteria table. Report any that do not, and why.

### 5. Report open questions

Anything you could not settle. Do not guess. An invented requirement becomes an invented
test and then invented code.

---

## Exit criteria

- [ ] All six decisions answered by me and recorded in the spec
- [ ] `specs/contract/carecredits-token.md` exists, under 200 lines
- [ ] Every FR-C-01…24 requirement appears in the acceptance criteria table
- [ ] Every acceptance criterion has a concrete test function name
- [ ] All seven test categories appear, or their absence is justified in writing
- [ ] Each of the five invariants has an explicit assertion
- [ ] Trust assumptions and known limitations stated without softening
- [ ] **No code written** — no `.sol` file anywhere in the diff

## Handoff

Append to `docs/SESSION-LOG.md`, then propose:

```
docs: add contract specification and acceptance criteria
```

Tell Session 04: the final cap and symbol, the six decisions and how they were settled,
the acceptance-criteria count, and any requirement that could not be turned into a test
name.
