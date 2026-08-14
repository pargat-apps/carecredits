# CareCredits

Educational portfolio project. **Testnet only.** No real funds, no real users, no real
service providers. This project is never deployed to mainnet.

## What this is

Families — living abroad or elsewhere in Canada — prepay service credits for an
elderly parent living in Canada. The parent redeems them for trusted local services:
snow clearing, medical rides, groceries, house cleaning, government paperwork help,
medical interpretation, technology help, scam-call checks.

**The parent never handles money.**

- 1 CareCredit = $1 CAD of service value
- Pilot city: Ottawa, Ontario
- Flow: family buys credits → parent requests a service → provider completes it → credits are burned

## Why this uses a blockchain

Four reasons. Everything else in the product is ordinary web development.

1. Credits can **never convert back to cash** — enforced by code, not by a promise
2. The supply cap **cannot be exceeded** by anyone, including the operator
3. The record **survives** even if the company does not
4. For overseas funders, value arrives in Canada in minutes without a bank

## The rule that protects the recipient

The elderly parent **never** holds a wallet, signs a transaction, pays gas, sees a
credit number, or sees a dollar amount. Their app is a thin client over the backend.

This is a safety property, not a UX preference. Older adults are the most heavily
targeted group for financial fraud. A credit that cannot be transferred or cashed
out is worthless to a scammer.

**Any feature that breaks this is wrong. Say so and stop.**

## Stack

- Solidity 0.8.x · Foundry · OpenZeppelin 5.x
- React · TypeScript · Vite · viem · Tailwind
- Vitest · Testing Library — **never Python, pytest, Flask or unittest**
- Chain: Sepolia. Local: Anvil.

## How I work

- I am learning blockchain development. Explain before writing code.
- Use plan mode for any design decision. Get my approval before implementing.
- Do not write contracts or tests unless I explicitly ask.
- One spec per session. Read `specs/<current>.md` and the last `SESSION-LOG` entry only.
- Never install a package without asking first.

## Hard rules

- **NEVER** read `design/**/code.html` — use `docs/DESIGN-SYSTEM.md` instead
- Secrets live in `.env`, which is gitignored. Never commit a key or seed phrase.
- Private keys go in Foundry's encrypted keystore, never in any file
- Follow `docs/ARCHITECTURE.md`. If a change requires breaking it, stop and say so.
- Add nothing the spec did not ask for
- Never modify a test to make code pass
- **Never claim the contract is secure.** It is unaudited educational code.

## The five invariants

Every change must preserve all five:

1. `totalSupply() <= cap()`
2. Sum of all balances equals `totalSupply()`
3. Only `ISSUER_ROLE` ever increases supply
4. A recipient's balance changes only by issue or redeem
5. Redeemed credits are burned, never transferred

## Layout

```
contracts/   Foundry — src, test/{unit,fuzz,invariant,script}, script
frontend/    Vite + React + TypeScript
specs/       one spec per session or feature
docs/        ARCHITECTURE · REQUIREMENTS · DESIGN-SYSTEM · SECURITY-REVIEW ·
             DEPLOYMENTS · SESSION-LOG · TEST-LOG
design/      read-only Stitch export
```

## Detail lives elsewhere, on purpose

This file loads in **every** session, so it stays short. Specifics are here:

- `.claude/skills/` — house style, test patterns, viem lifecycle, UX copy, handoff format, deploy runbook
- `.claude/hooks/` — formatting, compile checks, secret blocking (automatic, not requested)
- `.claude/agents/` — spec writing, test writing, test running, security and quality review
- Commands — `/ship-feature` `/test-feature` `/code-review-feature` `/verify` `/handoff` `/audit`
