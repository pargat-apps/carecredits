# CareCredits — Session Map

**16 isolated sessions.** Each has one role, owns a specific set of paths, and may not
write anywhere else. This file is the ownership contract.

- **Project:** CareCredits · Ottawa, Ontario · testnet only
- **Launch a session:** `./scripts/cc.sh <id>`
- **Close a session:** `/handoff`

---

## Rules of isolation

Every session must follow all six. State them in each spec.

1. **Write only inside your OWNS list.** If a task requires writing outside it, stop and
   report — do not proceed. The next session owns that path.
2. **Read freely inside your READS list. Read nothing else.** Especially not
   `design/**/code.html`, which is blocked at the permission layer.
3. **`docs/SESSION-LOG.md` is append-only.** Add your entry at the end. Never edit or
   delete an earlier entry — that is another session's record.
4. **`CLAUDE.md`, `docs/ARCHITECTURE.md` and `docs/REQUIREMENTS.md` are read-only for
   every session.** Changing them requires an explicit amendment session, not a
   drive-by edit.
5. **One branch per session:** `session/<id>`. Merge to `main` after `/handoff`.
6. **Never modify another session's tests to make your code pass.** If a test looks
   wrong, report it. Do not touch it.

---

## Path ownership map

| Path | Owned by | Notes |
|---|---|---|
| `CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/REQUIREMENTS.md` | **nobody** | Read-only. Amend deliberately. |
| `.gitignore`, `foundry.toml`, `remappings.txt`, `.env.example` | S01 | |
| `.claude/**` | S01 | Agents, skills, hooks, commands |
| `docs/DESIGN-SYSTEM.md`, `frontend/tailwind.config.ts`, `frontend/src/styles/**`, `frontend/public/img/**` | S02 | |
| `specs/**` | S03 | Later sessions read specs, never write them |
| `contracts/test/unit/**` | S04 | |
| `contracts/src/**` | S05 | S07 may patch **approved findings only** |
| `contracts/test/fuzz/**`, `contracts/test/invariant/**` | S06 | |
| `docs/SECURITY-REVIEW.md` | S07 | |
| `.gas-snapshot`, `contracts/test/unit/gaps/**` | S08 | Coverage-filling tests live in `gaps/` |
| `contracts/script/**`, `contracts/test/script/**` | S09 | |
| `docs/DEPLOYMENTS.md`, `contracts/.env` | S10 | `.env` is local only, never committed |
| `frontend/` root config, `frontend/src/components/**` | S11 | |
| `frontend/src/config/**`, `frontend/src/abi/**`, read hooks | S12 | |
| write hooks, `frontend/src/lib/**` | S13 | |
| `frontend/src/pages/senior/**`, `frontend/src/pages/provider/**` | S14 | |
| `frontend/**/__tests__/**`, `vitest.config.ts` | S15 | |
| `.github/workflows/**`, `README.md`, `SECURITY.md` | S16 | |
| `docs/SESSION-LOG.md` | **shared** | Append only |

---

# The 16 sessions

---

## S01 — `01-repo-bootstrap`

**Role:** Repository architect.

Establishes the skeleton the other fifteen sessions live inside. Creates the monorepo
layout, installs OpenZeppelin, configures Foundry, and places the Claude Code tooling —
agents, skills, hooks, commands. Deletes Foundry's sample files. Places the three
read-only foundation documents.

Nothing in this session is product logic. Get it right and every later session starts
clean; get it wrong and every later session inherits the mess.

- **Owns:** repo structure · `.gitignore` · `foundry.toml` · `remappings.txt` · `.env.example` · `.claude/**` · `docs/` scaffolding
- **Reads:** `CLAUDE.md`
- **Must not touch:** `contracts/src/` · `frontend/src/` · `specs/`
- **Model:** haiku · **Exit:** `forge build` passes, no `.env` tracked

---

## S02 — `02-design-system`

**Role:** Design system extractor.

The **only** session permitted near the raw design export, and only through the
`design-extractor` subagent. Reads 17 HTML screens once, emits a compact design system,
writes the Tailwind theme and CSS tokens, and downloads the Stitch-hosted images before
their URLs expire. Applies the Winnipeg → Ottawa replacements.

After this session, nobody reads the design HTML again. Everything downstream reads
`docs/DESIGN-SYSTEM.md`.

- **Owns:** `docs/DESIGN-SYSTEM.md` · `frontend/tailwind.config.ts` · `frontend/src/styles/**` · `frontend/public/img/**`
- **Reads:** `design/**` *(this session only)* · `docs/REQUIREMENTS.md`
- **Must not touch:** `contracts/**` · any `frontend/src` outside `styles/`
- **Model:** sonnet · **Exit:** design system under 250 lines, images local

---

## S03 — `03-contract-spec`

**Role:** Specification author.

Decides every contract rule before any code exists. Token identity, cap, the three
roles and their exact powers, non-transferability, issuance and redemption, custom
errors, constructor validation, trust assumptions — and acceptance criteria written as
test function names.

**Writes no code.** Runs in plan mode. Its output is the contract that S04 and S05 are
both held to.

- **Owns:** `specs/**`
- **Reads:** `docs/ARCHITECTURE.md` · `docs/REQUIREMENTS.md`
- **Must not touch:** `contracts/**` · `frontend/**`
- **Model:** opus · plan mode · **Exit:** every requirement has a test name

---

## S04 — `04-tests-first`

**Role:** Test author.

Turns the spec's acceptance criteria into Foundry unit tests. Every test derives from
the **spec**, never from an implementation — because tests written from code validate
the code's bugs along with its behaviour.

All tests will fail at the end of this session. That is the correct outcome.

- **Owns:** `contracts/test/unit/**`
- **Reads:** `specs/**` · `docs/ARCHITECTURE.md`
- **Must not touch:** `contracts/src/**` — **may not read it either**
- **Model:** sonnet · **Exit:** `forge build` passes, `forge test` fails as expected

---

## S05 — `05-contract-impl`

**Role:** Contract implementer.

Writes `CareCredits.sol` until every existing test passes. Nothing more. No function
the tests do not exercise, no convenience helper, no "might be useful later."

Every extra function is extra attack surface, extra gas, and one more thing to defend
in an interview.

- **Owns:** `contracts/src/**`
- **Reads:** `specs/**` · `contracts/test/unit/**` · `docs/ARCHITECTURE.md`
- **Must not touch:** any test file — **never edit a test to make code pass**
- **Model:** sonnet · MCP: context7 · **Exit:** all tests green, no untested function

---

## S06 — `06-fuzz-invariant`

**Role:** Property test designer.

Designs and builds the two test types that separate this repository from every tutorial
ERC-20: fuzz tests over properties, and invariant tests with a bounded handler that
keeps the fuzzer doing realistic things.

Establishes the five system invariants in plan mode before writing any code. An
invariant that cannot fail is worse than no invariant.

- **Owns:** `contracts/test/fuzz/**` · `contracts/test/invariant/**`
- **Reads:** `contracts/src/**` · `specs/**` · `docs/ARCHITECTURE.md`
- **Must not touch:** `contracts/src/**` · `contracts/test/unit/**`
- **Model:** opus · plan mode · **Exit:** both suites pass at configured run counts

---

## S07 — `07-security-review`

**Role:** Auditor.

Attacks the contract and documents what it finds. Runs Slither, applies a manual
checklist, and writes an honest security review including trust assumptions, the
completion-oracle problem, and known limitations.

**Reports before fixing.** Fixing while finding means you stop looking.

- **Owns:** `docs/SECURITY-REVIEW.md`
- **Reads:** `contracts/**` · `docs/ARCHITECTURE.md`
- **Conditional write:** `contracts/src/**` — **only** for findings you explicitly approve, one at a time, each logged
- **Must not touch:** `frontend/**` · any test file
- **Model:** opus · **Exit:** every finding fixed or justified in writing

---

## S08 — `08-gas-coverage`

**Role:** Coverage and gas analyst.

Measures rather than guesses. Finds untested lines and fills them, records gas per
function, and proposes optimisations with before/after numbers — never estimates.

Never trades a security check for gas.

- **Owns:** `.gas-snapshot` · `contracts/test/unit/gaps/**`
- **Reads:** `contracts/**`
- **Must not touch:** `contracts/src/**` · existing tests in `contracts/test/unit/`
- **Model:** haiku · **Exit:** coverage ≥95% on `src/`, snapshot committed

---

## S09 — `09-deploy-local`

**Role:** Deployment engineer, local.

Writes the deployment script **and its tests** — because a script that silently grants
the wrong role is one of the most common real-world failures. Deploys to Anvil and
verifies behaviour with `cast` before any real network is involved.

Also the session where `.env` is first created and confirmed untracked.

- **Owns:** `contracts/script/**` · `contracts/test/script/**`
- **Reads:** `contracts/src/**` · `specs/**`
- **Must not touch:** `contracts/src/**` · unit, fuzz or invariant tests
- **Model:** sonnet · **Exit:** deploys to Anvil, script tests pass, `.env` untracked

---

## S10 — `10-deploy-sepolia`

**Role:** Deployment engineer, testnet.

Deploys to Sepolia and verifies the source on Etherscan, then runs the five post-deploy
assertions. Records the address, block, transaction hash and constructor arguments.

🔒 Uses a wallet created solely for this project via Foundry's encrypted keystore.
`.env` holds the account **name**, never a key.

- **Owns:** `docs/DEPLOYMENTS.md` · `contracts/.env` *(local, never committed)*
- **Reads:** `contracts/**`
- **Must not touch:** any source or test file
- **Model:** sonnet · **Exit:** verified on Etherscan, all five assertions pass

---

## S11 — `11-fe-scaffold`

**Role:** Frontend foundation builder.

Creates the Vite + React + TypeScript app, wires Tailwind to the tokens from S02,
installs `lucide-react`, and builds the reusable component library plus a gallery page
showing every component in every state.

Builds from `docs/DESIGN-SYSTEM.md`, never from the design HTML. No component fetches
data — that boundary is what keeps the UI testable without a blockchain.

- **Owns:** `frontend/` root config · `frontend/src/components/**` · `frontend/src/pages/` shell
- **Reads:** `docs/DESIGN-SYSTEM.md` · `frontend/src/styles/**`
- **Must not touch:** `contracts/**` · `frontend/src/hooks/` · `frontend/src/config/`
- **Model:** sonnet · MCP: context7 · **Exit:** dev server runs, gallery matches tokens

---

## S12 — `12-fe-reads`

**Role:** Chain read integrator.

Connects the app to Sepolia for everything free: token metadata, cap, total supply,
balances, role checks. Sets up the viem public client, the `as const` ABI, the wallet
connection and the network guard.

Reads need no signature and cost nothing — this is the safe half of chain integration.

- **Owns:** `frontend/src/config/**` · `frontend/src/abi/**` · read hooks in `frontend/src/hooks/`
- **Reads:** `docs/DEPLOYMENTS.md` · `contracts/src/**` *(for the ABI)* · `frontend/src/components/**`
- **Must not touch:** `frontend/src/components/**` · write hooks
- **Model:** sonnet · MCP: context7 · **Exit:** live Sepolia data renders, wrong network blocked

---

## S13 — `13-fe-writes`

**Role:** Transaction flow engineer.

Implements everything that costs gas and needs a signature: the add-credits flow, the
redemption flow, and the full `simulate → write → wait` lifecycle with all five UI
states. Owns the error dictionary that turns contract reverts into plain sentences.

No hex, no selectors, no "user rejected transaction" ever reaches a user.

- **Owns:** write hooks in `frontend/src/hooks/` · `frontend/src/lib/**`
- **Reads:** `frontend/src/config/**` · `frontend/src/abi/**` · `contracts/src/**` *(for error names)*
- **Must not touch:** `frontend/src/config/**` · `frontend/src/components/**` · read hooks
- **Model:** sonnet · MCP: context7 · **Exit:** a real Sepolia transaction completes from the UI

---

## S14 — `14-fe-senior-provider`

**Role:** Specialist interface builder.

Builds the two audiences that are not the funder. The senior view — including the home
screen Stitch never generated — is governed by hard constraints: 24px+ text, 64px
targets, maximum four choices, and no numbers or currency anywhere.

Those are safety requirements, not styling preferences. Ends with a real accessibility
audit, including keyboard navigation and 200% zoom in an actual browser.

- **Owns:** `frontend/src/pages/senior/**` · `frontend/src/pages/provider/**`
- **Reads:** `docs/DESIGN-SYSTEM.md` · `frontend/src/components/**` · `frontend/src/hooks/**`
- **Must not touch:** `frontend/src/components/**` · hooks · config
- **Model:** sonnet · MCP: playwright · **Exit:** both keyboard-usable, AA contrast verified

---

## S15 — `15-fe-tests`

**Role:** Frontend test author.

Applies the same discipline used on the contract to the interface. Unit tests for
formatting, error mapping and credit maths; integration tests with a mocked viem
transport so the suite never depends on Sepolia being up; accessibility assertions on
the senior view.

Tests your code, not Ethereum.

- **Owns:** `frontend/**/__tests__/**` · `vitest.config.ts` · test setup files
- **Reads:** all of `frontend/src/**`
- **Must not touch:** any production source file — **if a test fails, report it, do not patch the source**
- **Model:** sonnet · MCP: playwright · **Exit:** suite green, hooks and lib covered

---

## S16 — `16-ci-docs-release`

**Role:** Release manager.

Automates the checks, writes the documentation an employer will actually read, and
publishes v1.0.0. Every claim in the README is verified by running it — test counts,
coverage numbers, the contract address, and setup steps from a clean clone.

Includes an honest limitations section, which is the most persuasive part of the
document. Never describes the contract as secure or audited.

- **Owns:** `.github/workflows/**` · `README.md` · `SECURITY.md` · final pass on `docs/`
- **Reads:** the entire repository
- **Must not touch:** `contracts/src/**` · `frontend/src/**` — documentation only
- **Model:** sonnet · MCP: github, playwright · **Exit:** CI green on `main`, `v1.0.0` released

---

## After v1.0.0

New features do not get a new numbered session. They use the feature workflow:

```
/ship-feature <name>
```

One branch, 11 gates, four subagents — `test-writer`, `test-runner`,
`security-reviewer`, `code-quality-reviewer` — and the same isolation rules apply. A
feature session owns only the paths its spec names.

---

## Dependency order

```
S01 ─┬─► S02 ──────────────────────────────► S11 ─► S12 ─► S13 ─► S14 ─► S15 ─┐
     │                                                                          │
     └─► S03 ─► S04 ─► S05 ─► S06 ─► S07 ─► S08 ─► S09 ─► S10 ──────────────────┴─► S16
```

S02 and S03 can run in either order after S01. Everything else is strictly sequential —
each session's exit criteria are the next session's preconditions.
