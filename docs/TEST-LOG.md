# Test Log

Append-only. Newest entry at the bottom.

## Session 04 — Tests first (2026-08-14)

**Scope:** Unit tests only, derived from `specs/contract/carecredits-token.md` §15
(AC-01..AC-37, the `unit` suite). AC-38..AC-40 (`script`), AC-41..AC-43 (`fuzz`) and
AC-44..AC-48 (`invariant`) are out of this session's OWNS list and are not attempted
here.

**Test count:** 37 tests across 6 files, matching the 37 acceptance rows exactly
(verified by `forge test --list` against the spec's AC table, name for name).

| File | Tests |
|---|---|
| `CareCredits.metadata.t.sol` | 3 |
| `CareCredits.constructor.t.sol` | 4 |
| `CareCredits.issue.t.sol` | 11 |
| `CareCredits.redeem.t.sol` | 11 |
| `CareCredits.transfers.t.sol` | 3 |
| `CareCredits.roles.t.sol` | 5 |
| **Total** | **37** |

Shared `BaseTest.t.sol` deploys `CareCredits("CareCredits", "CCRD", 100_000_000e18, admin)`
and grants `ISSUER_ROLE`/`PROVIDER_ROLE` to labelled actors (`makeAddr`).

**Category coverage (task 4):**

| Category | Covered by |
|---|---|
| Happy path | AC-01, AC-03, AC-04, AC-09, AC-21 |
| Validation | AC-07, AC-08, AC-22, AC-23, AC-27, AC-29, AC-30 |
| Error semantics | AC-10, AC-13, AC-14, AC-15, AC-28 |
| Edge cases | AC-02, AC-05, AC-31, AC-32, AC-35 |
| Auth guard | AC-06, AC-11, AC-16, AC-17, AC-18, AC-24, AC-25, AC-26, AC-33, AC-34 |
| Side effects | AC-12, AC-19, AC-20, AC-36, AC-37 |
| Render states | N/A — a contract has no UI. Render states are covered by the FR-F/FR-S/FR-P frontend suites, not here (spec §15). |

Plus the three project-specific checks the session brief named: `transfer` /
`transferFrom` / `approve` each revert with their exact error (AC-13/14/15); the cap
invariant is exercised at its exact boundary (AC-35 succeeds at the cap, AC-05 reverts
one wei over); and the deployer holds no `ISSUER_ROLE` after construction (AC-24).

**Stub:** `contracts/src/CareCredits.sol` — correct inheritance
(`ERC20Capped, AccessControl`), every error and event from the spec, `ISSUER_ROLE` /
`PROVIDER_ROLE` constants, every function signature from §4–§11. Every function body
is `revert NotImplemented();`, including the constructor (routed through a private
`_stub()` helper — see ambiguity 1 below). No business logic, no assignments, no
validation.

**Run results:**
- `forge build` — **passes**, zero compile errors.
- `forge fmt --check` — passes.
- `forge test` — **fails**, 0 passed / 6 suites failed. Every one of the 37 named
  tests is confirmed to exist via `forge test --list`; every suite fails identically
  with `[FAIL: NotImplemented()] setUp()`, because the constructor stub reverts
  unconditionally, so no test in this session ever reaches its own body. No test
  fails for the wrong reason (no compile error, no unrelated revert, no
  string-matched assertion).

**Ambiguities / notes for Session 05:**

1. **Solc error 1284 forced one line of indirection in the stub.** A bare
   `revert NotImplemented();` as the constructor's entire body does not compile —
   Solidity 0.8.25 cannot prove `ERC20Capped`'s immutable `cap` is assigned when the
   derived constructor's body is an unconditional `revert` (confirmed with a minimal
   repro contract, isolated from the rest of this file). The constructor body calls a
   one-line private `_stub()` helper that reverts instead. Behaviour is identical —
   construction always reverts `NotImplemented()` — this is a compiler-compatibility
   workaround, not implementation logic. Session 05 removes `_stub()` entirely along
   with every other stub body.
2. **Every test fails at `setUp()`, not at its own assertion.** Because the
   constructor stub reverts unconditionally, `BaseTest.setUp()` never completes, so
   none of the 37 tests ever reach their own `Act`/`Assert` lines this session — all
   37 fail identically with `NotImplemented()`. This is the expected, unavoidable
   consequence of stubbing the constructor per the session brief ("every function
   body is `revert NotImplemented();` — nothing else"). Once Session 05 implements
   the real constructor, each test will exercise its own logic independently for the
   first time.
3. **OQ-A/B/C (spec §16) do not block this session.** All three concern the `script`
   suite (AC-38..40) or `renounceRole`, neither of which is in this session's OWNS
   list (`contracts/test/unit/**` only). No unit test in this file depends on their
   resolution.
