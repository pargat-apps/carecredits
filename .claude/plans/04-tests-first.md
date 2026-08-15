# Session 04 — Tests first

## Context

Session 03 produced `specs/contract/carecredits-token.md`: 48 acceptance criteria
(AC-01..AC-48), of which AC-01..AC-37 are the `unit` suite and belong to this session.
AC-38..AC-40 (`script`), AC-41..AC-43 (`fuzz`) and AC-44..AC-48 (`invariant`) belong to
later sessions. No `.sol` file exists anywhere in the repo yet.

Per `specs/04-tests-first.md`, this session writes the 37 unit tests before any real
implementation exists, plus a single stub `contracts/src/CareCredits.sol` whose only
job is to make the tests compile — every function body reverts `NotImplemented()`.
Writes are limited to `contracts/test/unit/**`, the stub file itself, and appends to
`docs/TEST-LOG.md` / `docs/SESSION-LOG.md`. `contracts/script/**`,
`contracts/test/{fuzz,invariant}/**`, `frontend/**`, and every other file under
`specs/` and `docs/` are off limits.

## Plan

1. **Read the source material.** `specs/contract/carecredits-token.md` (primary),
   `docs/REQUIREMENTS.md` §4, `docs/ARCHITECTURE.md` §6/§13, and the
   `foundry-test-patterns` skill. Extract the 37-row unit slice of the acceptance
   table as the literal work order — one test per row, named exactly as the spec
   names it.
2. **Write the stub.** `contracts/src/CareCredits.sol`: correct inheritance
   (`ERC20Capped`, `AccessControl`), every custom error and event, `ISSUER_ROLE` /
   `PROVIDER_ROLE` constants, every function signature from §4–§11 — every body
   `revert NotImplemented();`, nothing else. Run `forge build` until it compiles.
3. **Write the 37 unit tests**, split by concern into six files
   (`CareCredits.{metadata,constructor,issue,redeem,transfers,roles}.t.sol`) plus a
   shared `BaseTest.t.sol` for `setUp()` and labelled actors, following
   `foundry-test-patterns` exactly: `test_<Function>_<Behaviour>` naming,
   Arrange/Act/Assert comments, `vm.expectRevert` on the selector, `vm.expectEmit`
   immediately before the emitting call, `makeAddr` for every actor.
4. **Cover all seven categories** (happy path, validation, error semantics, edge
   cases, auth guard, side effects, render states — the last justified as N/A, a
   contract has no UI) plus the three project-specific checks: `transfer` /
   `transferFrom` / `approve` each revert their exact error; the cap boundary is
   tested exactly (cap succeeds, cap+1 reverts); the deployer holds no
   `ISSUER_ROLE`.
5. **Run and confirm the right kind of failure.** `forge build` must pass with zero
   compile errors; `forge test` must fail, and every failure must be
   `NotImplemented()` or a clean assertion — never a compile error, never a
   string-matched revert.
6. **Create `docs/TEST-LOG.md`**: date, test count, the seven-category coverage
   table, and any spec ambiguity hit along the way.
7. **Hand off.** Append the Session 04 entry to `docs/SESSION-LOG.md` (test count,
   which files exist, confirmation every stub body still reverts, anything Session
   05 needs to know), then propose the commit
   `test: add failing acceptance tests from contract spec`.

## Ambiguities flagged before starting

1. **OQ-A/B/C (spec §16)** looked like they might block this session — OQ-A names
   the concrete operator/demo-provider addresses AC-40 needs, OQ-B asks whether
   `renounceRole` gets its own row, OQ-C asks about dual-role holders. Resolved by
   re-reading scope: all three concern the `script` suite or `renounceRole`, and
   `contracts/test/script/**` is not in this session's OWNS list (only
   `contracts/test/unit/**` is) — so none of the 37 unit tests depend on them.
2. **Whether "every function body is `revert NotImplemented();`" includes the
   constructor.** The stub exception's own wording is unambiguous (constructor is
   listed among "every function signature from the spec"), so yes — but this
   turned out to have a real consequence, see below.

## Ambiguities discovered while executing

1. **Solc 0.8.25 error 1284.** A bare `revert NotImplemented();` as the entire
   constructor body does not compile: Solidity cannot prove the inherited
   `ERC20Capped` immutable `cap` is assigned when the derived constructor
   unconditionally reverts. Confirmed with an isolated minimal repro (an empty
   constructor body compiles; a bare `revert()` of any kind does not; `assert(false)`
   does; a call to a private helper that reverts does). Fixed by routing the
   constructor's revert through a one-line private `_stub()` helper — identical
   observable behaviour, zero added logic, purely a compiler-compatibility shim.
2. **Because the constructor always reverts, `BaseTest.setUp()` never completes.**
   All 37 tests therefore fail identically with `[FAIL: NotImplemented()] setUp()`
   rather than at their own Act/Assert lines. This is the unavoidable, expected
   consequence of stubbing the constructor per the brief, not a defect in the
   tests — it resolves itself the moment Session 05 implements a working
   constructor.

## Verification

- `forge build` exits 0, zero compile errors — confirmed
- `forge fmt --check` passes — confirmed
- `forge test --list` shows exactly 37 test functions, names matching AC-01..AC-37
  from the spec table one-for-one — confirmed
- `forge test` fails: 0 passed, 6 suites failed, every failure `NotImplemented()`,
  none for the wrong reason — confirmed
- `git status` shows changes only under `contracts/src/`, `contracts/test/`,
  `docs/TEST-LOG.md` — confirmed
- `docs/TEST-LOG.md` exists with test count, category table, and both ambiguities
  above — confirmed
