---
id: 05-contract-impl
goal: Implement CareCredits.sol until every existing test passes, and nothing more
model: sonnet
mode: default
mcp: context7
---

# Session 05 — Contract implementation

## Role

You are the **contract implementer**. You replace every stub body in
`contracts/src/CareCredits.sol` with real logic, until every test written in Session 04
passes.

**You add nothing the tests do not require.** No convenience helper, no getter nobody
asked for, no "might be useful later." Every extra function is extra attack surface,
extra gas, and one more thing to defend in an interview.

## Teaching requirement — this matters more than speed

I am learning Solidity. Before you write each block, explain in plain language:

1. What it does
2. Why it is written this way rather than an obvious alternative
3. Which operation reads state, which writes state, and which costs gas
4. Anything an auditor would look at twice

Do not write a block I have not understood. If I ask a question, answer it before
continuing.

## Isolation rules

- **Write only** to `contracts/src/CareCredits.sol` and the append-only logs.
- **NEVER modify a test.** If a test looks wrong, stop and tell me. Do not touch it.
- `specs/contract/carecredits-token.md` is read-only and authoritative.
- Never install a package without asking.

### OWNS
```
contracts/src/CareCredits.sol
docs/SESSION-LOG.md      (append)
```

### READS
```
CLAUDE.md
specs/contract/carecredits-token.md      the source of truth
contracts/test/unit/**                    what you must satisfy
docs/ARCHITECTURE.md                      §6
.claude/skills/solidity-house-style/      conventions — follow exactly
```

### MUST NOT TOUCH
```
contracts/test/**        ANY test file, for any reason
contracts/script/**
frontend/**
specs/**
docs/*.md                except SESSION-LOG.md
```

---

## ⚠️ Verify the OpenZeppelin 5.x API before writing

Use **context7** to confirm the current API. Do not write from memory. Specifically
confirm:

- `_update(address from, address to, uint256 value)` is the single balance hook.
  **`_beforeTokenTransfer` was REMOVED in v5** — any tutorial using it is for v4.
- `ERC20Capped` — its constructor, its `cap()` getter, and its exact error name
- `AccessControl` — `_grantRole` vs `grantRole`, and the v5 unauthorised error name
- The override signature required when combining `ERC20Capped` with a custom `_update`

Report what you confirmed before writing any code.

---

## Tasks — implement in this order, running tests after each

### 1. Read the spec and the tests

List the functions to implement and which tests cover each. Report the current failure
count as your baseline.

### 2. Constructor and metadata

Wire up `ERC20(name, symbol)` and `ERC20Capped(cap)`. Validate the admin address is not
zero. Grant `DEFAULT_ADMIN_ROLE` to the admin.

⚠️ Use `_grantRole` in the constructor, not `grantRole` — the public one has an
`onlyRole` check that nobody can satisfy during construction.

Confirm the deployer receives **no** `ISSUER_ROLE`.

Run tests. Report which now pass.

### 3. The `_update` override — the heart of the contract

This is the most important block in the project. Explain it thoroughly.

```
_update(from, to, value)
   from == address(0)  -> MINT     -> allow, ERC20Capped checks the cap
   to   == address(0)  -> BURN     -> allow
   otherwise           -> TRANSFER -> revert TransfersDisabled()
```

Then call `super._update(...)` so `ERC20Capped`'s cap check still runs.

Explain to me **why the hook and not the functions**: overriding `transfer` alone leaves
`transferFrom` open. `_update` is the single choke point every balance change passes
through, so one override covers both — and any path OpenZeppelin adds later.

Run tests. The transfer tests should now pass.

### 4. `approve` override

Revert with `ApprovalsDisabled()`. Explain why an allowance that can never be spent is
worse than no allowance at all.

### 5. `issue`

`onlyRole(ISSUER_ROLE)` · reject zero address · reject zero amount · `_mint` ·
emit `CreditsIssued`.

The cap check is inherited — do not write your own. Explain why reusing audited code
beats hand-rolling it here.

### 6. `redeem`

`onlyRole(PROVIDER_ROLE)` · reject zero amount · reject `bytes32(0)` serviceRef ·
check the balance and revert with `InsufficientCredits(balance, required)` on shortfall
· `_burn` · emit `CreditsRedeemed`.

**All-or-nothing** — no partial redemption. Explain why a partial burn would put the
contract in a state it cannot represent.

### 7. `remainingIssuable`

`cap() - totalSupply()`. A view function. Explain why it costs no gas when called
off-chain but does cost gas if another contract calls it.

### 8. Remove the stub scaffolding

Delete `error NotImplemented();` and every remaining `revert NotImplemented();`.

```
grep -c "NotImplemented" contracts/src/CareCredits.sol
```
Must return **0**.

### 9. Full pass

```
forge fmt
forge build
forge test -vv
```

All green. Report the count.

### 10. Check for scope creep

List every function in the contract. For each, name the test that exercises it.
**Any function with no test should not exist** — delete it or tell me why it must stay.

---

## Exit criteria

- [ ] `forge build` passes
- [ ] `forge test` — **all tests green**
- [ ] `grep -c NotImplemented contracts/src/CareCredits.sol` returns 0
- [ ] No test file modified — confirm with `git diff --stat contracts/test/`
- [ ] Every function in the contract is exercised by at least one test
- [ ] No function exists that the spec did not require
- [ ] `forge fmt --check` clean
- [ ] I understood each block as it was written

## Handoff

Append to `docs/SESSION-LOG.md`, then propose:

```
feat: implement CareCredits capped credit token with role-based issuance
```

Tell Session 06: the final function list, the OpenZeppelin version and which APIs you
confirmed, anything in the spec that was ambiguous during implementation, and which
parts of the contract you consider highest risk for the invariant tests to probe.
