---
name: viem-tx-lifecycle
description: Use when writing any hook or lib function in frontend/src/hooks, frontend/src/lib, or frontend/src/config that reads from or writes to CareCredits.sol — client choice, the write lifecycle, unit conversion, and UI state mapping.
---

# viem Transaction Lifecycle

Applies to `frontend/src/hooks/**`, `frontend/src/lib/**`, `frontend/src/config/**`.

## Two clients, two purposes
| Client | For | Signature | Gas |
|---|---|---|---|
| `publicClient` | `balanceOf`, `cap`, `totalSupply`, `hasRole` | No | No |
| `walletClient` | `issue`, `redeem` | Yes | Yes |

Never call a write client for a read — it works, but ties a free question to a
connected wallet for no reason. Reads use `publicClient` even with no wallet connected.

## The ABI must be `as const`
Bad: `export const careCreditsAbi = [ ... ];`
Good: `export const careCreditsAbi = [ ... ] as const;`
Without `as const`, TypeScript widens the array to `any[]`, so
`writeContract({ functionName: 'issue', args })` cannot check `args` against
`issue`'s parameter types. `as const` is the entire reason to use viem's type
inference — dropping it turns every write into an unchecked runtime string.

## Every write is three steps, and step 1 is never skipped
```
simulateContract  →  walletClient.writeContract  →  waitForTransactionReceipt
```
`simulateContract` rehearses the call with no signature and no gas. If it would
revert, the user finds out **before** paying to sign a doomed transaction. Skipping
to `writeContract` means the first sign of a problem is a transaction the user
already paid for.

## Units — never parseFloat, never mix bigint and number
Contract amounts are `bigint`, 18 decimals. Read `decimals()` from the contract —
never hardcode `18`. Convert only at the UI boundary.
Bad: `const amount = parseFloat(input) * 10 ** 18;`
Good: `const amount = parseUnits(input, decimals); // bigint`
Mixing `bigint` and `number` in one expression throws at runtime — treat that as a
signal you crossed the boundary in the wrong place.

## The five UI states
`idle → simulating → awaiting signature → pending → confirmed`, with `failed`
reachable from any of them (FR-F-08). Every write hook returns one of these five and
nothing else — no bespoke sixth state per feature.

## Errors become plain sentences, never hex
Bad: showing `0xa9059cbb...` or "execution reverted."
Good: decode the custom error in `lib/errors.ts`:
`// InsufficientCredits(uint256 balance, uint256 required)` →
`"That service needs 250 credits. Mom has 120."`
Every error in `docs/ARCHITECTURE.md` §6.7 needs an entry in the error map before a
feature ships. An undecoded revert reaching the UI is a bug, not an edge case.

## The network guard is a security control
Block every write — not just warn — when `chainId` isn't Sepolia's. A write on the
wrong network can silently target the wrong contract at the same address. Check
before `simulateContract` runs, offer a one-click switch.

## Role-gated UI comes from an on-chain read
Bad: `if (env.ISSUER_ADDRESS === account) ...`
Good: `useReadContract({ functionName: 'hasRole', args: [ISSUER_ROLE, account] })`
The frontend is advisory (ARCHITECTURE §11 TB3) — showing the right button to the
right role must be driven by actual chain state, or it drifts the moment a role is
revoked.

## The recipient's app breaks the rule if it does any of this
Per CLAUDE.md's core safety rule, nothing under `frontend/src/pages/senior/**` (or
hooks it calls) may import `walletClient`, trigger a signature request, show a gas
estimate or tx hash, or call `useAccount`/`useConnect`. Chain data for that app comes
from a backend read the operator performs. If you're wiring `simulateContract` into
a senior page, stop — that page is describing the wrong app.

## Never
- Never skip `simulateContract` before a write.
- Never hardcode `18` for decimals.
- Never `parseFloat` a chain value or mix `bigint` with `number`.
- Never show a hex string, selector, or "reverted" to a user.
- Never gate role-specific UI on a hardcoded address instead of `hasRole`.
- Never let a write reach `walletClient` before the network guard has run.
- Never give the recipient a wallet, signature prompt, or gas concept.
