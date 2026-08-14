---
id: 02-design-system
goal: Apply the design system — Tailwind theme, CSS tokens, local images, and the six project Skills
model: sonnet
mode: default
mcp: none
---

# Session 02 — Design system application

## Role

You are the **design system engineer**. You turn the written design system into working
configuration, rescue the design images before their URLs expire, and generate the six
project Skills that every later session relies on.

**Note on scope:** extraction is already done. `docs/DESIGN-SYSTEM.md` exists and is
authoritative. You are applying it, not producing it.

## Isolation rules

- **Write only** inside the OWNS list. If a task needs a path outside it, stop and tell me.
- `docs/DESIGN-SYSTEM.md` is **read-only**. Do not rewrite it.
- `CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/REQUIREMENTS.md`, `docs/SESSIONS.md` are read-only.
- `docs/SESSION-LOG.md` is append-only.
- **You may NOT read `design/**/code.html`.** Blocked at the permission layer, and there
  is no reason to — everything you need is in `docs/DESIGN-SYSTEM.md`.
- Never install a package without asking.

### OWNS
```
frontend/tailwind.config.ts
frontend/src/styles/**
frontend/public/img/**
frontend/.gitkeep
scripts/fetch-design-assets.sh
.claude/skills/**
docs/SESSION-LOG.md          (append)
```

### READS
```
CLAUDE.md
docs/DESIGN-SYSTEM.md        (primary source)
docs/ARCHITECTURE.md
docs/REQUIREMENTS.md
```

### MUST NOT TOUCH
```
design/**/code.html          blocked
contracts/**
specs/**
docs/*.md                    except SESSION-LOG.md
.claude/agents/  commands/  hooks/  settings.json
```

---

## Tasks

Show me each step before running it.

### 1. Rescue the images — do this first

The design images are hosted on `lh3.googleusercontent.com` and **will expire**.

Run `./scripts/fetch-design-assets.sh`. It finds every Stitch-hosted URL in `design/`,
downloads it to `frontend/public/img/`, and reports what succeeded.

Report how many downloaded and how many failed. If any failed, tell me which.

### 2. Rename the downloaded images

They arrive as `asset-01.jpg`, `asset-02.jpg`… Give each a meaningful name based on
where it is used — `logo.png`, `hero-network.jpg`, `caregiver-headshot.jpg`, and so on.
You may read `design/**/*.html` **filenames and img alt attributes only** via grep to
work out what each one is. Do not read full HTML files.

### 3. Create the Tailwind config

Write `frontend/tailwind.config.ts` using the **corrected config in §6 of
docs/DESIGN-SYSTEM.md**, verbatim. That config already resolves the export's
inconsistencies — do not re-derive it.

### 4. Create the CSS tokens

Write `frontend/src/styles/tokens.css` with the same values as CSS custom properties,
plus the Google Fonts import for Space Grotesk and Inter.

Include a `@media (prefers-reduced-motion: reduce)` block that disables transitions.

### 5. Add the base stylesheet

Write `frontend/src/styles/base.css`:
- import `tokens.css`
- Tailwind directives
- `body` defaults: cream background, Inter 17px, `on-surface` text
- a global `:focus-visible` rule: 2px `#006A62` ring with 2px offset
- `font-variant-numeric: tabular-nums` on a `.tabular` utility

### 6. Generate the six Skills

Use the **skill-writer** subagent. It writes six files into `.claude/skills/`:
solidity-house-style · foundry-test-patterns · viem-tx-lifecycle ·
carecredits-ux-copy · session-handoff · deploy-runbook

Do not write them yourself. Report each file's line count and description line.

### 7. Verify

- `frontend/tailwind.config.ts` exists and is valid TypeScript
- `frontend/src/styles/tokens.css` and `base.css` exist
- `frontend/public/img/` contains the downloaded images
- `.claude/skills/` contains six SKILL.md files, none over 150 lines
- `git status` shows no `.env` and no `node_modules/`

---

## Exit criteria

- [ ] All design images downloaded locally and meaningfully named
- [ ] `tailwind.config.ts` matches §6 of the design system doc
- [ ] `tokens.css` and `base.css` written
- [ ] Six Skills generated, each under 150 lines
- [ ] Nothing outside the OWNS list was modified

## Handoff

Append to `docs/SESSION-LOG.md`, then propose:

```
feat: add design system tokens, tailwind theme and project skills
```

Tell Session 03: how many images were rescued, the six Skill names, and anything in
the design system that still needs a human decision.
