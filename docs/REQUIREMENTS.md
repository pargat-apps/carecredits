# CareCredits — Requirements

**Status:** v1.0 · **Last updated:** 2026-08-14 · **Owner:** Pargat Singh

> Educational portfolio project. Testnet only. Unaudited. Never deployed to mainnet.

This document defines **what** the product does and **why**.
`docs/ARCHITECTURE.md` defines **how**. Specs in `specs/` implement individual
requirements from here. Every requirement below carries an ID and a test name — if a
requirement cannot be tested, it does not belong in this document.

---

## Contents

| § | Section |
|---|---|
| 1 | [Problem statement](#1-problem-statement) |
| 2 | [Users](#2-users) |
| 3 | [Product scope](#3-product-scope) |
| 4 | [Functional requirements — contract](#4-functional-requirements--contract) |
| 5 | [Functional requirements — family app](#5-functional-requirements--family-app) |
| 6 | [Functional requirements — senior app](#6-functional-requirements--senior-app) |
| 7 | [Functional requirements — provider app](#7-functional-requirements--provider-app) |
| 8 | [Functional requirements — off-chain](#8-functional-requirements--off-chain) |
| 9 | [Non-functional requirements](#9-non-functional-requirements) |
| 10 | [Service catalogue](#10-service-catalogue) |
| 11 | [Business rules](#11-business-rules) |
| 12 | [Constraints and assumptions](#12-constraints-and-assumptions) |
| 13 | [Explicitly excluded](#13-explicitly-excluded) |
| 14 | [Legal and regulatory](#14-legal-and-regulatory) |
| 15 | [Definition of done](#15-definition-of-done) |
| 16 | [Success criteria](#16-success-criteria) |
| 17 | [Open questions](#17-open-questions) |
| 18 | [Traceability](#18-traceability) |

**Priority key:** `MUST` = v1.0 blocker · `SHOULD` = v1.0 if time allows · `COULD` = v2

---

## 1. Problem statement

Families are geographically split. An adult child lives abroad or in another Canadian
province; an elderly parent lives alone in Canada. The child wants to arrange and pay
for help. Today that means:

| Today's friction | Consequence |
|---|---|
| Send money and hope it is used for care | No visibility, no assurance |
| International transfers are slow and expensive | Delay when help is needed now |
| Money arrives as **cash** | The parent must manage payments |
| Cash in an elderly person's hands | The single most exploited fraud vector for this age group |
| The parent arranges everything themselves | Phone calls, negotiating with strangers, no vetting |
| Nothing is recorded | Neither side knows what was actually delivered |

For the parent, the daily cost is time and risk: a snowfall means finding someone that
morning; a medical appointment means booking transport days ahead; a form means an
afternoon of confusion; an unfamiliar phone call may be a scam.

**The product:** the family prepays *service value* rather than sending *money*. The
parent receives services without ever handling payment.

---

## 2. Users

### 2.1 Funder — the adult child *(the paying customer)*

| | |
|---|---|
| **Where** | Abroad, or elsewhere in Canada |
| **Goal** | Ensure a parent is looked after, from a distance |
| **Pain** | Guilt, uncertainty, time-zone gaps, no visibility |
| **Tech** | Comfortable. Smartphone, can manage a wallet with guidance |
| **Success** | "I know Mom's driveway is cleared and I didn't have to phone anyone." |

### 2.2 Recipient — the elderly parent *(the protected user)*

| | |
|---|---|
| **Where** | Canada. Pilot: Ottawa, Ontario |
| **Age** | 70–90 |
| **Goal** | Stay independent at home; not be a burden |
| **Pain** | Reduced mobility, winter hazards, paperwork, scam calls, isolation |
| **Tech** | Low to none. Possibly reduced vision, hearing, or fine motor control |
| **Constraint** | **Never holds a wallet, signs anything, or sees a number** |
| **Success** | "I pressed one button and somebody came." |

### 2.3 Provider — the local worker

| | |
|---|---|
| **Who** | Vetted individual or small business |
| **Goal** | Steady work, reliable payment, no chasing invoices |
| **Pain** | Late payment, no-shows, unclear scope |
| **Tech** | Comfortable. Mobile-first |
| **Success** | "I finished, uploaded a photo, and payment was queued automatically." |

### 2.4 Operator — the platform *(you)*

| | |
|---|---|
| **Goal** | Run the network, stay solvent, stay legal |
| **Pain** | Provider vetting, liability, price drift, regulatory exposure |
| **Success** | Credits issued and redeemed with no manual reconciliation |

---

## 3. Product scope

### 3.1 In scope for v1.0

- One ERC-20 contract on Sepolia: capped supply, role-gated issuance, non-transferable, burn-on-redemption
- Family web app: connect, view balance, add credits, browse services, request, view activity
- Senior tablet app: four tiles, request a service, confirmation, call for help
- Provider web app: available jobs, accept, complete with photo, earnings
- Off-chain services **mocked**: catalogue, prices, bookings, providers
- Full test suite: unit, fuzz, invariant, deploy-script, frontend
- Public documentation and a verified contract

### 3.2 Out of scope for v1.0

Real money · real users · real providers · mainnet · a real backend or database ·
authentication · KYC · provider payouts · mobile apps · notifications · disputes

---

## 4. Functional requirements — contract

| ID | Requirement | Priority | Verified by |
|---|---|---|---|
| FR-C-01 | Token reports name `CareCredits`, symbol `CCRD`, and 18 decimals | MUST | `test_Metadata_ReturnsCorrectValues` |
| FR-C-02 | Supply cap is set at deployment and is immutable thereafter | MUST | `test_Cap_IsImmutableAfterDeployment` |
| FR-C-03 | Total supply is zero immediately after deployment | MUST | `test_Deploy_InitialSupplyIsZero` |
| FR-C-04 | An address holding `ISSUER_ROLE` can issue credits to any non-zero address | MUST | `test_Issue_MintsCreditsToRecipient` |
| FR-C-05 | Issuance that would push total supply above the cap reverts | MUST | `test_Issue_RevertsWhen_AmountExceedsCap` |
| FR-C-06 | Issuance by an address without `ISSUER_ROLE` reverts | MUST | `test_Issue_RevertsWhen_CallerLacksIssuerRole` |
| FR-C-07 | Issuance to the zero address reverts | MUST | `test_Issue_RevertsWhen_RecipientIsZeroAddress` |
| FR-C-08 | Issuance of zero credits reverts | MUST | `test_Issue_RevertsWhen_AmountIsZero` |
| FR-C-09 | An address holding `PROVIDER_ROLE` can redeem credits from a holder | MUST | `test_Redeem_BurnsCreditsFromHolder` |
| FR-C-10 | Redemption exceeding the holder's balance reverts | MUST | `test_Redeem_RevertsWhen_AmountExceedsBalance` |
| FR-C-11 | Redemption by an address without `PROVIDER_ROLE` reverts | MUST | `test_Redeem_RevertsWhen_CallerLacksProviderRole` |
| FR-C-12 | Redemption reduces both the holder's balance and total supply | MUST | `test_Redeem_ReducesBalanceAndTotalSupply` |
| FR-C-13 | `transfer` always reverts with `TransfersDisabled` | MUST | `test_Transfer_AlwaysReverts` |
| FR-C-14 | `transferFrom` always reverts with `TransfersDisabled` | MUST | `test_TransferFrom_AlwaysReverts` |
| FR-C-15 | `approve` always reverts with `ApprovalsDisabled` | MUST | `test_Approve_AlwaysReverts` |
| FR-C-16 | `DEFAULT_ADMIN_ROLE` can grant and revoke `ISSUER_ROLE` and `PROVIDER_ROLE` | MUST | `test_GrantRole_AdminCanGrantIssuerRole` |
| FR-C-17 | Role grants by a non-admin revert | MUST | `test_GrantRole_RevertsWhen_CallerIsNotAdmin` |
| FR-C-18 | A revoked issuer can no longer issue | MUST | `test_Issue_RevertsAfter_IssuerRoleRevoked` |
| FR-C-19 | `CreditsIssued(to, amount, issuer)` is emitted on every issuance | MUST | `test_Issue_EmitsCreditsIssued` |
| FR-C-20 | `CreditsRedeemed(from, amount, serviceRef, provider)` is emitted on every redemption | MUST | `test_Redeem_EmitsCreditsRedeemed` |
| FR-C-21 | `remainingIssuable()` returns `cap() - totalSupply()` | MUST | `test_RemainingIssuable_ReturnsCapMinusSupply` |
| FR-C-22 | The constructor reverts if the admin address is zero | MUST | `test_Constructor_RevertsWhen_AdminIsZeroAddress` |
| FR-C-23 | The constructor reverts if the cap is zero | MUST | `test_Constructor_RevertsWhen_CapIsZero` |
| FR-C-24 | The deployer does not automatically receive `ISSUER_ROLE` | MUST | `test_Deploy_DeployerHasNoIssuerRole` |

---

## 5. Functional requirements — family app

| ID | Requirement | Priority | Verified by |
|---|---|---|---|
| FR-F-01 | The user can connect a browser wallet | MUST | `connectWallet.test.tsx` |
| FR-F-02 | On a network other than Sepolia, writes are blocked and a one-click switch is offered | MUST | `networkGuard.test.tsx` |
| FR-F-03 | Token name, symbol, cap and total supply are read from the contract and displayed | MUST | `tokenInfo.test.tsx` |
| FR-F-04 | The recipient's balance is shown in credits **and** its CAD equivalent | MUST | `balanceCard.test.tsx` |
| FR-F-05 | Below 50 credits, a non-alarming low-balance state is shown with an add action | MUST | `balanceCard.lowBalance.test.tsx` |
| FR-F-06 | Adding credits follows a three-step flow: Choose → Review → Complete | MUST | `addCreditsFlow.test.tsx` |
| FR-F-07 | Every write calls `simulateContract` before requesting a signature | MUST | `useIssueCredits.simulate.test.ts` |
| FR-F-08 | All five write states are rendered: idle, simulating, awaiting signature, pending, confirmed | MUST | `txStates.test.tsx` |
| FR-F-09 | Every contract error is shown as a plain sentence with no hex, selector, or "reverted" | MUST | `errors.test.ts` |
| FR-F-10 | The activity feed is built from `CreditsIssued` and `CreditsRedeemed` events | MUST | `activityFeed.test.tsx` |
| FR-F-11 | The service catalogue is browsable by category with each service's credit cost | MUST | `catalogue.test.tsx` |
| FR-F-12 | A service detail view shows cost, what's included, duration, and a request action | MUST | `serviceDetail.test.tsx` |
| FR-F-13 | The issuer panel renders only when an on-chain `hasRole` check returns true | MUST | `roleGate.test.tsx` |
| FR-F-14 | Upcoming scheduled services are displayed with provider and time | SHOULD | `upcoming.test.tsx` |
| FR-F-15 | A weather-aware card shows scheduled snow clearing when snow is forecast | COULD | — |

---

## 6. Functional requirements — senior app

> Every requirement in this section is a **safety requirement**, not a usability preference.

| ID | Requirement | Priority | Verified by |
|---|---|---|---|
| FR-S-01 | No more than four choices are visible on screen at once | MUST | `seniorHome.choiceCount.test.tsx` |
| FR-S-02 | No credit count, dollar amount, or any numeric value appears anywhere | MUST | `seniorView.noNumbers.test.tsx` |
| FR-S-03 | Availability is expressed in words only, e.g. "You have plenty of help available" | MUST | `seniorHome.availability.test.tsx` |
| FR-S-04 | A confirmation names a person and a time: "Sarah will call you within an hour" | MUST | `seniorConfirm.test.tsx` |
| FR-S-05 | A "Call for Help" action is always visible without scrolling | MUST | `seniorView.helpButton.test.tsx` |
| FR-S-06 | No wallet connection, signature request, or gas concept exists in this app | MUST | `seniorView.noWallet.test.tsx` |
| FR-S-07 | Body text is at least 24px; interactive targets are at least 64px | MUST | `seniorView.a11y.test.tsx` |
| FR-S-08 | There are no menus, settings, navigation depth, or login screen | MUST | `seniorView.noNav.test.tsx` |
| FR-S-09 | Requesting a service takes exactly one tap from the home screen | MUST | `seniorHome.oneTap.test.tsx` |

---

## 7. Functional requirements — provider app

| ID | Requirement | Priority | Verified by |
|---|---|---|---|
| FR-P-01 | Available jobs list shows service, neighbourhood, date, time, distance, credits and CAD | MUST | `availableJobs.test.tsx` |
| FR-P-02 | A provider can accept an available job | MUST | `acceptJob.test.tsx` |
| FR-P-03 | A job detail view shows scope, time window and client first name only | MUST | `jobDetail.test.tsx` |
| FR-P-04 | Completion requires a confirmation photo before it can be submitted | MUST | `completeJob.test.tsx` |
| FR-P-05 | Earnings show jobs completed, credits earned, CAD payable and next payout | MUST | `earnings.test.tsx` |
| FR-P-06 | No client full name, address, or phone number is shown before a job is accepted | MUST | `jobDetail.privacy.test.tsx` |

---

## 8. Functional requirements — off-chain

> Mocked in v1. Requirements define the boundary so the contract stays clean.

| ID | Requirement | Priority | Verified by |
|---|---|---|---|
| FR-B-01 | A service catalogue holds every service with its current credit cost | MUST | `catalogue.test.ts` |
| FR-B-02 | The credit cost of a service is resolved **at redemption**, never at purchase | MUST | `pricing.resolveAtRedemption.test.ts` |
| FR-B-03 | A booking has states: requested → assigned → in progress → completed → redeemed | MUST | `booking.lifecycle.test.ts` |
| FR-B-04 | Redemption on-chain occurs only after a booking reaches `completed` | MUST | `redemption.trigger.test.ts` |
| FR-B-05 | `serviceRef` passed on-chain is `keccak256(bookingId)` and contains no personal data | MUST | `serviceRef.test.ts` |
| FR-B-06 | A provider registry records vetting status; unvetted providers cannot be assigned | MUST | `providerRegistry.test.ts` |

---

## 9. Non-functional requirements

### 9.1 Accessibility — the highest-priority NFR in this product

| ID | Requirement | Priority |
|---|---|---|
| NFR-A-01 | All screens meet WCAG 2.1 AA | MUST |
| NFR-A-02 | Body text contrast ≥ 4.5:1; large text and UI borders ≥ 3:1 | MUST |
| NFR-A-03 | Every interactive element has a visible focus indicator | MUST |
| NFR-A-04 | Every flow is completable by keyboard alone | MUST |
| NFR-A-05 | Touch targets ≥ 48px everywhere; ≥ 64px in the senior app | MUST |
| NFR-A-06 | Layouts remain usable at 200% browser zoom | MUST |
| NFR-A-07 | Status is never conveyed by colour alone — always colour + icon + text | MUST |
| NFR-A-08 | `prefers-reduced-motion` is respected | SHOULD |

### 9.2 Usability and language

| ID | Requirement | Priority |
|---|---|---|
| NFR-U-01 | No user-facing text contains: wallet, token, gas, mint, burn, blockchain, smart contract, transaction hash, seed phrase | MUST |
| NFR-U-02 | All copy reads at approximately a grade 6 level | MUST |
| NFR-U-03 | Every error states what happened, what it means, and what to do next | MUST |
| NFR-U-04 | Every list has a designed empty state | MUST |
| NFR-U-05 | Credit amounts are always shown alongside their CAD equivalent (except in the senior app) | MUST |

### 9.3 Security and privacy

| ID | Requirement | Priority |
|---|---|---|
| NFR-S-01 | No personally identifying information is ever written on-chain | MUST |
| NFR-S-02 | No private key, seed phrase, API key or RPC credential appears in the repository at any commit | MUST |
| NFR-S-03 | Every access restriction is enforced by the contract, never only by the UI | MUST |
| NFR-S-04 | Slither reports no unresolved High or Critical findings | MUST |
| NFR-S-05 | Deployment keys are stored in an encrypted keystore, never in a file | MUST |

### 9.4 Quality

| ID | Requirement | Priority |
|---|---|---|
| NFR-Q-01 | Line and branch coverage ≥ 95% on `contracts/src/` | MUST |
| NFR-Q-02 | All five system invariants hold under invariant testing | MUST |
| NFR-Q-03 | Fuzz tests run at ≥ 1000 runs; invariant tests at ≥ 256 runs | MUST |
| NFR-Q-04 | CI passes on `main`: format, build, test, coverage, typecheck | MUST |
| NFR-Q-05 | The contract source is verified and readable on Sepolia Etherscan | MUST |

### 9.5 Performance and compatibility

| ID | Requirement | Priority |
|---|---|---|
| NFR-P-01 | Contract reads render within 3 seconds on Sepolia under normal RPC conditions | SHOULD |
| NFR-P-02 | The senior app is usable on a tablet at 768px width | MUST |
| NFR-P-03 | The family app is usable at 390px width | MUST |
| NFR-P-04 | Supported browsers: current Chrome, Edge, Firefox, Safari | SHOULD |

---

## 10. Service catalogue

**1 CareCredit = $1 CAD of service value.** Different services cost different numbers
of credits.

### Winter and home

| Service | Credits |
|---|---|
| Sidewalk snow clearing | 35 |
| Driveway snow clearing | 50 |
| Salting icy steps | 15 |
| Lawn mowing | 40 |
| Leaf raking / yard cleanup | 60 |
| Gutter cleaning | 120 |
| Small handyman job (1 hr) | 60 |
| Change bulbs / smoke alarm batteries | 25 |

### Transport

| Service | Credits |
|---|---|
| Medical ride, one way | 25 |
| Medical ride with waiting | 60 |
| Grocery trip with carrying help | 40 |
| Out-of-town medical appointment | 250 |
| Overnight stay for an out-of-town appointment | 120 |

### Daily living

| Service | Credits |
|---|---|
| Grocery delivery and put away | 20 |
| House cleaning (2 hrs) | 90 |
| Laundry pickup and return | 35 |
| Dog walking | 20 |
| Meal preparation (5 meals) | 75 |

### Paperwork and language

| Service | Credits |
|---|---|
| Government forms assistance (1 hr) | 45 |
| Tax filing assistance | 80 |
| **Medical appointment interpretation (1.5 hrs)** | 70 |
| Mail sorting and bill review | 40 |

### Technology and safety

| Service | Credits |
|---|---|
| Device troubleshooting (1 hr) | 50 |
| **Video call setup with family** | 30 |
| **"Is this call a scam?" check** | 15 |
| Escort and note-taking at a doctor's visit | 55 |

### Featured in the demo

Snow clearing · Medical interpretation · Scam call check · Video call setup

Chosen because together they tell the product's story: the physical need, the
language gap, the fraud risk, and the emotional connection.

---

## 11. Business rules

| ID | Rule | Rationale |
|---|---|---|
| BR-01 | 1 CareCredit represents $1 CAD of service value | Simple mental model; different services cost different credit counts |
| BR-02 | The funder pays **$1.10** per credit | Operator margin |
| BR-03 | The provider redeems each credit for **$1.00** | Provider is paid in CAD off-chain |
| BR-04 | Operator margin is therefore approximately 9% | Covers vetting, insurance, platform |
| BR-05 | Service prices are resolved **at redemption**, never at purchase | Protects the operator from price drift (ADR-006) |
| BR-06 | Credits are **not** redeemable for cash, by anyone, ever | Core safety and legal property |
| BR-07 | Credits do not expire | Consumer fairness; several provinces restrict expiry on prepaid value |
| BR-08 | An optional family plan may be charged at $5/month | Software revenue, not token sales |
| BR-09 | The operator never sells the token as an investment | Keeps it a consumptive utility voucher |
| BR-10 | The supply cap bounds total outstanding service liability | The cap is a solvency control, not decoration |

**Worked example**

```
Funder buys 300 credits          →  pays $330.00 CAD
Provider redeems 300 credits     →  receives $300.00 CAD
Operator retains                 →  $30.00 CAD  (~9%)
```

---

## 12. Constraints and assumptions

### Constraints

| ID | Constraint |
|---|---|
| CON-01 | Testnet only. Sepolia. Never mainnet. |
| CON-02 | No real money, users, or service providers |
| CON-03 | Solo developer; target ~15 hours of build time |
| CON-04 | Contract is immutable — no proxy, no upgrade path |
| CON-05 | The recipient has no wallet, by design |
| CON-06 | Off-chain services are mocked, not built |
| CON-07 | Stack fixed: Foundry, OpenZeppelin 5.x, React, TypeScript, Vite, viem, Vitest |

### Assumptions

| ID | Assumption | If false |
|---|---|---|
| ASM-01 | The funder can install and use a browser wallet with guidance | v2 needs embedded wallets |
| ASM-02 | The operator can vet providers and confirm completion | The entire trust model fails (see TB4) |
| ASM-03 | Sepolia remains available and faucets remain accessible | Switch testnet; low cost |
| ASM-04 | 18 decimals is appropriate for a $1-denominated credit | Would require redeploy |
| ASM-05 | Recipients have a tablet or someone to set one up | Product needs a phone-only path |

---

## 13. Explicitly excluded

Excluded on purpose, with the reason. **Being able to defend an exclusion is worth
more than adding a feature.**

| ID | Excluded | Reason |
|---|---|---|
| EX-01 | `Pausable` | Freezing a vulnerable person's access to help is a serious power with no requirement behind it |
| EX-02 | `Ownable` | One key with all powers; the requirement is multiple revocable issuers |
| EX-03 | Upgradeable proxy | A proxy admin who can silently replace logic destroys the trust argument entirely |
| EX-04 | Recipient-initiated transfers | Non-transferability is what makes credits worthless to a scammer |
| EX-05 | Cash redemption | Same reason, plus it would make the credit stored value with the regulation that follows |
| EX-06 | `ERC20Burnable` public burn | Would let a recipient destroy credits with no service received (ADR-005) |
| EX-07 | Secondary market or trading | This is a voucher, not an asset. Any market invites speculation. |
| EX-08 | Nursing, medication, wound care, foot care | Regulated health services requiring licensing |
| EX-09 | Bill payment or banking on someone's behalf | Financial services; also the most common elder-fraud vector |
| EX-10 | Emergency or fall response | Requires guaranteed response times that cannot be promised |
| EX-11 | Driving a client's personal vehicle | Insurance exposure |
| EX-12 | Real-time hotel or motel booking | A live-availability problem, not a token problem; already solved well elsewhere |
| EX-13 | Mainnet deployment | Educational project; no audit, no legal review |
| EX-14 | Referral, points multipliers, tiers | Gamification of elder care is the wrong instinct |

---

## 14. Legal and regulatory

**Not legal advice.** Recorded so the design stays on the safe side of known lines.
Any real-world launch needs Canadian counsel first.

| Area | Consideration | Design response |
|---|---|---|
| Securities | CSA Staff Notice 46-308 — most token offerings have been found to involve securities; genuine consumptive utility tokens generally have not | Credits are non-transferable, non-cashable, redeemable only for services, and **never sold by the operator as an investment** (BR-09) |
| Money services | FINTRAC MSB registration covers virtual currency exchange and transfer; enforcement has been active | The operator never custodies customer funds and never exchanges crypto for fiat on a customer's behalf |
| Prepaid / gift cards | Provincial rules restrict expiry and fees on prepaid value | Credits never expire (BR-07); no dormancy fees |
| Vulnerable persons | Sending workers into seniors' homes | Criminal record checks, insurance and liability are mandatory before any real deployment (FR-B-06) |
| Privacy (PIPEDA) | Right to erasure vs an immutable public ledger | No PII on-chain, ever (NFR-S-01, ADR-007) |
| Consumer protection | Clear disclosure of what credits are and are not | UI states plainly that credits have no cash value |

**The governing principle: monetise the software, never the token.** Revenue comes
from margin and subscription (BR-02 to BR-08). The operator never sells tokens as an
investment.

---

## 15. Definition of done

v1.0 is complete when every box is checked.

**Contract**
- [ ] All FR-C requirements implemented and tested
- [ ] `forge test` green, including fuzz and invariant suites
- [ ] Coverage ≥ 95% on `src/`
- [ ] `.gas-snapshot` committed
- [ ] Slither clean, or every finding justified in writing
- [ ] Deployed to Sepolia and **verified** on Etherscan
- [ ] All five post-deploy assertions pass

**Frontend**
- [ ] All MUST requirements in FR-F, FR-S, FR-P implemented
- [ ] Every NFR-A accessibility requirement verified with real numbers
- [ ] No banned word appears in any user-facing string (NFR-U-01)
- [ ] Frontend tests pass
- [ ] Works end-to-end against Sepolia

**Repository**
- [ ] CI green on `main`
- [ ] `README`, `ARCHITECTURE`, `REQUIREMENTS`, `SECURITY-REVIEW`, `DEPLOYMENTS` complete
- [ ] `git log` audited — no secret in any commit, ever
- [ ] Tagged `v1.0.0` with a written release
- [ ] Demo video recorded

**Personal**
- [ ] You can explain any file in the repository from memory
- [ ] You can defend every exclusion in §13 out loud

---

## 16. Success criteria

This is a portfolio project. Honest measures of success:

| Measure | Target |
|---|---|
| An interviewer can understand the product in 60 seconds | ✅ / ❌ |
| You can explain why it needs a blockchain, and where it does not | ✅ / ❌ |
| You can name eight limitations without prompting | ✅ / ❌ |
| Invariant tests exist and could actually fail | ✅ / ❌ |
| The contract is verified and publicly readable | ✅ / ❌ |
| The README's setup steps work from a clean clone | ✅ / ❌ |
| The repository leads to a technical conversation, not a shrug | ✅ / ❌ |

**Not** measures of success: user counts, token price, transaction volume, GitHub
stars. There are no users. Saying so plainly is itself a signal.

---

## 17. Open questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| OQ-01 | ~~Confirm symbol~~ **Resolved (Session 03, D-1):** symbol is **`CCRD`** | Pargat | — |
| OQ-02 | ~~Cap value~~ **Resolved (Session 03, D-2):** cap is **100,000,000 CCRD** (`100_000_000e18`), not the 10,000,000 originally proposed | Pargat | — |
| OQ-03 | ~~Partial redemption~~ **Resolved (Session 03, D-3):** all-or-nothing — partial redemption reverts | Pargat | — |
| OQ-04 | ~~One funder, many recipients~~ **Resolved (Session 03, D-4):** allowed implicitly, and an explicit NON-requirement — the contract models no funder↔recipient link | Pargat | — |
| OQ-05 | ~~Who holds `PROVIDER_ROLE`~~ **Resolved (Session 03, D-5):** the operator address **plus** exactly one labelled demo-provider address, both granted by the deploy script | Pargat | — |
| OQ-06 | Does the senior app need a phone-only path, or is tablet sufficient for v1? | Pargat | FR-S scope |

Open questions are recorded rather than guessed. An invented requirement becomes an
invented test and then invented code.

Resolutions D-1…D-8 are recorded in full, with rationale, in
`specs/contract/carecredits-token.md` §3. OQ-06 remains open.

---

## 18. Traceability

Sample rows. The full matrix is maintained as tests are written.

| Requirement | Architecture § | Test | Status |
|---|---|---|---|
| FR-C-02 cap immutable | §6.2, ADR-008 | `test_Cap_IsImmutableAfterDeployment` | ⬜ |
| FR-C-05 cap enforced | §6.5, §13 invariant 1 | `test_Issue_RevertsWhen_AmountExceedsCap` | ⬜ |
| FR-C-13 transfer reverts | §6.5 | `test_Transfer_AlwaysReverts` | ⬜ |
| FR-F-02 network guard | §8.1, §11 T6 | `networkGuard.test.tsx` | ⬜ |
| FR-F-07 simulate first | §8.3 | `useIssueCredits.simulate.test.ts` | ⬜ |
| FR-S-02 no numbers | §3 P3, §11 T4 | `seniorView.noNumbers.test.tsx` | ⬜ |
| FR-B-02 price at redemption | §7.2, ADR-006 | `pricing.resolveAtRedemption.test.ts` | ⬜ |
| NFR-S-01 no PII on-chain | §7.1, ADR-007 | manual review + `serviceRef.test.ts` | ⬜ |

---

## Change log

| Date | Change |
|---|---|
| 2026-08-14 | Initial requirements. 24 contract, 15 family, 9 senior, 6 provider, 6 off-chain, 22 non-functional. |
