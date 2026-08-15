# Session Log

Append-only. Newest entry at the bottom.
Never edit or delete an earlier entry.

## Session 01 — Repository bootstrap (2026-08-14)

**Goal:** Restructure the Foundry starter into the CareCredits monorepo and install Claude Code tooling.

**Completed:**
- Deleted Counter template files (src/Counter.sol, test/Counter.t.sol, script/Counter.s.sol)
- Restructured into monorepo layout: moved src/, test/, script/, lib/, and foundry.toml into contracts/
- Created test subdirectory structure (test/{unit,fuzz,invariant/handlers,script})
- Created frontend/.gitkeep placeholder
- Updated .gitignore with build artifacts, env files, and OS artifacts
- Created contracts/.env.example with documented (empty) environment variables
- Installed OpenZeppelin contracts v5.7.0 as a git submodule
- Configured contracts/foundry.toml with Solidity 0.8.25, optimizer settings, and test parameters
- Generated contracts/remappings.txt for library import resolution
- Verified design/ export is populated with Stitch output
- Created .claude/ directory structure with agents/, skills/, commands/, hooks/ subdirectories
- Created .claude/settings.json with permission deny/allow lists (no hooks block yet — will add after files are in place)

**Exit criteria met:**
- ✅ forge build succeeds from contracts/ (no contracts yet, expected output)
- ✅ No Counter files remain
- ✅ git status shows no .env, out/, cache/, broadcast/ staged
- ✅ contracts/.env.example exists with empty values
- ✅ contracts/remappings.txt exists

**Handoff notes for Session 02:**
- OpenZeppelin version installed: **v5.7.0**
- .claude/settings.json permissions are configured but will take effect after Claude Code restarts
- Hooks configuration in settings.json should be added once hook scripts are ready
- All foundry dependencies (forge-std, OpenZeppelin) are git submodules tracked in lib/
- Monorepo structure ready for contract and frontend development

## Session 02 — Design system application (2026-08-14)

**Goal:** Apply the design system — Tailwind theme, CSS tokens, local images, and the six project Skills.

**Completed:**
- Ran `scripts/fetch-design-assets.sh`: 10 of 10 Stitch-hosted images downloaded, 0 failures
- Deduped 2 byte-identical pairs (logo used twice, caregiver headshot reused as generic avatar placeholder), leaving 8 unique images renamed meaningfully: `logo.jpg`, `hero-network.jpg`, `caregiver-headshot.jpg`, `margaret-portrait.jpg`, `provider-jobs-map.png`, `snow-clearing-completed.jpg`, `snow-clearing-service-illustration.jpg`, `snow-falling-illustration.jpg`
- Wrote `frontend/tailwind.config.ts` verbatim from §6 of `docs/DESIGN-SYSTEM.md` (diffed to confirm exact match)
- Wrote `frontend/src/styles/tokens.css`: CSS custom properties for all design tokens, Google Fonts import (Space Grotesk + Inter), `prefers-reduced-motion` block
- Wrote `frontend/src/styles/base.css`: tokens import, Tailwind directives, body defaults (cream background, Inter 17px, ink text), global `:focus-visible` ring (2px `#006A62`, 2px offset), `.tabular` utility
- Used the `skill-writer` subagent to generate six Skills into `.claude/skills/`: `solidity-house-style` (94 lines), `foundry-test-patterns` (103 lines), `viem-tx-lifecycle` (83 lines), `carecredits-ux-copy` (81 lines), `session-handoff` (68 lines), `deploy-runbook` (89 lines) — all under the 150-line cap
- Saved the session plan to `.claude/plans/02-design-system.md`

**Exit criteria met:**
- ✅ All design images downloaded locally and meaningfully named (8 unique, 2 duplicates removed)
- ✅ `tailwind.config.ts` matches §6 of the design system doc (verified via diff)
- ✅ `tokens.css` and `base.css` written
- ✅ Six Skills generated, each under 150 lines
- ✅ Nothing outside the OWNS list was modified (verified via `git status`)
- ✅ No `.env` or `node_modules/` in git status

**Handoff notes for Session 03:**
- **10 of 10** images rescued from Stitch's expiring URLs; 8 unique files remain in `frontend/public/img/` after deduping 2 identical pairs
- The six Skills are: `solidity-house-style`, `foundry-test-patterns`, `viem-tx-lifecycle`, `carecredits-ux-copy`, `session-handoff`, `deploy-runbook` — read them, do not regenerate them (`skill-writer` is a one-time-use subagent per its own instructions)
- Still needs a human decision: the `skill-writer` agent flagged that `contracts/.env.example` doesn't exist yet, so the exact Etherscan API key env var name used in `deploy-runbook` (`$ETHERSCAN_API_KEY`) should be confirmed once that file is created
- `frontend/` has no scaffold yet (no `package.json`, no Vite setup) — only `tailwind.config.ts`, `src/styles/`, and `public/img/` exist so far; scaffolding the actual app is out of this session's scope

## Session 03 — Contract specification (2026-08-14)

**Goal:** Decide and document every contract rule before any Solidity exists.

**Completed:**
- Read `docs/REQUIREMENTS.md` §4/§11/§13/§17 and `docs/ARCHITECTURE.md` §6/§7/§11/§12/§13/§18/§19; reported six disagreements between the two documents rather than silently picking one
- Settled the six briefed decisions (D-1…D-6) plus two that the documents left open (D-7, D-8) — all eight recorded in the spec with rationale
- Used the `spec-writer` subagent to write `specs/contract/carecredits-token.md` (197 lines, 17 sections)
- Built a 48-row acceptance-criteria table: 37 unit, 3 script, 3 fuzz, 5 invariant — every row has a concrete test function name
- Verified the OpenZeppelin v5.7.0 error names ARCHITECTURE §6.1 flagged as version-sensitive: `ERC20ExceededCap(increasedSupply, cap)`, `ERC20InvalidCap(cap)`, `ERC20InsufficientBalance(sender, balance, needed)`, `AccessControlUnauthorizedAccount(account, neededRole)`
- Found and documented two ordering traps in the OZ 5.x sources (see handoff notes)
- Wrote no code — no `.sol` file anywhere in the diff

**Exit criteria met:**
- ✅ All six briefed decisions answered by the user and recorded in the spec (plus D-7 and D-8, which the source documents left undefined)
- ✅ `specs/contract/carecredits-token.md` exists, 197 lines (limit 200)
- ✅ All 24 FR-C-01…24 requirements appear in the acceptance criteria table — verified by grep, none missing
- ✅ Every one of the 48 acceptance criteria has a concrete test function name — 48 rows, 48 unique names
- ✅ Six of seven test categories appear; **Render states** is absent and justified in writing (a contract has no UI; render states live in the FR-F/FR-S/FR-P suites)
- ✅ Each of the five invariants has an explicit assertion and an `invariant_` function name
- ✅ Trust assumptions and known limitations stated without softening, including the operator's redemption power and admin escalation
- ✅ No code written — `git status` shows zero `.sol` files
- ✅ `./scripts/verify.sh` passed — secrets, tracked build output, `forge fmt --check`, `forge build`
- ⚠️ verify.sh skipped its test stage (no `.t.sol` files exist yet) and its frontend typecheck (no `frontend/package.json` yet). Neither was run, so neither is claimed.

**Handoff notes for Session 04:**
- **Symbol is `CCRD`, not `CARE`. Cap is 100,000,000 (`100_000_000e18`), not 10,000,000.** `docs/REQUIREMENTS.md` FR-C-01 and OQ-02 still say `CARE` / 10,000,000 and are now **stale** — that file was read-only this session. The spec is authoritative; REQUIREMENTS.md must be corrected in a later session (OQ-D). A builder who follows the wrong document ships the wrong immutable cap.
- The eight decisions: D-1 symbol `CCRD` · D-2 cap 100,000,000 · D-3 partial redemption **reverts** (all-or-nothing) · D-4 one funder → many recipients is allowed **implicitly** and is an explicit NON-requirement · D-5 `PROVIDER_ROLE` goes to the operator **plus exactly one labelled demo-provider address**, both granted by the deploy script · D-6 `serviceRef` must be non-zero, else `InvalidServiceRef()` · D-7 over-redemption reverts the custom `InsufficientCredits(balance, required)` via an **explicit pre-check**, not the inherited `ERC20InsufficientBalance` · D-8 `redeem` validates both zero holder (`ZeroAddress()`) and zero amount (`ZeroAmount()`).
- **Acceptance-criteria count: 48** (AC-01…AC-48). AC-01…AC-24 map one-to-one onto FR-C-01…FR-C-24. AC-25…AC-40 are derived from the decisions and from gaps in FR-C. AC-41…AC-48 are fuzz and invariant.
- **Trap 1 — `transferFrom` needs its own override.** ARCHITECTURE §6.5 claims one `_update` override covers `transfer` and `transferFrom`. Verified false for the *error identity*: OZ v5.7.0 `transferFrom` calls `_spendAllowance` before `_transfer`, and since `approve` always reverts every allowance is 0 — so a non-zero `value` reverts `ERC20InsufficientAllowance(spender, 0, value)` and never reaches `_update`, while `value == 0` reverts `TransfersDisabled()`. FR-C-14 demands `TransfersDisabled()` every time, so `transferFrom` must revert in its own override.
- **Trap 2 — `_update` ordering.** `ERC20Capped._update` calls `super._update` FIRST and checks the cap AFTER. The override must place the transfer rejection BEFORE `super._update`. No named test distinguishes the two orderings — a reviewer has to read the override.
- **Constructor ordering:** `ERC20Capped(cap_)` runs before the constructor body, so with both `cap_ == 0` and `admin == address(0)` the revert is `ERC20InvalidCap(0)`, not `ZeroAddress()`. `test_Constructor_RevertsWhen_AdminIsZeroAddress` must pass a valid cap.
- **Every FR-C requirement turned into a test name.** FR-C-16 was the only one that resisted a single name — it hides two requirements ("grant **and** revoke") and covers two roles, so it was split across AC-16, AC-25 and AC-26.
- Four open questions still need your decision, recorded in §16 of the spec: **OQ-A** which addresses are the operator and the demo provider (blocks AC-40) · **OQ-B** whether `renounceRole` gets its own acceptance row · **OQ-C** whether one address may hold both `ISSUER_ROLE` and `PROVIDER_ROLE` · **OQ-D** when REQUIREMENTS.md is corrected.
- The session plan is saved at `.claude/plans/03-contract-spec.md`, matching the Session 02 convention.
