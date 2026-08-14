# CareCredits — Architecture

**Status:** v1.0 draft · **Last updated:** 2026-08-14 · **Owner:** Pargat Singh

> Educational portfolio project. Testnet only. Unaudited. Never deployed to mainnet.

This document is the source of truth for system design. Specs must be consistent
with it. If a feature requires contradicting it, this document changes first — by
adding an ADR in §18 — and only then does the code change.

---

## Contents

| § | Section |
|---|---|
| 1 | [Purpose and scope](#1-purpose-and-scope) |
| 2 | [Product overview](#2-product-overview) |
| 3 | [Architecture principles](#3-architecture-principles) |
| 4 | [System context](#4-system-context) |
| 5 | [Component architecture](#5-component-architecture) |
| 6 | [Contract architecture](#6-contract-architecture) |
| 7 | [Data architecture](#7-data-architecture) |
| 8 | [Frontend architecture](#8-frontend-architecture) |
| 9 | [Off-chain services](#9-off-chain-services) |
| 10 | [Sequence flows](#10-sequence-flows) |
| 11 | [Trust boundaries and threat model](#11-trust-boundaries-and-threat-model) |
| 12 | [Security architecture](#12-security-architecture) |
| 13 | [Test architecture](#13-test-architecture) |
| 14 | [Deployment architecture](#14-deployment-architecture) |
| 15 | [Observability](#15-observability) |
| 16 | [Failure modes](#16-failure-modes) |
| 17 | [Performance and scale](#17-performance-and-scale) |
| 18 | [Architecture decision records](#18-architecture-decision-records) |
| 19 | [Known limitations](#19-known-limitations) |
| 20 | [Future architecture (v2)](#20-future-architecture-v2) |
| 21 | [Glossary](#21-glossary) |

---

## 1. Purpose and scope

### In scope for v1.0

- One ERC-20 contract on Sepolia holding credit balances, a supply cap, and roles
- A React frontend serving three distinct audiences
- Mocked off-chain services — service catalogue, prices, bookings, providers
- Full test coverage: unit, fuzz, invariant, deploy-script, frontend

### Explicitly out of scope for v1.0

- Real money, real users, real service providers
- Mainnet or any L2 production deployment
- A real backend, database, or authentication system
- Payment rails, KYC, provider payouts
- Mobile applications

### Audience

Future me, an interviewer reading the repository, and any developer picking this up.

---

## 2. Product overview

Families — living abroad or elsewhere in Canada — prepay service credits for an
elderly parent living in Canada. The parent redeems them for trusted local services.
The parent never handles money.

- **1 CareCredit = $1 CAD of service value**
- **Pilot city:** Ottawa, Ontario
- **Flagship services:** snow clearing, medical rides, medical interpretation, scam-call checks

```
FUNDER                RECIPIENT              PROVIDER
buys credits    →     requests service   →   completes service
(abroad or CA)        (elderly, Canada)      (local, vetted)
                                                    │
                                             credits burned
```

### Why a blockchain

Four properties. Everything else in this product is ordinary web development.

| # | Property | Why a database cannot provide it |
|---|---|---|
| 1 | Credits can never convert back to cash | A company can promise this; a policy change can revoke it. A contract cannot revoke it. |
| 2 | Supply cap cannot be exceeded | Any database owner can run an `UPDATE`. An `immutable` cap is enforced by the EVM. |
| 3 | The record outlives the company | A shut-down database evaporates. On-chain balances remain provable. |
| 4 | Overseas value arrives in minutes without a bank | Correspondent banking is slow and expensive, and delivers **cash** — which reintroduces problem 1. |

**Honest framing:** roughly 90% of this system is a normal web application. The
blockchain does one job — hold a credit balance under rules nobody can change.

---

## 3. Architecture principles

Applied in order when principles conflict.

### P1 — Security lives in the contract, never in the UI
The frontend is advisory. Anyone can call the contract directly via `cast` or
Etherscan. Hiding a button is not access control.

### P2 — Keep the permanent thing permanent, the changeable thing changeable
Contracts are immutable; prices change weekly. Anything that changes goes off-chain.
Consequence: the service catalogue can grow to fifty entries without touching Solidity.

### P3 — The recipient never touches value
No wallet, no signature, no gas, no numbers, no currency shown. This is a safety
property. Older adults are the most heavily targeted group for financial fraud, and
a credit that cannot be transferred or cashed is worthless to a scammer.

### P4 — Least privilege
Three roles, each able to do exactly one thing. No role can do another's job. Every
role is revocable.

### P5 — Immutability over upgradeability
No proxies. A proxy admin who can silently replace all logic destroys the entire
trust argument in §2. If the contract is wrong, redeploy and migrate.

### P6 — Add nothing without a requirement
Every feature traces to a sentence in `docs/REQUIREMENTS.md`. Removing a feature for
a stated reason is a better engineering outcome than adding one.

### P7 — Honest limitations over claimed guarantees
Where trust is required, name it (§11, §19). Never describe this system as trustless
or secure.

---

## 4. System context

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                ACTORS                                    │
└─────────────────────────────────────────────────────────────────────────┘

  FUNDER                 RECIPIENT              PROVIDER          OPERATOR
  adult child            elderly parent         local worker      platform
  abroad or in CA        in Canada              vetted            (you)
      │                       │                     │                 │
  buys credits          requests service      completes work     vets providers
  has a wallet          NO wallet             has a wallet       sets prices
  pays in fiat/crypto   NO money              paid in CAD        holds admin role
      │                       │                     │                 │
      ▼                       ▼                     ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        CARECREDITS PLATFORM                              │
│                                                                          │
│   Family Web App        Senior Tablet App        Provider Web App        │
│   React + viem          React, no wallet         React + viem            │
│   full dashboard        4 tiles, no numbers      jobs + earnings         │
└─────────────────────────────────────────────────────────────────────────┘
            │                                              │
            ▼                                              ▼
┌───────────────────────────┐              ┌──────────────────────────────┐
│  Sepolia testnet          │              │  Off-chain services (mock)   │
│  CareCredits.sol          │              │  catalogue · prices ·        │
│  balances · cap · roles   │              │  bookings · providers ·      │
│  issue · redeem · events  │              │  scheduling · payouts        │
└───────────────────────────┘              └──────────────────────────────┘
            │                                              │
            ▼                                              ▼
┌───────────────────────────┐              ┌──────────────────────────────┐
│  External: RPC provider   │              │  External: wallet (MetaMask) │
│  Alchemy / Infura         │              │  Etherscan (verification)    │
└───────────────────────────┘              └──────────────────────────────┘
```

### Actor capability matrix

| Capability | Funder | Recipient | Provider | Operator |
|---|:---:|:---:|:---:|:---:|
| Holds a wallet | ✅ | ❌ | ✅ | ✅ |
| Buys credits | ✅ | ❌ | ❌ | ❌ |
| Holds a credit balance | ❌ | ✅ | ❌ | ❌ |
| Requests a service | ✅ | ✅ | ❌ | ❌ |
| Completes a service | ❌ | ❌ | ✅ | ❌ |
| Triggers a redemption | ❌ | ❌ | ❌ | ✅ |
| Grants / revokes roles | ❌ | ❌ | ❌ | ✅ |
| Sees credit numbers | ✅ | ❌ | ✅ | ✅ |

The recipient row is the product. Everything else follows from it.

---

## 5. Component architecture

```
                      ┌────────────────────────────┐
                      │       PRESENTATION          │
                      │   pages/ · components/      │
                      │   No data fetching. Ever.   │
                      └─────────────┬──────────────┘
                                    │ props down, events up
                      ┌─────────────▼──────────────┐
                      │        APPLICATION          │
                      │  hooks/ — all state lives   │
                      │  here. One hook per concern │
                      └─────────────┬──────────────┘
                                    │
                  ┌─────────────────┴─────────────────┐
                  ▼                                   ▼
      ┌───────────────────────┐          ┌────────────────────────┐
      │     CHAIN ACCESS       │          │    OFF-CHAIN ACCESS    │
      │  config/ · abi/        │          │  services · prices ·   │
      │  publicClient (read)   │          │  bookings (mock in v1) │
      │  walletClient (write)  │          └────────────────────────┘
      └───────────┬───────────┘
                  ▼
      ┌───────────────────────┐
      │   CareCredits.sol      │
      │   Sepolia              │
      └───────────────────────┘
```

**The dependency rule:** dependencies point downward only. A component may not import
a client. A hook may not import a page. Violating this makes components untestable
without a blockchain, which is the single most common reason DApp test suites are slow
and flaky.

---

## 6. Contract architecture

### 6.1 Inheritance

```
                    ┌──────────────────┐
                    │      ERC20        │  balances, totalSupply,
                    │  (OpenZeppelin 5) │  _mint, _burn, _update hook
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
    ┌──────────────────┐          ┌──────────────────┐
    │   ERC20Capped     │          │  AccessControl    │
    │  immutable cap,   │          │  roles, onlyRole  │
    │  checks in _update│          │                   │
    └────────┬─────────┘          └─────────┬────────┘
             └──────────────┬───────────────┘
                            ▼
                  ┌──────────────────┐
                  │   CareCredits     │
                  │  issue · redeem   │
                  │  transfers off    │
                  └──────────────────┘
```

```solidity
contract CareCredits is ERC20Capped, AccessControl { ... }
```

⚠️ **Version-sensitive.** OpenZeppelin 5.x replaced `_beforeTokenTransfer` /
`_afterTokenTransfer` with a single `_update(from, to, value)` hook. Confirm the exact
`ERC20Capped` error names against the installed version before relying on them —
they changed between v4 and v5.

**What we inherit, and what we still owe:**

| From | Provides | We still must |
|---|---|---|
| `ERC20` | balances, `totalSupply`, `_mint`, `_burn`, `_update` | Block transfers |
| `ERC20Capped` | `immutable` cap, cap check inside `_update` | Choose the cap, validate it at deploy |
| `AccessControl` | `grantRole`, `revokeRole`, `hasRole`, `onlyRole` | Define roles, assign at deploy |

**Deliberately not inherited: `ERC20Burnable`.** See [ADR-005](#adr-005).

### 6.2 State

```solidity
bytes32 public constant ISSUER_ROLE   = keccak256("ISSUER_ROLE");
bytes32 public constant PROVIDER_ROLE = keccak256("PROVIDER_ROLE");
// DEFAULT_ADMIN_ROLE (0x00) comes from AccessControl
// cap() is immutable, provided by ERC20Capped
```

There is no mutable storage of our own. Everything is either an inherited mapping,
a constant, or an immutable. That is deliberate — less state is less to get wrong.

`immutable` values are written into the deployed bytecode, cost almost nothing to
read, and cannot be changed by anyone including the deployer. The cap's immutability
*is* the product's core promise.

### 6.3 Roles and permissions

| Role | May | May not |
|---|---|---|
| `DEFAULT_ADMIN_ROLE` | Grant and revoke `ISSUER_ROLE` and `PROVIDER_ROLE` | Issue. Redeem. Move balances. Change the cap. |
| `ISSUER_ROLE` | `issue()` up to the remaining cap | Redeem. Grant roles. Transfer. |
| `PROVIDER_ROLE` | `redeem()` on service completion | Issue. Grant roles. Transfer. |

**Separation of duties:** the admin cannot create credits, and the issuer cannot
grant itself more power. Compromising one key is not enough to drain the system —
though see [§19](#19-known-limitations) for the honest caveat about admin escalation.

### 6.4 Function surface

| Function | Visibility | Access | Reads/Writes | Gas | Emits |
|---|---|---|---|---|---|
| `name` `symbol` `decimals` | view | public | reads | free | — |
| `cap` | view | public | reads | free | — |
| `totalSupply` `balanceOf` | view | public | reads | free | — |
| `remainingIssuable` | view | public | reads | free | — |
| `hasRole` `getRoleAdmin` | view | public | reads | free | — |
| `issue(to, amount)` | external | `ISSUER_ROLE` | **writes** | ✅ | `CreditsIssued`, `Transfer` |
| `redeem(from, amount, ref)` | external | `PROVIDER_ROLE` | **writes** | ✅ | `CreditsRedeemed`, `Transfer` |
| `grantRole` `revokeRole` | external | `DEFAULT_ADMIN_ROLE` | **writes** | ✅ | `RoleGranted` / `RoleRevoked` |
| `renounceRole` | external | self | **writes** | ✅ | `RoleRevoked` |
| `transfer` `transferFrom` `approve` | external | — | **always revert** | ✅ | — |

Reads are free and require no signature — one node answers a question. Writes cost
gas and require a signature — thousands of nodes must permanently agree on a new fact.

### 6.5 Non-transferability

Every balance change in OpenZeppelin 5 passes through one hook. Overriding it closes
every path at once:

```
_update(from, to, value)
   │
   ├─ from == address(0)  →  MINT      →  allow (ERC20Capped checks the cap)
   ├─ to   == address(0)  →  BURN      →  allow
   └─ otherwise           →  TRANSFER  →  revert TransfersDisabled()
```

```solidity
function _update(address from, address to, uint256 value)
    internal
    override(ERC20Capped)
{
    if (from != address(0) && to != address(0)) revert TransfersDisabled();
    super._update(from, to, value);   // ERC20Capped enforces the cap on mint
}
```

**Why the hook and not the functions.** Overriding `transfer` alone leaves
`transferFrom` open — a classic and expensive mistake. `_update` is the single choke
point, so one override covers `transfer`, `transferFrom`, and any future path
OpenZeppelin adds.

`approve` is overridden separately to revert, because an allowance that can never be
spent is a misleading UI surface.

### 6.6 Events

```solidity
event CreditsIssued(
    address indexed to,
    uint256 amount,
    address indexed issuer
);

event CreditsRedeemed(
    address indexed from,
    uint256 amount,
    bytes32 indexed serviceRef,
    address provider
);
```

Plus inherited `Transfer`, `Approval`, `RoleGranted`, `RoleRevoked`.

**`indexed` fields are filterable.** The frontend asks the RPC for "every
`CreditsRedeemed` where `from` = this address" without scanning the chain. That query
is the activity feed.

**`serviceRef`** is `keccak256(bookingId)` — a pointer to the off-chain booking. The
contract never learns that a credit bought snow clearing. It records only that a
redemption happened and which booking it referenced. That keeps personal and
commercial data off a public ledger while preserving auditability.

### 6.7 Errors

```solidity
error ZeroAddress();
error ZeroAmount();
error TransfersDisabled();
error ApprovalsDisabled();
error InsufficientCredits(uint256 balance, uint256 required);
error InvalidServiceRef();
```

Plus inherited: `ERC20ExceededCap`, `ERC20InsufficientBalance`,
`AccessControlUnauthorizedAccount`.

Custom errors cost meaningfully less gas than `require` strings and carry structured
data the frontend decodes into a sentence. `InsufficientCredits(120, 250)` becomes
*"That service needs 250 credits. Mom has 120."*

### 6.8 Constructor and deployment invariants

```solidity
constructor(string memory name_, string memory symbol_, uint256 cap_, address admin)
    ERC20(name_, symbol_)
    ERC20Capped(cap_)          // reverts on cap == 0
{
    if (admin == address(0)) revert ZeroAddress();
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
}
```

The deploy script asserts, after deployment:

1. `cap()` equals the intended value
2. `totalSupply() == 0`
3. The intended admin holds `DEFAULT_ADMIN_ROLE`
4. No unintended address holds `ISSUER_ROLE`
5. No unintended address holds `PROVIDER_ROLE`

⚠️ The deployer does **not** automatically receive `ISSUER_ROLE`. A deploy script that
silently grants the wrong role is one of the most common real-world failures, which
is why the script has its own test suite.

---

## 7. Data architecture

### 7.1 Placement

| Data | Location | Reason |
|---|---|---|
| Credit balances | ⛓️ chain | Must be provable and unforgeable |
| Total supply, cap | ⛓️ chain | The cap is the core promise |
| Role assignments | ⛓️ chain | Permissions must be publicly auditable |
| Issue / redeem history | ⛓️ events | Tamper-proof audit trail |
| Service catalogue | 🗄️ database | Changes constantly |
| Prices | 🗄️ database | **Contracts are permanent; prices are not** |
| Bookings, schedules | 🗄️ database | High volume, no trust requirement |
| Provider profiles, checks | 🗄️ database | Personal data must never be public |
| Recipient name, address, phone | 🗄️ database | Privacy law vs immutable ledger |

**Rule:** nothing personally identifying ever touches the chain. A public ledger and
a right-to-erasure request cannot both be satisfied.

### 7.2 The pricing model

**1 credit = $1 CAD of value.** Services cost different numbers of credits, like an
arcade where the big ride takes four tokens.

| Service | Credits |
|---|---|
| Salting icy steps | 15 |
| Grocery delivery | 20 |
| Medical ride (one way) | 25 |
| Snow clearing (sidewalk) | 35 |
| Interpretation (1.5 hrs) | 70 |
| Gutter cleaning | 120 |

**Prices are resolved at redemption, never at purchase.** If snow clearing rises from
$35 to $45, it costs 45 credits that day. The family's credits keep their dollar
value; they simply cover fewer visits.

Without this rule, a season pass sold in October at October's prices becomes a
guaranteed loss in a hard February. Pre-selling fixed *services* transfers price risk
to the operator; selling fixed *value* does not.

### 7.3 Units

The contract stores 18-decimal integers. 300 credits is `300 * 10**18`.

- Never do decimal maths by hand
- Never `parseFloat` a chain value
- Read `decimals()` from the contract; do not hardcode 18
- All chain amounts are `bigint` in TypeScript — never mix with `number`
- Convert only at the UI boundary, with `formatUnits` / `parseUnits`

---

## 8. Frontend architecture

```
frontend/src/
├── abi/careCredits.ts        exported `as const`
├── config/
│   ├── chains.ts             Sepolia, RPC from env
│   ├── clients.ts            publicClient + walletClient
│   └── contracts.ts          address + ABI, typed
├── hooks/
│   ├── useWallet.ts          connect, account, chainId
│   ├── useNetworkGuard.ts    wrong-chain detection + switch
│   ├── useTokenInfo.ts       name, symbol, decimals, cap, totalSupply
│   ├── useBalance.ts         balanceOf
│   ├── useRoles.ts           hasRole → drives which UI renders
│   ├── useIssueCredits.ts    simulate → write → wait
│   └── useRedeem.ts          simulate → write → wait
├── lib/
│   ├── format.ts             formatUnits / parseUnits wrappers
│   ├── errors.ts             contract errors → human sentences
│   └── credits.ts            credit ↔ CAD display
├── components/               presentational only
├── pages/                    route-level screens
└── styles/tokens.css         design tokens
```

### 8.1 Two clients

| Client | Purpose | Signature | Gas |
|---|---|---|---|
| `publicClient` | Reads — balances, cap, roles | ❌ | ❌ Free |
| `walletClient` | Writes — issue, redeem | ✅ | ✅ Costs |

### 8.2 The `as const` ABI

Not a style choice. With `as const`, `writeContract({ functionName: 'issue', args })`
type-checks the argument list against the ABI. Without it, TypeScript sees a plain
array and every argument becomes `any` — losing the main reason to use viem.

### 8.3 Write lifecycle

Every write is three steps, and step 1 is never skipped:

```
simulateContract   →  rehearse. If it would revert, find out BEFORE
                      asking the user to sign and pay for a doomed tx
writeContract      →  wallet prompts, user signs, tx broadcasts
waitForReceipt     →  wait for inclusion; check receipt.status
```

UI states: `idle → simulating → awaiting signature → pending → confirmed`, with
`failed` reachable from any of them.

### 8.4 Three applications, one codebase

| App | Audience | Wallet | Constraints |
|---|---|---|---|
| Family dashboard | Funder | ✅ | Full data, mobile-first |
| Senior view | Recipient | ❌ | 24px+ text, 64px targets, max 4 choices, **no numbers, no currency** |
| Provider console | Provider | ✅ | Jobs, completion, earnings |

The senior view shares only brand tokens. It deliberately does not share layout,
navigation, or information density.

---

## 9. Off-chain services

Mocked in v1. Documented so the boundary is explicit.

| Service | Responsibility |
|---|---|
| Catalogue | Service definitions, categories, descriptions |
| Pricing | Current credit cost per service, resolved at redemption |
| Booking | Requests, scheduling, provider assignment, status |
| Provider registry | Profiles, background checks, insurance, ratings |
| Completion | Photo evidence, confirmation, dispute window |
| Redemption trigger | Calls `redeem()` after confirmed completion |
| Payout | CAD payment to providers |
| Notification | SMS/voice to the recipient, push to the family |

**The redemption trigger is the critical component.** It is the bridge between "a
service happened in the physical world" and "credits are burned on-chain." It is a
trusted oracle. See [§11 TB4](#11-trust-boundaries-and-threat-model).

---

## 10. Sequence flows

### 10.1 Family adds credits

```
Funder        Frontend         Wallet          Contract
  │              │                │                │
  │ choose 300   │                │                │
  ├─────────────►│                │                │
  │              │ simulateContract│               │
  │              ├────────────────┼───────────────►│  would this revert?
  │              │◄───────────────┼────────────────┤  no
  │              │ writeContract  │                │
  │              ├───────────────►│                │
  │ approve      │                │                │
  ├──────────────┼───────────────►│                │
  │              │                ├───────────────►│  issue(mom, 300e18)
  │              │                │                │  onlyRole(ISSUER_ROLE)
  │              │                │                │  _mint → _update
  │              │                │                │  ERC20Capped: cap check
  │              │                │                │  emit CreditsIssued
  │              │ waitForReceipt │                │
  │              ├────────────────┼───────────────►│
  │ "300 added"  │◄───────────────┼────────────────┤  confirmed
  │◄─────────────┤                │                │
```

### 10.2 Recipient requests a service

```
Recipient taps "I need a ride"
     │
     ▼
Senior app → off-chain API
     │            ├─ read balanceOf on-chain (free, no signature)
     │            ├─ look up today's price: 25 credits
     │            ├─ sufficient? yes
     │            └─ assign provider, create booking
     ▼
"Done! Sarah will call you within an hour."

NO wallet. NO signature. NO gas. NO number shown.
NOTHING WRITTEN TO THE CHAIN.
```

Credits move on **completion**, not on request. A request that is never fulfilled
costs the family nothing.

### 10.3 Provider completes, credits burn

```
Provider marks complete + uploads photo
     │
     ▼
Off-chain API validates the booking and the provider
     │
     ▼
redeem(recipient, 25e18, keccak256(bookingId))
     ├─ onlyRole(PROVIDER_ROLE)
     ├─ balance check → InsufficientCredits if short
     ├─ _burn → _update (to == address(0), allowed)
     └─ emit CreditsRedeemed
     │
     ▼
Frontend watches the event → activity feed updates
Provider payout queued off-chain in CAD
```

### 10.4 Operator grants a provider role

```
Admin wallet → grantRole(PROVIDER_ROLE, providerAddress)
     ├─ onlyRole(DEFAULT_ADMIN_ROLE)
     └─ emit RoleGranted

Revocation is the same call in reverse and takes effect immediately.
Role changes are public — anyone can audit who can redeem.
```

---

## 11. Trust boundaries and threat model

```
╔════════════════════════════════════════════════════════════════════╗
║ TB1  Browser ↔ Wallet                                              ║
║ The app never sees a private key; it requests signatures.          ║
║ Threat:  a malicious page requests an unexpected signature.        ║
║ Control: simulate first; show precisely what will happen.          ║
╠════════════════════════════════════════════════════════════════════╣
║ TB2  Wallet ↔ Chain                                                ║
║ A signed transaction is public in the mempool before mining.       ║
║ Threat:  front-running, MEV.                                       ║
║ Assessment: LOW — no price, no auction, no ordering advantage.     ║
╠════════════════════════════════════════════════════════════════════╣
║ TB3  Frontend ↔ Contract                                           ║
║ The frontend is ADVISORY. Anyone can call the contract directly.   ║
║ ⚠️ ALL SECURITY LIVES IN THE CONTRACT.                             ║
║ Threat:  assuming a hidden button is access control.               ║
║ Control: every restriction enforced by onlyRole on-chain.          ║
╠════════════════════════════════════════════════════════════════════╣
║ TB4  Physical world ↔ Chain   ← THE HONEST WEAK POINT              ║
║ Someone must attest that a service actually happened.              ║
║ That someone is the operator. This is a trusted oracle.            ║
║ Blockchain does NOT remove this trust. It only makes the           ║
║ resulting credit movements publicly auditable.                     ║
║ Control: dispute window, photo evidence, revocable roles,          ║
║          public event log. Mitigation, not elimination.            ║
╚════════════════════════════════════════════════════════════════════╝
```

**TB4 is the mature part of this design.** Every real-world-asset system has it.
Naming it earns credibility; claiming to be "fully trustless" loses it.

### Threat register

| # | Threat | Likelihood | Impact | Control |
|---|---|---|---|---|
| T1 | Admin key compromised | Low | **Critical** | Roles revocable; admin cannot mint directly; §19 documents the escalation path |
| T2 | Issuer key compromised | Low | High | Bounded by the cap; role revocable; every mint emits an event |
| T3 | Provider over-redeems | Medium | High | Operator holds the role in v1; dispute window; ADR-004 |
| T4 | Recipient socially engineered | **High** | Low | ✅ **Eliminated by design** — credits are non-transferable and non-cashable |
| T5 | Frontend serves a wrong address | Low | High | Address from env, verified on Etherscan, checked in CI |
| T6 | Wrong-network transaction | Medium | Low | Network guard blocks writes before signature |
| T7 | Personal data exposed on-chain | Low | **Critical** | No PII on-chain, by architecture. `serviceRef` is a hash. |
| T8 | Cap set wrong at deploy | Low | **Critical** | Immutable — unfixable. Deploy-script tests + 5 post-deploy assertions. |

T4 is worth pausing on. The most likely attack on this user base is a phone call
convincing an elderly person to send everything to a stranger. The architecture makes
that attack return nothing but a voucher for a snow clearing.

---

## 12. Security architecture

### Controls by layer

| Layer | Control |
|---|---|
| Contract | `onlyRole` on every state-changing function |
| Contract | `_update` override — one choke point for all balance changes |
| Contract | `immutable` cap enforced by audited `ERC20Capped` |
| Contract | Custom errors carrying data, no silent failures |
| Contract | Events on every privileged action |
| Contract | Zero-address and zero-amount validation on every input |
| Deployment | Encrypted keystore, never a raw key in a file |
| Deployment | Five post-deploy assertions |
| Deployment | Source verified on Etherscan |
| Frontend | Network guard before every write |
| Frontend | `simulateContract` before every write |
| Frontend | Role-gated UI from an on-chain `hasRole` read, never hardcoded |
| Frontend | No secrets in client code |
| Repository | `.env` gitignored; hook blocks secret-carrying commits |
| Repository | Slither in CI |
| Process | Two-agent review — security and quality — on every feature |

### What is NOT claimed

- ❌ Not audited
- ❌ Not formally verified
- ❌ Not production-ready
- ❌ Not trustless — see TB4
- ✅ Tested, reviewed, and honestly documented

---

## 13. Test architecture

```
        ▲ fewer · slower · broader
        │
  ┌─────────────────────────┐
  │ Frontend integration    │  mocked transport, full write lifecycle
  ├─────────────────────────┤
  │ Frontend unit           │  format, error mapping, credit maths
  ├─────────────────────────┤
  │ Deploy script tests     │  the script itself, and its 5 assertions
  ├─────────────────────────┤
  │ Invariant + handler     │  ⭐ 256 runs × 128 calls
  ├─────────────────────────┤
  │ Fuzz                    │  1000 random inputs per property
  ├─────────────────────────┤
  │ Unit                    │  one behaviour each, derived from the spec
  └─────────────────────────┘
        │
        ▼ many · fast · narrow
```

### The five invariants

1. `totalSupply() <= cap()`
2. Sum of all balances equals `totalSupply()`
3. No address without `ISSUER_ROLE` ever increased supply
4. A recipient's balance changes only via issue or redeem
5. Redeemed credits are burned, never transferred

The **handler contract** bounds the fuzzer to realistic action sequences. Without it,
the fuzzer spends its runs on calls that revert instantly and tests nothing.

Every feature is additionally tested across seven categories: happy path, validation,
error semantics, edge cases, auth guard, side effects, render states.

---

## 14. Deployment architecture

```
LOCAL                    TESTNET                    (never)
┌──────────┐            ┌──────────────┐          ┌──────────┐
│  Anvil   │ ─promote─► │   Sepolia    │ ──✗───►  │ Mainnet  │
│ instant  │            │ real network │          │ OUT OF   │
│ free     │            │ free ETH     │          │  SCOPE   │
│ 10 keys  │            │ Etherscan    │          └──────────┘
└──────────┘            └──────────────┘
```

| Environment | Keys | Purpose |
|---|---|---|
| Anvil | Built-in, publicly known, worthless | Fast iteration, script testing |
| Sepolia | Encrypted Foundry keystore | Verification, demo, portfolio |
| Mainnet | — | Out of scope, permanently |

**Key handling:** `cast wallet import carecredits-deployer --interactive`. The `.env`
holds the account *name*, never the key. The wallet is created solely for this
project and has never held real value.

**Immutability consequence:** there is no patch. A mistake means redeploying and
updating the frontend address. Say this out loud before every deployment.

---

## 15. Observability

Events are the data layer. There is no separate logging system.

| Question | Answered by |
|---|---|
| What did this family fund? | `CreditsIssued` filtered by `issuer` |
| What has this recipient used? | `CreditsRedeemed` filtered by `from` |
| Which provider did what? | `CreditsRedeemed` filtered by `provider` |
| Who can currently issue? | `RoleGranted` / `RoleRevoked` |
| How much liability is outstanding? | `totalSupply()` |
| How much can still be created? | `cap() - totalSupply()` |

v1 queries logs directly through viem. A subgraph is a v2 concern (§20) and only
becomes necessary once log volume makes direct queries slow.

---

## 16. Failure modes

| Failure | Effect | Response |
|---|---|---|
| RPC provider down | Reads fail, writes fail | Fallback RPC; UI shows a connection banner |
| User rejects signature | Nothing happens | "You cancelled the transaction." Return to idle. |
| Transaction reverts | No state change, gas spent | Decode the error, show a plain sentence, offer retry |
| Wrong network | Write blocked before signature | Network guard + one-click switch |
| Cap reached | `issue` reverts | Show remaining issuable; deploy a v2 contract if genuinely exhausted |
| Off-chain API down | Requests and bookings fail | Balances still readable on-chain — a real benefit of the split |
| Operator ceases trading | No new services | Balances remain provable on-chain; another operator could resume |
| Admin key lost | Roles frozen as-is | Existing issuers and providers keep working; no new grants. Unrecoverable. |
| Provider key compromised | Unauthorised redemptions | Revoke the role immediately; dispute window; reissue affected credits |

---

## 17. Performance and scale

**v1 is not scale-constrained.** Sepolia, a demo dataset, no real load.

Where limits would appear first:

| Constraint | First bites at | Path |
|---|---|---|
| Gas cost per redemption | Every redemption on L1 | Move to Base or Arbitrum |
| Event query time | ~10k events | Subgraph or an indexer |
| One tx per redemption | High volume | Batch redemptions per provider per day |
| RPC rate limits | Many concurrent users | Caching layer, paid tier |

**L2 is the natural v2 move.** The contract is chain-agnostic; only `chains.ts` and
the deployment change. Base or Arbitrum reduce per-redemption cost by roughly two
orders of magnitude, which matters when the underlying service is worth $25.

---

## 18. Architecture decision records

### ADR-001 — AccessControl instead of Ownable
**Status:** Accepted
**Context:** Multiple people must be able to issue credits, and that permission must
be revocable when someone leaves.
**Decision:** OpenZeppelin `AccessControl` with three roles.
**Alternatives:** `Ownable` (one key, all powers); `Ownable2Step` (safer transfer,
still one key).
**Consequences:** More setup and a more complex deployment. Gains least privilege and
revocability. Deploy-script tests exist specifically to verify role assignment.

### ADR-002 — No Pausable
**Status:** Accepted
**Context:** Pausable is conventional in token contracts.
**Decision:** Excluded.
**Rationale:** Pausing would freeze a vulnerable person's access to help. That is a
serious power with no requirement behind it. A credit token with no market and no
exploit-response scenario does not justify it.
**Consequences:** No emergency stop. Accepted — the mitigation is role revocation.

### ADR-003 — No upgradeability
**Status:** Accepted
**Decision:** No proxy pattern. The contract is immutable.
**Rationale:** A proxy admin who can silently replace all logic destroys the trust
argument in §2 entirely. Immutability is the product.
**Consequences:** Bugs require redeployment and migration. Accepted, and it raises the
bar on testing — which is the point.

### ADR-004 — Operator holds PROVIDER_ROLE in v1
**Status:** Accepted, revisit in v2
**Context:** `redeem` burns from a recipient's balance. Giving each provider the role
would let a malicious provider over-redeem. The clean fix is EIP-712 signed
authorisation from the recipient — but the recipient has no wallet, by design (P3).
**Decision:** In v1 the operator holds `PROVIDER_ROLE` and calls `redeem` only after
confirming completion off-chain.
**Consequences:** A real trust assumption, documented in §11 TB4 and §19. v2 path:
operator-countersigned EIP-712 redemptions with per-provider limits and a dispute
window.

### ADR-005 — Do not inherit ERC20Burnable
**Status:** Accepted *(revised — earlier drafts included it)*
**Context:** `ERC20Burnable` adds public `burn()` and `burnFrom()`.
**Decision:** Not inherited. `redeem` calls the internal `_burn` directly.
**Rationale:** Public `burn()` would let a recipient destroy their own credits with no
service received — a support burden and a confusing UI surface. `burnFrom()` requires
`approve()`, which we disable anyway. We need only the internal `_burn` that `ERC20`
already provides.
**Consequences:** Less public surface, less to audit, less to explain. No loss of
capability.

### ADR-006 — Prices resolved at redemption
**Status:** Accepted
**Decision:** A credit is one dollar of value, not one unit of a service. Prices are
looked up when the service is redeemed.
**Rationale:** Selling fixed *services* in advance transfers price risk to the
operator. One hard winter of rising contractor rates would be enough to make
pre-sold season passes unprofitable.
**Consequences:** The family's credits cover fewer visits when prices rise. Their
dollar value is unchanged. This must be stated plainly in the UI.

### ADR-007 — No personal data on-chain
**Status:** Accepted
**Decision:** `serviceRef` is `keccak256(bookingId)`. No names, addresses, phone
numbers, or service descriptions are ever written on-chain.
**Rationale:** A public immutable ledger and privacy law with a right to erasure
cannot both be satisfied.
**Consequences:** Reading the chain alone does not reveal what a credit purchased.
That requires the off-chain booking record — which is correct.

### ADR-008 — ERC20Capped rather than a hand-rolled cap
**Status:** Accepted
**Decision:** Inherit OpenZeppelin `ERC20Capped`.
**Rationale:** Audited code, and the check lives inside `_update` — exactly the choke
point we already override. Hand-rolling risks missing a mint path.
**Consequences:** Adds a base contract to the linearization; `_update` must call
`super._update` so the cap check still runs. Requires verifying v5 error names.

---

## 19. Known limitations

Stated plainly. This section is the most valuable part of the document.

1. **The completion oracle is trusted.** Someone must attest that a service happened.
   The blockchain makes the *consequences* auditable, not the *attestation* true.
2. **The operator can redeem from any recipient (v1).** Holding `PROVIDER_ROLE`, the
   operator could burn credits without a service. Mitigated by public events, a
   dispute window, and role revocability — not eliminated. (ADR-004)
3. **Admin escalation is possible.** `DEFAULT_ADMIN_ROLE` cannot mint, but it can
   grant itself `ISSUER_ROLE` and then mint to the cap. Separation of duties here is
   procedural, not cryptographic. A v2 fix is a timelock or multisig on role grants.
4. **The cap is unfixable if set wrong.** Immutable means immutable. Only a redeploy
   corrects it.
5. **No recovery for a lost recipient account.** Since the recipient has no wallet,
   their balance is tied to an address the operator controls on their behalf. That is
   custodial, and it is a trade-off P3 makes knowingly.
6. **Frontend correctness is not enforced.** A wrong contract address in the build
   would point users at the wrong contract. CI checks it; nothing on-chain can.
7. **Not audited.** Reviewed by two agents and by me. That is a habit, not an audit.
8. **Testnet only.** Nothing here has been exercised under real economic incentives,
   which is the only true test of a token system.

---

## 20. Future architecture (v2)

| Item | Why | Complexity |
|---|---|---|
| EIP-712 signed redemptions | Removes the over-redemption trust assumption (ADR-004) | High |
| Timelock or multisig on role grants | Closes the admin escalation path (§19.3) | Medium |
| L2 deployment (Base / Arbitrum) | ~100× cheaper per redemption | Low |
| Subgraph indexing | Fast history at volume | Medium |
| Embedded wallets for funders | Removes MetaMask from onboarding | Medium |
| Gas sponsorship (meta-transactions) | Funder never holds ETH | Medium |
| Batched redemptions | One tx per provider per day | Medium |
| Per-provider redemption limits | Bounds the damage from a compromised provider | Low |
| Dispute resolution on-chain | Currently entirely off-chain | High |

Each of these should get its own ADR when it is actually built. None are in v1.

---

## 21. Glossary

| Term | Meaning |
|---|---|
| **Credit** | One unit of the CareCredits token. Worth $1 CAD of service value. |
| **Cap** | The immutable maximum number of credits that can ever exist. |
| **Issue** | Creating credits. Mints. Restricted to `ISSUER_ROLE`. |
| **Redeem** | Consuming credits on service completion. Burns. Restricted to `PROVIDER_ROLE`. |
| **Funder** | The family member who pays. |
| **Recipient** | The elderly parent who receives services. Holds the balance, holds no wallet. |
| **Provider** | The vetted local worker who performs a service. |
| **Operator** | The platform. Holds `DEFAULT_ADMIN_ROLE`. |
| **serviceRef** | `keccak256(bookingId)` — an on-chain pointer to an off-chain booking. |
| **Invariant** | A property that must hold after any sequence of valid actions. |
| **Handler** | A test contract that bounds the fuzzer to realistic action sequences. |
| **`_update`** | OpenZeppelin 5's single hook through which every balance change passes. |

---

## Change log

| Date | Change |
|---|---|
| 2026-08-14 | Initial architecture. ADR-001 to ADR-008. |
