---
name: foundry-test-patterns
description: Use when writing or reviewing any Foundry test in contracts/test/unit, contracts/test/fuzz, or contracts/test/invariant — naming, assertions, and how to write a test that can actually fail.
---

# Foundry Test Patterns

Applies to every `.t.sol` file in `contracts/test/unit/`, `contracts/test/fuzz/`,
`contracts/test/invariant/`, `contracts/test/script/`.

## Naming
`test_<Function>_<Behaviour>` for a passing case, `test_<Function>_RevertsWhen_<Condition>`
for a revert.
Bad: `test1`, `testIssue`, `testItWorks`
Good: `test_Issue_MintsCreditsToRecipient`, `test_Issue_RevertsWhen_CallerLacksIssuerRole`
Fuzz tests prefix with `testFuzz_`. Invariant properties prefix with `invariant_`.

## setUp()
Deploy `CareCredits` once, grant roles with `vm.prank(admin)`, create labeled
addresses with `makeAddr(...)`. Never hardcode a raw address like `address(0x123)` —
`makeAddr("recipient")` gives readable trace output and avoids precompile collisions.

## Arrange / Act / Assert
Every test has three commented sections, even when short:
```solidity
function test_Issue_MintsCreditsToRecipient() public {
    // Arrange
    uint256 amount = 300e18;

    // Act
    vm.prank(issuer);
    credits.issue(recipient, amount);

    // Assert
    assertEq(credits.balanceOf(recipient), amount);
}
```

## vm.expectRevert — the selector, never a string
Bad: `vm.expectRevert("insufficient balance");`
Good:
```solidity
vm.expectRevert(abi.encodeWithSelector(CareCredits.InsufficientCredits.selector, 120e18, 250e18));
```
When the exact arguments aren't the point, use at least the bare selector:
`vm.expectRevert(CareCredits.InsufficientCredits.selector);`. A string match breaks
silently the moment wording changes; the selector cannot.

## vm.expectEmit
Declare which fields are checked before the call, then re-emit the exact event:
```solidity
vm.expectEmit(true, true, false, true);
emit CreditsIssued(recipient, amount, issuer);
vm.prank(issuer);
credits.issue(recipient, amount);
```
The four booleans are (topic1, topic2, topic3, data) — match them to which fields
are `indexed`.

## vm.prank vs vm.startPrank
One call: `vm.prank(actor)`. Multiple consecutive calls as the same actor:
`vm.startPrank(actor)` / `vm.stopPrank()`. Never leave a `startPrank` unstopped
across test functions.

## bound(), not vm.assume(), for numeric ranges
Bad:
```solidity
function testFuzz_Issue(uint256 amount) public {
    vm.assume(amount > 0 && amount <= cap);
```
Good:
```solidity
function testFuzz_Issue(uint256 amount) public {
    amount = bound(amount, 1, credits.cap());
```
`vm.assume` discards rejected runs and can exhaust the fuzzer on a narrow range;
`bound` maps every input into range, so every run is used.

## Invariant tests route through a handler
Never let the fuzzer call the contract directly — unbounded random calls revert
instantly and test nothing. Write a handler in `contracts/test/invariant/handlers/`
exposing bounded, realistic actions (`issueBounded`, `redeemBounded`), and target it
with `targetContract(address(handler))`. Track ghost variables in the handler
(`ghost_totalIssued`, `ghost_totalRedeemed`) and assert against them in
`invariant_` functions — this catches drift the handler itself introduces, not just
drift in the contract.

## Every test must be able to fail
Before committing a test, ask: if I comment out the source line this test protects,
does this test go red? If it can't fail, delete it.
Bad: `assertTrue(true);` after a call, with no state assertion.
Good: assert the exact balance, exact `totalSupply()`, and the exact event — not
just "it didn't revert."

## Never
- Never assert only `!reverted` — assert the resulting state.
- Never use `vm.assume` for a numeric range; use `bound()`.
- Never match a revert on a string message.
- Never call the contract directly from an invariant sequence — go through the
  handler.
- Never write a unit test in `contracts/test/fuzz/` or vice versa — the directory
  is the test type's contract with you.
- Never leave a test that passes regardless of what the implementation does.
