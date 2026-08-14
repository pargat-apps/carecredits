---
id: 01-repo-bootstrap
goal: Turn the Foundry starter into the CareCredits monorepo and install the Claude Code tooling
model: haiku
mode: default
mcp: none
---

# Session 01 — Repository bootstrap

## Role

You are the **repository architect**. You build the skeleton that the next fifteen
sessions live inside. You write no product logic — no contract code, no UI, no tests.

Get this right and every later session starts clean. Get it wrong and every later
session inherits the mess.

## Isolation rules

- **Write only** inside the OWNS list below. If a task needs a path outside it, stop and tell me.
- `CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/REQUIREMENTS.md`, `docs/DESIGN-SYSTEM.md`,
  `docs/SESSIONS.md` are **read-only**. They already exist. Do not rewrite them.
- `docs/SESSION-LOG.md` is **append-only**.
- Never install a package or dependency without asking first.

### OWNS (you may write here)
```
.gitignore
foundry.toml
remappings.txt
contracts/**            (structure only — no .sol source)
frontend/.gitkeep
design/**               (copying files in)
docs/SESSION-LOG.md     (append)
.claude/**
scripts/**
```

### READS
```
CLAUDE.md
docs/ARCHITECTURE.md
docs/REQUIREMENTS.md
docs/SESSIONS.md
```

### MUST NOT TOUCH
```
contracts/src/**        any .sol file
frontend/src/**
specs/**                (except reading this file)
docs/*.md               (except SESSION-LOG.md)
```

---

## Tasks

Work through these in order. Show me each step before you run it.

### 1. Clean out the Foundry sample

Delete `src/Counter.sol`, `test/Counter.t.sol`, `script/Counter.s.sol`.
They are template files, not our project.

### 2. Restructure into a monorepo

Target layout:

```
carecredits/
├── CLAUDE.md                 (already exists)
├── contracts/                move src/, test/, script/, lib/, foundry.toml here
│   ├── src/
│   ├── test/unit/
│   ├── test/fuzz/
│   ├── test/invariant/handlers/
│   ├── test/script/
│   ├── script/
│   └── lib/
├── frontend/                 empty for now, add .gitkeep
├── docs/                     (already exists)
├── specs/                    (already exists)
├── scripts/                  (already exists)
├── design/                   the Stitch export
└── .claude/
```

Keep `lib/forge-std` working. Update `foundry.toml` paths if needed.

### 3. Write `.gitignore`

Must cover:
```
out/
cache/
broadcast/
.env
.env.local
node_modules/
dist/
.DS_Store
```

Confirm `lib/` stays tracked — Foundry dependencies are git submodules.

### 4. Create `contracts/.env.example`

Committed, with **empty** values. It documents what variables are needed without
revealing any:

```
SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=
DEPLOYER_ACCOUNT=
```

### 5. Install OpenZeppelin

```
cd contracts && forge install OpenZeppelin/openzeppelin-contracts
```
Ask before running. Report the version installed.

### 6. Configure `contracts/foundry.toml`

- Pin the Solidity compiler version (do not use a caret)
- `optimizer = true`, `optimizer_runs = 200`
- `[fuzz] runs = 1000`
- `[invariant] runs = 256`, `depth = 128`, `fail_on_revert = false`
- Confirm `src`, `test`, `script`, `libs` paths match the new layout

### 7. Generate remappings

```
cd contracts && forge remappings > remappings.txt
```
This is what stops Cursor underlining OpenZeppelin imports in red.

### 8. Copy the design export

Copy the Stitch export into `design/`. Do **not** open or read any `code.html`.

### 9. Create the `.claude/` tooling

Create these directories and tell me which files I need to paste in:
```
.claude/agents/
.claude/skills/
.claude/commands/
.claude/hooks/
```

Create `.claude/settings.json` with the permissions block (deny list for
`design/**/code.html`, `.env`, `lib/`, `out/`, `cache/`, `node_modules/`).

⚠️ Hooks and settings only take effect after Claude Code restarts. Note this in the
handoff so Session 02 knows.

### 10. Verify

```
cd contracts && forge build
```
Must compile. Then `git status` — confirm no `.env` and no `out/` are staged.

---

## Exit criteria

All five must pass:

- [ ] `forge build` succeeds from `contracts/`
- [ ] No `Counter` files remain anywhere
- [ ] `git status` shows no `.env`, `out/`, `cache/`, `broadcast/`
- [ ] `contracts/.env.example` exists and is committed with empty values
- [ ] `remappings.txt` exists

## Handoff

Append to `docs/SESSION-LOG.md`, then propose one commit:

```
chore: restructure into monorepo and install openzeppelin
```

Tell Session 02: the OpenZeppelin version installed, whether hooks are active yet,
and anything about the layout it needs to know.
