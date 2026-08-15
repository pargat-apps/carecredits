---
id: ui-preview
goal: Build a running, clickable CareCredits website with mock data — no blockchain, no wallet
model: sonnet
mode: default
mcp: none
---

# Session UI-PREVIEW — the website you can actually look at

**Standalone session. Not part of the numbered 16.** Run it whenever you like.

## Role

You are the **UI builder**. You produce a website that runs at `localhost:5173`,
looks like the design system, and can be clicked through end to end.

**Everything is mock data.** No wallet, no viem, no chain calls, no `.env`. Not one
line of blockchain code. Sessions 12 and 13 wire the real data in later — your job is
to make the shell real first.

The point of this session: after five sessions of Solidity, you get something to look at.

## Isolation rules

- **Write only** inside the OWNS list. If a task needs a path outside it, stop and tell me.
- **You may NOT read `design/**/code.html`** — blocked. Everything you need is in
  `docs/DESIGN-SYSTEM.md`.
- `contracts/**` is off limits entirely. Do not read it, do not import from it.
- Do not create `.env` or `.env.local`. There are no secrets in this session.
- Ask before installing any package beyond the list below.

### OWNS
```
frontend/package.json  vite.config.ts  tsconfig.json  index.html
frontend/src/main.tsx  App.tsx  routes.tsx
frontend/src/components/**
frontend/src/pages/**
frontend/src/mock/**
frontend/src/lib/format.ts
frontend/public/**
docs/SESSION-LOG.md          (append)
```

### READS
```
CLAUDE.md
docs/DESIGN-SYSTEM.md            primary source — tokens, components, screens
docs/REQUIREMENTS.md             §5 §6 §7 UI requirements, §10 service catalogue
frontend/tailwind.config.ts      already written in Session 02
frontend/src/styles/**           already written in Session 02
.claude/skills/react-component-patterns/
.claude/skills/accessibility-rules/
.claude/skills/carecredits-ux-copy/
```

### MUST NOT TOUCH
```
contracts/**
design/**/code.html          blocked
specs/**
docs/*.md                    except SESSION-LOG.md
frontend/tailwind.config.ts  Session 02 owns it
frontend/src/styles/**       Session 02 owns it
.claude/agents  commands  hooks  settings.json
```

---

## Allowed packages — ask before anything else

```
react react-dom react-router-dom
vite @vitejs/plugin-react typescript
tailwindcss postcss autoprefixer
lucide-react
clsx
```

**Not in this session:** viem, wagmi, ethers, any wallet library, any state manager,
any UI kit. If you think you need one, stop and ask.

---

## Tasks

### 1. Scaffold Vite

```
npm create vite@latest . -- --template react-ts
```
run inside `frontend/`. Preserve the existing `tailwind.config.ts` and `src/styles/`
from Session 02 — do not overwrite them.

Wire Tailwind properly (PostCSS, not the CDN). Import `src/styles/base.css` in `main.tsx`.

Confirm `npm run dev` serves a blank page before going further.

### 2. Mock data — `frontend/src/mock/`

Use the Ottawa content reference in **§11 of docs/DESIGN-SYSTEM.md**. Consistency
matters more than volume — the same people and neighbourhoods everywhere.

```
services.ts    all 26 services with credit costs, grouped by category (REQUIREMENTS §10)
recipient.ts   Margaret, 78, Alta Vista, 420 credits, avatar
funder.ts      her daughter, overseas
providers.ts   Capital Snow Pros, Rideau Home Care, Élise T., Sarah M., Marcus O.
activity.ts    ~8 past items, mixed issued/redeemed, statuses
bookings.ts    2 upcoming services with provider and time
jobs.ts        5 provider jobs across Alta Vista, Barrhaven, The Glebe, Orléans, Nepean
```

Type everything. No `any`.

### 3. Components — `frontend/src/components/`

Build from the inventory in **§7 of docs/DESIGN-SYSTEM.md**. Follow the
**react-component-patterns** skill exactly.

```
Button  Card  StatusChip  BalanceCard  ServiceCard  CreditPack
ActivityRow  Nav  Input  Avatar  EmptyState  SkeletonCard  SeniorTile
```

Every one: default, hover, focus-visible, disabled, loading. Lists also get empty.

### 4. Pages — `frontend/src/pages/`

```
/                    Landing        hero, trust strip, how it works, featured services
/dashboard           Family         balance card, upcoming, activity, quick add, weather card
/dashboard/low       Family         same page, low-balance state (38 credits)
/services            Marketplace    all 26, grouped, filter pills, search
/services/:id        Detail         snow clearing as the worked example
/add                 Add credits    3 steps: Choose -> Review -> Complete
/activity            History        full activity list with empty state
/senior              Senior home    4 tiles + Call for Help
/senior/done         Senior confirm large check, "Sarah will call you within an hour"
/provider            Provider jobs  5 available jobs
/provider/earnings   Provider       earnings summary
/preview             Index          links to every route above, for clicking through
/components          Gallery        every component in every state
```

`/preview` and `/components` are for you and me, not users. Build them first — they
make everything else reviewable.

### 5. The senior pages get stricter treatment

Follow the **accessibility-rules** skill senior section exactly.
24px+ body, 32px+ buttons, 64px targets, max 4 tiles, persistent "Call for Help",
**no numbers, no currency anywhere on the page.**

The senior home screen does not exist in the design export — build it from the
confirmation screen's type scale and the rules in the skill.

### 6. Formatting helper — `frontend/src/lib/format.ts`

```
formatCredits(n)   ->  "420 CareCredits"
formatCad(n)       ->  "$420.00 CAD"
formatDate(d)      ->  "Thursday, 9:30 AM"
```
Plain numbers for now. Sessions 12–13 replace this with bigint and `formatUnits`.
Add a comment saying so.

### 7. Accessibility pass

Run through the **accessibility-rules** skill:
contrast pairs with real numbers · focus rings · keyboard order · 48px / 64px targets ·
status never colour alone · 200% zoom · reduced motion.

Report the actual contrast ratio for any colour pair you introduced.

### 8. Verify

```
npm run build      must succeed
npx tsc --noEmit   zero errors
npm run dev        open localhost:5173/preview and click every link
```

---

## Exit criteria

- [ ] `npm run dev` serves the site, `/preview` links to every route
- [ ] All 13 routes render without a console error
- [ ] `npx tsc --noEmit` — zero errors, no `any` anywhere
- [ ] No arbitrary Tailwind values — everything from the token scale
- [ ] Senior pages show no number and no currency
- [ ] Every list has a designed empty state
- [ ] Zero blockchain code — `grep -ri "viem\|wagmi\|ethers\|wallet" frontend/src` returns nothing
- [ ] `npm run build` succeeds

## Handoff

Append to `docs/SESSION-LOG.md`, then propose:

```
feat: add static UI preview with mock data
```

Tell the next session: which routes exist, which components are reusable as-is, what is
mocked and will need replacing with real data, and any design decision you had to make
because the design system did not cover it.
