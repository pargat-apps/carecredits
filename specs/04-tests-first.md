---
id: 04-tests-first
goal: Write the failing acceptance tests from the contract spec, before any implementation
model: sonnet
mode: default
mcp: none
---

# Session 04 — Tests first

## Role

You are the **test author**. You turn the spec's acceptance criteria into Foundry tests.

Every test derives from **the specification**, never from an implementation. Tests
written by reading code validate that code's bugs along with its behaviour. There is no
implementation to read anyway — and you are forbidden from creating one.

**At the end of this session every test will fail. That is the correct outcome.**
Failing tests are the definition of "done" here.

## Isolation rules

- **Write only** inside the OWNS list. If a task needs a path outside it, stop and tell me.
- **Do NOT read or write `contracts/src/`** — except the single stub exception below.
- `specs/contract/carecredits-token.md` is **read-only**. It is your source of truth.
- `docs/SESSION-LOG.md` and `docs/TEST-LOG.md` are append-only.
- Never install a package without asking.

### OWNS
```
contracts/test/unit/**
contracts/src/CareCredits.sol      STUB ONLY — see the exception below
docs/TEST-LOG.md                    (create + append)
docs/SESSION-LOG.md                 (append)
```

### READS
```
CLAUDE.md
specs/contract/carecredits-token.md      primary source
docs/REQUIREMENTS.md                     §4 FR-C-01..24
docs/ARCHITECTURE.md                     §6 contract architecture, §13 invariants
.claude/skills/foundry-test-patterns/    conventions — follow exactly
```

### MUST NOT TOUCH
```
contracts/src/**            any real logic — stub only
contracts/script/**
contracts/test/fuzz/**      Session 06 owns these
contracts/test/invariant/**  Session 06 owns these
frontend/**
specs/**                    read-only
docs/*.md                   except TEST-LOG.md and SESSION-LOG.md
```

---

## ⚠️ The stub exception — read this carefully

Tests import `CareCredits`. If that file does not exist, `forge build` fails with
"file not found" and you get no useful feedback at all — just a missing-file error
instead of real assertion failures.

So you may create **`contracts/src/CareCredits.sol` as a stub, and only as a stub:**

- Correct contract name, imports and inheritance, exactly as the spec defines
- Every function signature from the spec, with correct visibility and modifiers
- Every custom error and event declared
- Constants for the role identifiers
- **Every function body is `revert NotImplemented();`** — nothing else
- One extra error: `error NotImplemented();`
- No state variables beyond what the spec names, no logic, no assignments, no maths

The interface is defined by the spec, not invented by you. You are transcribing it.

Session 05 replaces every stub body with a real implementation. If you write a single
line of working logic, you have taken Session 05's job and broken the isolation.

**Result:** `forge build` passes. `forge test` fails with real reverts you can read.

---

## Tasks

### 1. Read the spec and extract the acceptance criteria table

That table is your work order. One test per row, named exactly as the spec names it.
Report the count.

### 2. Write the stub

Per the exception above. Then `forge build` — it must compile.

### 3. Write the unit tests

`contracts/test/unit/CareCredits.t.sol`

Follow the **foundry-test-patterns** skill exactly. In particular:

- `test_<Function>_<Behaviour>` and `test_<Function>_RevertsWhen_<Condition>`
- Arrange / Act / Assert with a comment marking each part
- `makeAddr("alice")` for actors — never a raw hex address
- `vm.prank` for one call, `vm.startPrank`/`vm.stopPrank` for a sequence
- `vm.expectRevert(Error.selector)` — **always the selector, never a string**
- `vm.expectEmit(true, true, true, true)` immediately before the emitting call
- `setUp()` leaves a clean, documented starting state and labels every actor
- One comment per test saying what a failure would mean in real terms

### 4. Cover all seven categories

Every category must appear, or you must state in writing why it does not apply:

| Category | For this contract |
|---|---|
| Happy path | issue mints, redeem burns, roles grant |
| Validation | zero address, zero amount, zero serviceRef |
| Error semantics | exact custom error selector **and** exact event emitted |
| Edge cases | 0, `type(uint256).max`, cap exactly, cap+1, one wei under cap |
| Auth guard | every function called by every unauthorised role |
| Side effects | assert `balanceOf`, `totalSupply`, **and** the event in the receipt |
| Render states | N/A for the contract — say so |

Plus, specifically for this project:
- `transfer`, `transferFrom` and `approve` each revert with the expected error
- `totalSupply() <= cap()` still holds after every operation
- The deployer holds no `ISSUER_ROLE` after construction

### 5. Organise by concern

Split into readable files rather than one giant one:
```
contracts/test/unit/CareCredits.metadata.t.sol
contracts/test/unit/CareCredits.issue.t.sol
contracts/test/unit/CareCredits.redeem.t.sol
contracts/test/unit/CareCredits.transfers.t.sol
contracts/test/unit/CareCredits.roles.t.sol
contracts/test/unit/CareCredits.constructor.t.sol
```
A shared `contracts/test/unit/BaseTest.t.sol` may hold `setUp` and common actors.

### 6. Run and confirm the right kind of failure

```
forge build      must PASS
forge test       must FAIL
```

Every failure must be `NotImplemented()` or a clean assertion failure. **Zero compile
errors.** If you see a compile error, the stub or the test is wrong — fix it.

Report: total tests, how many fail, and confirm none fail for the wrong reason.

### 7. Create `docs/TEST-LOG.md`

Record: date, test count, the seven-category coverage, and any spec ambiguity you hit.

---

## Exit criteria

- [ ] `forge build` passes
- [ ] `forge test` fails — every failure is `NotImplemented()` or an assertion
- [ ] **Zero compile errors**
- [ ] Every acceptance criterion in the spec has a matching test with the exact name
- [ ] All seven categories covered or explicitly justified
- [ ] Every stub function body is `revert NotImplemented();` and nothing else
- [ ] `docs/TEST-LOG.md` created
- [ ] No fuzz or invariant test written — Session 06 owns those

## Handoff

Append to `docs/SESSION-LOG.md`, then propose:

```
test: add failing acceptance tests from contract spec
```

Tell Session 05: the test count, which files exist, any acceptance criterion you could
not turn into a test, and confirmation that every stub body still reverts.
