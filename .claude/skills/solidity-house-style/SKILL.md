---
name: solidity-house-style
description: Use when writing or reviewing any Solidity file in contracts/src or contracts/script — layout order, naming, custom errors, events, and the OpenZeppelin 5.x patterns CareCredits requires.
---

# Solidity House Style

Apply this to every `.sol` file in `contracts/src/` and `contracts/script/`.

## Pragma and imports
- Pin the pragma exactly: `pragma solidity 0.8.25;` — never `^0.8.25`, never a range. A
  pinned version compiles identically on every machine and in CI.
- Import by name, never a bare path that pulls the whole file unqualified:
  - Bad: `import "@openzeppelin/contracts/token/ERC20/ERC20.sol";`
  - Good: `import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";`
- Group imports: OpenZeppelin first, then local, one blank line between.

## File layout order, top to bottom
License + pragma → imports → contract NatSpec (`@title`, `@notice`) → errors → events →
state (constants and immutables only — CareCredits has no mutable storage of its own) →
constructor → external/public functions → internal/private functions, `_update`
override last.

## Naming
Contract: `CareCredits`. Roles: `ISSUER_ROLE`, `PROVIDER_ROLE`, `bytes32 public
constant`. Functions: verbs for actions (`issue`, `redeem`), nouns for views
(`remainingIssuable`). Errors: PascalCase, no redundant `Error` suffix
(`ZeroAddress`, `InsufficientCredits`). Never abbreviate a role or function name to
save characters — this contract is read by an interviewer, not just a compiler.

## Custom errors carry UI data
Bad:
```solidity
require(balance >= amount, "insufficient balance");
```
Good:
```solidity
error InsufficientCredits(uint256 balance, uint256 required);
if (balance < amount) revert InsufficientCredits(balance, amount);
```
The frontend decodes `InsufficientCredits(120e18, 250e18)` into "That service needs
250 credits. Mom has 120." A string revert gives the UI nothing to work with.

## Events are past-tense with indexed fields
Bad: `event Issue(address to, uint256 amount);`
Good: `event CreditsIssued(address indexed to, uint256 amount, address indexed issuer);`
Index the address the activity feed filters by (recipient, issuer, provider). Never
index a `uint256` amount — it can't be range-filtered and wastes a topic slot.

## NatSpec
Every `external` and `public` function gets `@notice` and `@param` for each argument.
Internal helpers get NatSpec only when the name doesn't already say what they do.

## OpenZeppelin 5.x — read this before touching a transfer path
v5 removed `_beforeTokenTransfer` / `_afterTokenTransfer`. There is one hook:
`_update(from, to, value)`. Every mint, burn, and transfer passes through it.
Bad (v4 pattern — will not be called on v5, silently):
```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override { ... }
```
Good:
```solidity
function _update(address from, address to, uint256 value) internal override(ERC20Capped) {
    if (from != address(0) && to != address(0)) revert TransfersDisabled();
    super._update(from, to, value); // ERC20Capped enforces the cap on mint
}
```
Always call `super._update` — skipping it silently disables the cap check inherited
from `ERC20Capped`.

## The five invariants this style protects
1. `totalSupply() <= cap()` — never override `_update` without calling `super._update`.
2. Sum of balances == totalSupply — never add a second mint/burn path outside `_update`.
3. Only `ISSUER_ROLE` increases supply — only `issue()` calls `_mint`, gated
   `onlyRole(ISSUER_ROLE)`.
4. A recipient's balance changes only by issue or redeem — `transfer`,
   `transferFrom`, `approve` must revert unconditionally.
5. Redeemed credits are burned, never transferred — `redeem()` calls `_burn`, never
   sends to another address.

## Never
- Never inherit `Ownable` — CareCredits uses `AccessControl` with three named roles
  (ADR-001). One key with all powers is the wrong shape for this product.
- Never inherit `Pausable` — freezing a vulnerable person's access to help has no
  requirement behind it (ADR-002, EX-01).
- Never use a proxy or any upgradeable pattern — immutability is the product's core
  promise (ADR-003, P5).
- Never write inline assembly — nothing here needs it, and it is the easiest way to
  bypass `_update`.
- Never make the cap mutable, or store it outside the `immutable` OpenZeppelin gives
  via `ERC20Capped`.
- Never inherit `ERC20Burnable` — its public `burn()` would let a recipient destroy
  credits with no service received (ADR-005). Call internal `_burn` from `redeem()`.
- Never leave a `require(string)` in new code — use a custom error.
