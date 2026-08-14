# Plan — Session 02: Design system application

## Goal

Turn the already-written design system doc into working Tailwind config, CSS tokens,
rescued local images, and the six project Skills that future sessions depend on.

## Plan

1. Run `./scripts/fetch-design-assets.sh` to rescue images from
   `lh3.googleusercontent.com` before they expire; report download successes/failures.
2. Rename downloaded `asset-NN.jpg` files to meaningful names, using only
   filenames/`alt` attributes grepped from `design/**/*.html` (never full HTML content,
   never `code.html`).
3. Write `frontend/tailwind.config.ts` verbatim from §6 of `docs/DESIGN-SYSTEM.md`.
4. Write `frontend/src/styles/tokens.css` (CSS custom properties, Google Fonts import,
   reduced-motion block).
5. Write `frontend/src/styles/base.css` (tokens import, Tailwind directives, body
   defaults, focus-visible ring, `.tabular` utility).
6. Invoke the `skill-writer` subagent to generate the six Skills into
   `.claude/skills/`; report each file's line count and description line.
7. Run verification checklist (config validity, files exist, six skills ≤150 lines
   each, no `.env`/`node_modules` in git status), then append to
   `docs/SESSION-LOG.md` and propose the commit message.

## Ambiguities noted before starting

- Step 1: if any image fails to download, stop and report before renaming.
- Step 2: image names inferred from grepped filenames/alt text, mapping shown before
  renaming.
- Step 6: skill writing delegated to `skill-writer` subagent per spec ("do not write
  them yourself").
- Step 7: "valid TypeScript" check done as a lightweight syntax check, not a full
  project build.

## Isolation rules (from specs/02-design-system.md)

- Write only inside OWNS: `frontend/tailwind.config.ts`, `frontend/src/styles/**`,
  `frontend/public/img/**`, `frontend/.gitkeep`, `scripts/fetch-design-assets.sh`,
  `.claude/skills/**`, `docs/SESSION-LOG.md` (append only).
- `docs/DESIGN-SYSTEM.md` and other docs are read-only.
- Never read `design/**/code.html`.
- Never install a package without asking.
