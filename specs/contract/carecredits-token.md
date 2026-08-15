# Spec — CareCredits token contract

## 1. Goal
Specify a capped, non-transferable ERC-20 credit token whose supply only an `ISSUER_ROLE` can increase and whose balances only a `PROVIDER_ROLE` can burn against an off-chain booking reference.
## 2. Scope
**In:** identity and cap · three roles · `issue` · `redeem` · `remainingIssuable` · non-transferability · custom errors · two custom events · constructor validation · the five invariants · deploy-script role assertions.
**Out (REQUIREMENTS §13, contract-touching):** EX-01 `Pausable` · EX-02 `Ownable` · EX-03 upgradeable proxy · EX-04 recipient-initiated transfers · EX-05 cash redemption · EX-06 `ERC20Burnable` public burn · EX-07 secondary market. Also out: EIP-2612 permit, allowances of any kind, expiry, fee-on-transfer, batch issue.
**Deferred to v2:** EIP-712 recipient-authorised redemption · per-provider redemption limits · on-chain dispute window · timelock or multisig on role grants.
## 3. Decisions (settled by the user, Session 03)
| ID | Decision | Rationale |
|---|---|---|
| D-1 | Symbol **CCRD** (not `CARE`), name `CareCredits`, 18 decimals | Chosen by the user in Session 03, superseding FR-C-01; 18 decimals per ASM-04 |
| D-2 | Cap **100,000,000 CCRD**, constructor arg `100_000_000e18`, immutable via `ERC20Capped` | Chosen by the user in Session 03 over the 10,000,000 proposed in OQ-02; see §14.7 for what this costs |
| D-3 | Partial redemption **reverts, all-or-nothing** | Partial payment creates a debt the contract cannot represent; availability is checked off-chain before dispatch |
| D-4 | One funder, many recipients: **yes, implicitly** | The contract has no funder concept — it knows only addresses and balances |
| D-5 | `PROVIDER_ROLE`: **operator address + exactly one labelled demo-provider address**, both granted by the deploy script | ADR-004; the provider UI needs one real holder |
| D-6 | `serviceRef` **required non-zero**; `redeem` reverts `InvalidServiceRef()` on `bytes32(0)` | A redemption with no booking reference is unauditable |
| D-7 | Insufficient balance on redeem: **explicit pre-check reverting `InsufficientCredits(balance, required)`**, not inherited `ERC20InsufficientBalance` | The frontend decodes it into "That service needs 250 credits. Mom has 120." |
| D-8 | Zero-value validation on redeem: **both enforced** — `ZeroAddress()` on a zero holder, `ZeroAmount()` on a zero amount | Symmetry with `issue`; ARCHITECTURE §12 demands validation on every input |

**D-4 is an explicit NON-requirement.** The contract models no funder↔recipient relationship, so Session 04 writes no test for one; AC-32 confirms only that two recipients' balances move independently.
### Conflicts with existing documents — flagged, not silently resolved
1. REQUIREMENTS FR-C-01 says symbol `CARE`; OQ-02 proposes a 10,000,000 cap. **D-1 and D-2 override both.** REQUIREMENTS.md is read-only this session, so FR-C-01 and OQ-02 must be updated in a later session; until then the two documents disagree.
2. ARCHITECTURE §6.7 declares `InsufficientCredits` and `InvalidServiceRef` but no FR-C requirement covers either. D-7 and D-6 settle them.
3. ARCHITECTURE §12 promises zero-address and zero-amount validation on "every input"; FR-C-07/08 cover only `issue`. D-8 settles it.
4. ARCHITECTURE §6.7's inherited-error list omits `ERC20InvalidCap`, the actual revert for FR-C-23. Verified against installed OpenZeppelin v5.7.0: `ERC20InvalidCap(uint256 cap)`, thrown by the `ERC20Capped` constructor when `cap == 0`.
5. FR-C-16 hides two requirements ("grant and revoke") and names one test covering only `ISSUER_ROLE`. Split into AC-16, AC-25, AC-26.
6. ARCHITECTURE §6.8's constructor takes `name_` and `symbol_` as parameters, so FR-C-01's identity is fixed by the deploy script, not by the contract source.
7. ARCHITECTURE §6.5 states one `_update` override covers `transfer` **and** `transferFrom`. Verified false for the error identity — see §6. `transferFrom` needs its own override to satisfy FR-C-14.
## 4. Identity
| Property | Value | Where fixed |
|---|---|---|
| `name()` / `symbol()` | `CareCredits` / `CCRD` | Deploy script arguments `name_`, `symbol_` |
| `decimals()` | `18` | Inherited default, not overridden |
| `cap()` | `100000000000000000000000000` (1e8 × 1e18) | Deploy script argument `cap_` |
| Cap mutability | None — `ERC20Capped` stores it `immutable`; no setter exists | Bytecode |

The contract source hardcodes no name, symbol or cap. Wrong deploy arguments produce a wrong token, which is why AC-38..AC-40 live in the `script` suite.
## 5. Roles
| Role | MAY | MAY NOT |
|---|---|---|
| `DEFAULT_ADMIN_ROLE` (0x00) | Grant `ISSUER_ROLE`; revoke `ISSUER_ROLE`; grant `PROVIDER_ROLE`; revoke `PROVIDER_ROLE` | Call `issue`. Call `redeem`. Move a balance. Change the cap. |
| `ISSUER_ROLE` | Call `issue(to, amount)` up to `remainingIssuable()` | Call `redeem`. Grant or revoke any role. Transfer. |
| `PROVIDER_ROLE` | Call `redeem(from, amount, serviceRef)` | Call `issue`. Grant or revoke any role. Transfer. |

Any role holder may `renounceRole` for itself only.
**Admin-escalation caveat (ARCHITECTURE §19-3, unsoftened):** `DEFAULT_ADMIN_ROLE` cannot mint, but it can grant itself `ISSUER_ROLE` and then mint to the cap. Separation of duties here is procedural, not cryptographic.
## 6. Non-transferability
| Call | Reverts with | Enforced at |
|---|---|---|
| `transfer(to, value)` | `TransfersDisabled()` | `_update` override |
| `transferFrom(from, to, value)` | `TransfersDisabled()` | Explicit `transferFrom` override — `_update` alone is not enough |
| `approve(spender, value)` | `ApprovalsDisabled()` | Separate `approve` override |

`_update` is the single choke point for every balance change, so one override closes `transfer`, `transferFrom`, and any future path OpenZeppelin adds. Rule: `from != address(0) && to != address(0)` reverts `TransfersDisabled()`; mints (`from == address(0)`) and burns (`to == address(0)`) pass through. `approve` needs its own override because it never routes through `_update`.
**Why `transferFrom` needs its own override (correctness trap).** OZ v5.7.0 `transferFrom` calls `_spendAllowance` before `_transfer`. Because `approve` always reverts, every allowance is `0`: a non-zero `value` reverts `ERC20InsufficientAllowance(spender, 0, value)` and never reaches `_update`, while `value == 0` passes the allowance check and reverts `TransfersDisabled()`. FR-C-14 requires `TransfersDisabled()` for every call and AC-43 requires one selector for every amount, so `transferFrom` must revert in its own override before any allowance is read. `_update` still blocks the value movement; it cannot fix the error identity. This contradicts ARCHITECTURE §6.5's claim that one `_update` override covers `transferFrom` — true for blocking, false for the error.
**Ordering constraint (correctness trap):** `ERC20Capped._update` calls `super._update` FIRST and checks the cap AFTER. The `_update` override must therefore place the transfer rejection BEFORE its `super._update` call.
## 7. Issuance
`issue(to, amount)` — external, `onlyRole(ISSUER_ROLE)`.
| Condition | Behaviour |
|---|---|
| Caller lacks `ISSUER_ROLE` | Reverts `AccessControlUnauthorizedAccount(caller, ISSUER_ROLE)` |
| `to == address(0)` | Reverts `ZeroAddress()` |
| `amount == 0` | Reverts `ZeroAmount()` |
| `totalSupply() + amount > cap()` | Reverts `ERC20ExceededCap(totalSupply() + amount, cap())` |
| `totalSupply() + amount == cap()` | Succeeds |
| Success | Mints `amount` to `to`; `totalSupply()` rises by `amount` |
| Events | `CreditsIssued(to, amount, msg.sender)` plus inherited `Transfer(address(0), to, amount)` |

`remainingIssuable()` returns `cap() - totalSupply()`.
## 8. Redemption
`redeem(from, amount, serviceRef)` — external, `onlyRole(PROVIDER_ROLE)`. It is a **pull** from the holder's balance: the recipient signs nothing and holds no wallet (P3).
| Condition | Behaviour |
|---|---|
| Caller lacks `PROVIDER_ROLE` | Reverts `AccessControlUnauthorizedAccount(caller, PROVIDER_ROLE)` |
| `from == address(0)` (D-8) | Reverts `ZeroAddress()` |
| `amount == 0` (D-8) | Reverts `ZeroAmount()` |
| `serviceRef == bytes32(0)` (D-6) | Reverts `InvalidServiceRef()` |
| `amount > balanceOf(from)` (D-7) | Pre-check reverts `InsufficientCredits(balanceOf(from), amount)`; no partial burn occurs (D-3) |
| Success | Burns exactly `amount` from `from`; `balanceOf(from)` and `totalSupply()` each fall by `amount` |
| Events | `CreditsRedeemed(from, amount, serviceRef, msg.sender)` plus inherited `Transfer(from, address(0), amount)` |

Burning uses the internal `_burn` only; no public burn exists (ADR-005 / EX-06).
**Trust assumption (ADR-004, stated plainly):** any `PROVIDER_ROLE` holder — in v1 the operator — can burn any holder's credits with no service rendered. Public events, role revocability and an off-chain dispute window mitigate this; they do not eliminate it.
## 9. Errors
| Error | Parameters | Source | Fires when |
|---|---|---|---|
| `ZeroAddress()` | — | custom | `issue` `to == address(0)`; `redeem` `from == address(0)`; constructor `admin == address(0)` |
| `ZeroAmount()` | — | custom | `issue` `amount == 0`; `redeem` `amount == 0` |
| `TransfersDisabled()` | — | custom | `_update` with both `from` and `to` non-zero |
| `ApprovalsDisabled()` | — | custom | Any `approve` call |
| `InsufficientCredits` | `uint256 balance, uint256 required` | custom | `redeem` with `amount > balanceOf(from)` |
| `InvalidServiceRef()` | — | custom | `redeem` with `serviceRef == bytes32(0)` |
| `ERC20ExceededCap` | `uint256 increasedSupply, uint256 cap` | OZ v5.7.0 | Mint pushing supply above the cap |
| `ERC20InvalidCap` | `uint256 cap` | OZ v5.7.0 | `ERC20Capped` constructor with `cap == 0` |
| `ERC20InsufficientBalance` | `address sender, uint256 balance, uint256 needed` | OZ v5.7.0 | Reachable only if the D-7 pre-check is removed |
| `AccessControlUnauthorizedAccount` | `address account, bytes32 neededRole` | OZ v5.7.0 | Every `onlyRole` failure |
## 10. Events
`CreditsIssued(address indexed to, uint256 amount, address indexed issuer)` · `CreditsRedeemed(address indexed from, uint256 amount, bytes32 indexed serviceRef, address provider)`
| Event | Indexed (filterable) | Not indexed |
|---|---|---|
| `CreditsIssued` | `to` — the family app filters issuance history by recipient address; `issuer` — audit queries ask "everything this issuer minted" | `amount` — never a filter term; indexing a value only costs gas |
| `CreditsRedeemed` | `from` — the activity feed is exactly a filter on `from`; `serviceRef` — reconciles one off-chain booking to its on-chain burn | `amount` — read from the log body, never filtered on; `provider` — attribution is read, not filtered, and it keeps a topic slot free |

Because `provider` is not indexed, `vm.expectEmit` for `CreditsRedeemed` uses `(true, true, false, true)`.
## 11. Constructor
Parameters: `name_`, `symbol_`, `cap_`, `admin`.
| Condition | Behaviour |
|---|---|
| `cap_ == 0` | Reverts `ERC20InvalidCap(0)` |
| `admin == address(0)` | Reverts `ZeroAddress()` |
| Success | Grants `DEFAULT_ADMIN_ROLE` to `admin` only |

The deployer receives no `ISSUER_ROLE`, no `PROVIDER_ROLE`, and no `DEFAULT_ADMIN_ROLE` unless the deployer address is passed as `admin`. Base-constructor order: `ERC20Capped(cap_)` runs before the body, so when `cap_` and `admin` are both invalid, `ERC20InvalidCap(0)` fires and `ZeroAddress()` does not — AC-22 must pass a valid cap.
Post-deploy assertions (ARCHITECTURE §6.8): (1) `cap()` equals the intended value; (2) `totalSupply() == 0`; (3) the intended admin holds `DEFAULT_ADMIN_ROLE`; (4) no unintended address holds `ISSUER_ROLE`; (5) no unintended address holds `PROVIDER_ROLE`.
## 12. Invariants
| # | Invariant | Assertion | Function |
|---|---|---|---|
| INV-1 | `totalSupply() <= cap()` | `assertLe(token.totalSupply(), token.cap())` | `invariant_TotalSupplyNeverExceedsCap` |
| INV-2 | Sum of balances equals supply | `assertEq(sum of balanceOf over every handler actor, token.totalSupply())` | `invariant_SumOfBalancesEqualsTotalSupply` |
| INV-3 | Only `ISSUER_ROLE` increases supply | `assertEq(token.totalSupply(), ghost_totalIssued - ghost_totalRedeemed)`, the handler minting only as an `ISSUER_ROLE` actor | `invariant_SupplyIncreasedOnlyByIssuer` |
| INV-4 | A balance moves only by issue or redeem | `assertEq(token.balanceOf(actor), ghost_issuedTo[actor] - ghost_redeemedFrom[actor])` for every actor | `invariant_BalanceMovesOnlyViaIssueOrRedeem` |
| INV-5 | Redeemed credits are burned, never transferred | `assertEq(ghost_totalRedeemed, ghost_supplyBurned)` | `invariant_RedemptionsAlwaysBurn` |

Invariant runs route through a handler in `contracts/test/invariant/handlers/` that bounds the fuzzer to issue / redeem / grant / revoke sequences and maintains the ghost variables named above.
## 13. Trust assumptions
1. **Completion oracle (TB4).** Someone must attest that a service happened; that someone is the operator. The chain makes the consequences auditable, not the attestation true.
2. **Operator redemption power (ADR-004, §19-2).** A `PROVIDER_ROLE` holder can burn any holder's credits without rendering a service.
3. **Admin escalation (§19-3).** `DEFAULT_ADMIN_ROLE` can grant itself `ISSUER_ROLE` and mint to the cap.
4. **Custodial recipient address (§19-5).** The recipient has no wallet; the balance sits at an address the operator controls on their behalf, with no recovery path.

No claim of security is made. This is unaudited educational code, testnet only.
## 14. Known limitations
1. The cap is unfixable if set wrong — only a redeploy corrects it (§19-4). 2. No pause, no emergency stop (ADR-002); the only lever is role revocation. 3. No upgrade path (ADR-003); a bug requires redeploy plus migration. 4. Reading the chain alone never reveals what a credit purchased (ADR-007). 5. Frontend correctness is not enforced on-chain (§19-6). 6. Not audited (§19-7); testnet only (§19-8).
7. **Specific to D-2:** a 100,000,000 CCRD cap will never bind during a testnet demo, so the cap-exceeded path exists as a tested property rather than an operational limit.
## 15. Acceptance criteria
| AC | Requirement | Test function | Category | Suite |
|---|---|---|---|---|
| AC-01 | FR-C-01 | `test_Metadata_ReturnsCorrectValues` | Happy path | unit |
| AC-02 | FR-C-02 | `test_Cap_IsImmutableAfterDeployment` | Edge cases | unit |
| AC-03 | FR-C-03 | `test_Deploy_InitialSupplyIsZero` | Happy path | unit |
| AC-04 | FR-C-04 | `test_Issue_MintsCreditsToRecipient` | Happy path | unit |
| AC-05 | FR-C-05 | `test_Issue_RevertsWhen_AmountExceedsCap` | Edge cases | unit |
| AC-06 | FR-C-06 | `test_Issue_RevertsWhen_CallerLacksIssuerRole` | Auth guard | unit |
| AC-07 | FR-C-07 | `test_Issue_RevertsWhen_RecipientIsZeroAddress` | Validation | unit |
| AC-08 | FR-C-08 | `test_Issue_RevertsWhen_AmountIsZero` | Validation | unit |
| AC-09 | FR-C-09 | `test_Redeem_BurnsCreditsFromHolder` | Happy path | unit |
| AC-10 | FR-C-10 | `test_Redeem_RevertsWhen_AmountExceedsBalance` | Error semantics | unit |
| AC-11 | FR-C-11 | `test_Redeem_RevertsWhen_CallerLacksProviderRole` | Auth guard | unit |
| AC-12 | FR-C-12 | `test_Redeem_ReducesBalanceAndTotalSupply` | Side effects | unit |
| AC-13 | FR-C-13 | `test_Transfer_AlwaysReverts` | Error semantics | unit |
| AC-14 | FR-C-14 | `test_TransferFrom_AlwaysReverts` | Error semantics | unit |
| AC-15 | FR-C-15 | `test_Approve_AlwaysReverts` | Error semantics | unit |
| AC-16 | FR-C-16 | `test_GrantRole_AdminCanGrantIssuerRole` | Auth guard | unit |
| AC-17 | FR-C-17 | `test_GrantRole_RevertsWhen_CallerIsNotAdmin` | Auth guard | unit |
| AC-18 | FR-C-18 | `test_Issue_RevertsAfter_IssuerRoleRevoked` | Auth guard | unit |
| AC-19 | FR-C-19 | `test_Issue_EmitsCreditsIssued` | Side effects | unit |
| AC-20 | FR-C-20 | `test_Redeem_EmitsCreditsRedeemed` | Side effects | unit |
| AC-21 | FR-C-21 | `test_RemainingIssuable_ReturnsCapMinusSupply` | Happy path | unit |
| AC-22 | FR-C-22 | `test_Constructor_RevertsWhen_AdminIsZeroAddress` | Validation | unit |
| AC-23 | FR-C-23 | `test_Constructor_RevertsWhen_CapIsZero` | Validation | unit |
| AC-24 | FR-C-24 | `test_Deploy_DeployerHasNoIssuerRole` | Auth guard | unit |
| AC-25 | FR-C-16 (revoke half) | `test_RevokeRole_AdminCanRevokeIssuerRole` | Auth guard | unit |
| AC-26 | FR-C-16 (PROVIDER_ROLE half) | `test_GrantRole_AdminCanGrantProviderRole` | Auth guard | unit |
| AC-27 | D-6 | `test_Redeem_RevertsWhen_ServiceRefIsZero` | Validation | unit |
| AC-28 | D-7 | `test_Redeem_InsufficientCreditsReportsBalanceAndRequired` | Error semantics | unit |
| AC-29 | D-8 | `test_Redeem_RevertsWhen_HolderIsZeroAddress` | Validation | unit |
| AC-30 | D-8 | `test_Redeem_RevertsWhen_AmountIsZero` | Validation | unit |
| AC-31 | D-3 | `test_Redeem_LeavesBalanceUnchangedWhen_AmountExceedsBalance` | Edge cases | unit |
| AC-32 | D-4 | `test_Issue_MintsToMultipleRecipientsIndependently` | Edge cases | unit |
| AC-33 | ARCH §6.3 separation of duties | `test_Issue_RevertsWhen_CallerIsAdminWithoutIssuerRole` | Auth guard | unit |
| AC-34 | ARCH §6.3 separation of duties | `test_GrantRole_RevertsWhen_CallerIsIssuer` | Auth guard | unit |
| AC-35 | ARCH §6.5 cap boundary | `test_Issue_SucceedsWhen_AmountEqualsRemainingCap` | Edge cases | unit |
| AC-36 | ARCH §6.4 emits Transfer | `test_Issue_EmitsTransferFromZeroAddress` | Side effects | unit |
| AC-37 | ARCH §6.4 emits Transfer | `test_Redeem_EmitsTransferToZeroAddress` | Side effects | unit |
| AC-38 | ARCH §6.8 assertion 3 | `test_Deploy_AdminHoldsDefaultAdminRole` | Happy path | script |
| AC-39 | ARCH §6.8 assertion 5 | `test_Deploy_DeployerHasNoProviderRole` | Auth guard | script |
| AC-40 | D-5 | `test_Deploy_DemoProviderHoldsProviderRole` | Auth guard | script |
| AC-41 | INV-1 / FR-C-05 | `testFuzz_Issue_NeverExceedsCap` | Edge cases | fuzz |
| AC-42 | FR-C-10 | `testFuzz_Redeem_RevertsWhen_AmountExceedsBalance` | Edge cases | fuzz |
| AC-43 | FR-C-13, FR-C-14 | `testFuzz_Transfer_AlwaysRevertsForAnyAmount` | Error semantics | fuzz |
| AC-44 | INV-1 | `invariant_TotalSupplyNeverExceedsCap` | Side effects | invariant |
| AC-45 | INV-2 | `invariant_SumOfBalancesEqualsTotalSupply` | Side effects | invariant |
| AC-46 | INV-3 | `invariant_SupplyIncreasedOnlyByIssuer` | Auth guard | invariant |
| AC-47 | INV-4 | `invariant_BalanceMovesOnlyViaIssueOrRedeem` | Side effects | invariant |
| AC-48 | INV-5 | `invariant_RedemptionsAlwaysBurn` | Side effects | invariant |

**Category coverage.** Six of seven categories appear above: Happy path, Validation, Error semantics, Edge cases, Auth guard, Side effects. **Render states is absent because a contract has no UI** — render states are covered by the FR-F (family app), FR-S (senior app) and FR-P (provider app) frontend suites, not here.
## 16. Open questions
| # | Question | Blocks |
|---|---|---|
| OQ-A | Which address is the operator, and which is the labelled demo provider, in the D-5 deploy script? Without both, AC-40 cannot be written against a concrete constant. | Session 04 script suite, Session 09 |
| OQ-B | Does `renounceRole` need its own acceptance row, or is inherited `AccessControl` behaviour accepted untested? Not settled — no row added. | Session 04 scope |
| OQ-C | May one address hold both `ISSUER_ROLE` and `PROVIDER_ROLE` in the demo, or must the deploy script forbid it? ARCHITECTURE asserts separation of duties but defines no on-chain mutual exclusion. | Session 04 script suite |
| OQ-D | When are FR-C-01 (`CARE`) and OQ-02 (10,000,000 cap) in REQUIREMENTS.md updated to CCRD / 100,000,000? | Documentation session |
## 17. Definition of done
Every AC-01..AC-48 test exists, is named exactly as above, sits in its stated suite, and passes. No `.sol` source hardcodes a name, symbol or cap. No public burn, pause, upgrade or allowance surface exists. All five invariants hold across 256 runs × 128 calls.
