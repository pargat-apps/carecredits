# Session 05 — Contract implementation plan

**Goal:** Implement every stub function body in `contracts/src/CareCredits.sol` — constructor,
`_update` override, `approve` override, `issue`, `redeem`, `remainingIssuable` — until all 37
Session-04 tests pass, adding nothing beyond what those tests require.

## Steps

1. Read `specs/contract/carecredits-token.md`, `contracts/test/unit/**`, `docs/ARCHITECTURE.md` §6,
   and the `solidity-house-style` skill; list functions vs. covering tests; run `forge test` for the
   baseline failure count.
2. Use context7 to confirm the OZ 5.x APIs called out in the spec (`_update`, `ERC20Capped`,
   `AccessControl` error names, override signature) and report findings before writing code.
3. Implement the constructor (`ERC20`, `ERC20Capped`, zero-admin check, `_grantRole`) — run tests,
   report deltas.
4. Implement `_update` (mint/burn/transfer-reject) and `approve` (always reverts) — run tests,
   report deltas.
5. Implement `issue` and `redeem` per the spec's validation order and custom errors — run tests,
   report deltas.
6. Implement `remainingIssuable`, delete all `NotImplemented` scaffolding, confirm
   `grep -c NotImplemented` returns 0.
7. Full pass (`forge fmt`, `forge build`, `forge test -vv`), scope-creep check (every function has a
   covering test, nothing extra), then append `docs/SESSION-LOG.md` and propose the commit message.

## Ambiguities flagged before implementation

- Validation order in `issue`/`redeem` when multiple conditions are violated simultaneously — not
  stated in `specs/05-contract-impl.md`; check `contracts/test/unit/**` for an implied order.
- Who ends up holding `ISSUER_ROLE` — the deployer explicitly does not; presumed granted later
  (admin or deploy script), not in this session's constructor.
