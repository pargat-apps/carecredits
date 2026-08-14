# CareCredits — Design System

**Status:** v1.1 · **Extracted:** 2026-08-14 · **Source:** Google Stitch export, 17 screens
**Pilot city:** Ottawa, Ontario

> ⚠️ **This file replaces the raw design export.**
> Never read `design/**/code.html` — ~300 KB, blocked in `.claude/settings.json`.
> Everything needed to build the UI is here.

**Method:** extracted from the embedded `tailwind.config` block and from actual class
usage across all 17 `code.html` files, with frequency counts. Where the source
`DESIGN.md` prose disagreed with the markup, **the markup wins** — it is what renders.

---

## 1. ⚠️ Findings and decisions

Five inconsistencies found in the export. All five are now resolved.

### F-1 — The export is Winnipeg. The product is Ottawa. ✅ Decided

The designs contain **24 Winnipeg references**. The pilot city is Ottawa, Ontario, so
every one of them needs replacing during the port.

**Text replacements**

| Found in export | Uses | Replace with |
|---|---|---|
| "Winnipeg, Manitoba" | 2 | **Ottawa, Ontario** |
| "Winnipeg, MB" | 1 | **Ottawa, ON** |
| "Winnipeg-based support" | 1 | **Ottawa-based support** |
| "Winnipeg Snow Pros" (provider) | 1 | **Capital Snow Pros** |
| "Winnipeg" (map alt text) | 2 | **Ottawa** |

**Neighbourhood replacements** — chosen to match the character of each original

| Export (Winnipeg) | Uses | Ottawa equivalent | Why it matches |
|---|---|---|---|
| River Heights | 7 | **Alta Vista** | Established, leafy, older residents |
| St. Vital | 4 | **Barrhaven** | Suburban family residential |
| Osborne | 2 | **The Glebe** | Dense urban village, walkable |
| Transcona | 2 | **Orléans** | Outer suburb, distinct community identity |
| Fort Garry | 2 | **Nepean** | Large south/west residential area |

Use these five consistently. If a sixth is needed, add **Westboro** or **Kanata**.

**🔴 One asset must be regenerated.** `available_jobs_carecredits_provider` embeds a
generated map illustration explicitly described as *"Winnipeg… neighborhoods… River
Heights and St. Vital"* with five teal pins. Text find-and-replace cannot fix an image.
Either regenerate it for Ottawa, or replace it with a neutral abstract map panel.

**Content opportunity Ottawa creates.** Ottawa has a large francophone population and
municipal French-language services. **Medical appointment interpretation (70 CC) should
be the featured example rather than a secondary one**, and English↔French should be the
first language pair shown. In Winnipeg that service was a nice differentiator; in Ottawa
it is an obvious, everyday need — which makes the product read as more researched.

Government paperwork help also lands harder in the national capital, where federal
pension and benefits forms are part of ordinary life.

### F-2 — Success and warning tokens are missing from the palette ✅ Adopted

Stitch hit this and left a comment in `states_gallery_carecredits/code.html`:

```
'[#DCFCE7]'); // Fallback tint since specific success token not provided in config
```

Observed fallbacks, used consistently:

| Purpose | Background | Text / border | Uses |
|---|---|---|---|
| Success / Completed | `#DCFCE7` | `#166534` | 7 |
| Warning / Low balance | `#B45309` at 20% | `#B45309` at 30% border | 1 |

**Decision: adopt as real tokens.** Both pass AA and are already in use.

### F-3 — Four competing radius systems ✅ Resolved

| Source | Values |
|---|---|
| `DESIGN.md` front matter | sm 4 · DEFAULT 8 · md 12 · lg 16 · xl 24 |
| Embedded `tailwind.config` | DEFAULT 4 · lg 8 · xl 12 · full 9999 |
| Actual markup | `rounded-full` ×165 · `rounded-xl` ×86 · `rounded-[16px]` ×32 · `rounded-lg` ×23 · `rounded-[12px]` ×12 |

The config and the front matter **disagree on what `lg` and `xl` mean**, and the markup
bypasses both with arbitrary values.

**Decision: use the front-matter scale** (§5). It matches what the markup actually
reaches for — 16px cards, 12px buttons, pill chips.

### F-4 — Wallet and token icons appear in the UI 🔴 Remove

| Icon | Uses |
|---|---|
| `account_balance_wallet` | 6 |
| `token` | 3 |

These violate NFR-U-01 — no blockchain or financial jargon in the interface. A wallet
icon signals "crypto app" to exactly the audience we are trying not to alarm.

**Decision: replace** with `hand-heart`, `sparkles`, or the CareCredits mark.

### F-5 — Two border colours ✅ Resolved

`#C5C6CC` (the `outline-variant` token) and `#DDE3E9` (arbitrary, 4 uses).
**Decision: standardise on `#C5C6CC`.** It is the token, and the difference is invisible.

---

## 2. The embedded config, verbatim

Extracted from `<script id="tailwind-config">`. Ground truth for colour and type.

```js
colors: {
  "background": "#fcf9f4",  "on-background": "#1c1c19",
  "surface": "#fcf9f4",  "surface-bright": "#fcf9f4",  "surface-dim": "#dcdad5",
  "surface-container-lowest": "#ffffff",  "surface-container-low": "#f6f3ee",
  "surface-container": "#f0ede9",  "surface-container-high": "#ebe8e3",
  "surface-container-highest": "#e5e2dd",  "surface-variant": "#e5e2dd",
  "on-surface": "#1c1c19",  "on-surface-variant": "#44474c",
  "inverse-surface": "#31302d",  "inverse-on-surface": "#f3f0eb",
  "outline": "#75777d",  "outline-variant": "#c5c6cc",  "surface-tint": "#545f71",
  "primary": "#000000",  "on-primary": "#ffffff",
  "primary-container": "#101c2b",  "on-primary-container": "#798498",
  "primary-fixed": "#d7e3f9",  "primary-fixed-dim": "#bbc7dc",
  "on-primary-fixed": "#101c2b",  "on-primary-fixed-variant": "#3c4759",
  "inverse-primary": "#bbc7dc",
  "secondary": "#006a62",  "on-secondary": "#ffffff",
  "secondary-container": "#83f2e5",  "on-secondary-container": "#006f67",
  "secondary-fixed": "#86f5e8",  "secondary-fixed-dim": "#68d8cc",
  "on-secondary-fixed": "#00201d",  "on-secondary-fixed-variant": "#00504a",
  "tertiary": "#000000",  "on-tertiary": "#ffffff",
  "tertiary-container": "#00201c",  "on-tertiary-container": "#009485",
  "tertiary-fixed": "#62fae3",  "tertiary-fixed-dim": "#3cddc7",
  "on-tertiary-fixed": "#00201c",  "on-tertiary-fixed-variant": "#005047",
  "error": "#ba1a1a",  "on-error": "#ffffff",
  "error-container": "#ffdad6",  "on-error-container": "#93000a",
}
```

**Most-used colours in markup:** `#ffffff` 90 · `#fcf9f4` 54 · `#000000` 37 ·
`#00201c` 36 · `#e5e2dd` 34 · `#bbc7dc` 34 · `#1c1c19` 34 · `#101c2b` 34 ·
`#62fae3` 24 · `#006a62` 23.

---

## 3. Colour — practical guide

### Surfaces

| Token | Hex | Use |
|---|---|---|
| `background` / `surface` | `#FCF9F4` | Page background. Warm cream, never pure white. |
| `surface-container-lowest` | `#FFFFFF` | Cards |
| `surface-container-low` | `#F6F3EE` | Raised sections |
| `surface-container` | `#F0EDE9` | Input fills, inactive tabs |
| `surface-container-high` | `#EBE8E3` | Hover on low-emphasis surfaces |
| `surface-container-highest` | `#E5E2DD` | Pressed states |
| `surface-dim` | `#DCDAD5` | Disabled surfaces |
| `inverse-surface` | `#31302D` | Toasts, tooltips |

### Text and lines — computed contrast on `#FFFFFF`

| Token | Hex | Ratio | Verdict |
|---|---|---|---|
| `on-surface` | `#1C1C19` | ~16.4:1 | ✅ any size |
| `on-surface-variant` | `#44474C` | ~9.4:1 | ✅ any size |
| `outline` | `#75777D` | ~4.6:1 | ✅ body text OK |
| `outline-variant` | `#C5C6CC` | ~1.9:1 | ⚠️ **borders only — never text** |
| `on-primary-container` | `#798498` | ~3.6:1 | ⚠️ **large text on dark navy only** |

### Brand

| Token | Hex | Use |
|---|---|---|
| `primary` | `#000000` | Primary buttons, high-emphasis actions |
| `primary-container` | `#101C2B` | Dark hero surfaces |
| `secondary` | `#006A62` | Teal — links, focus, active, accents |
| `secondary-container` | `#83F2E5` | Light teal fill |
| `tertiary-container` | `#00201C` | Deepest surface, gradient stop |
| `tertiary-fixed` | `#62FAE3` | **Glow and decoration only** (24 uses, all blurs) |

### Status — including the two adopted in F-2

| Purpose | Background | Text / border | Ratio | Source |
|---|---|---|---|---|
| Success / Completed | `#DCFCE7` | `#166534` | ~6.6:1 ✅ | observed, 7 uses |
| Warning / Low balance | `#B45309`/20 | `#B45309`/30 border | ~4.9:1 on white ✅ | observed |
| Error | `#FFDAD6` | `#93000A` | ~8.6:1 ✅ | token |
| Info / Scheduled | `#83F2E5` | `#006F67` | ~5.1:1 ✅ | token |

### Gradients — real values from the markup

| Name | Definition | Where | Uses |
|---|---|---|---|
| `hero` | `to-br, #071322 → #11998E` | Landing hero, dark panels | 3 |
| `hero-rev` | `to-br, #11998E → #071322` | Success screens | 1 |
| `balance` | `to-br, primary-container → secondary` | Balance card | 1 |
| `cta` | `to-r, primary → secondary` | Gradient buttons | 1 |
| `rule` | `to-r, secondary-fixed-dim → tertiary-fixed → secondary-fixed-dim` @50% | Section dividers | 1 |
| `shimmer` | `to-r, transparent → surface-container-lowest/20 → transparent` | Skeletons | 1 |

⚠️ `#071322` and `#11998E` are **not tokens** — hard-coded in six places. Promoted to
`hero.start` / `hero.end` in §6.

### Decoration

```css
/* Dot grid — hero backgrounds, opacity-20 */
background-image: radial-gradient(circle at 2px 2px, rgba(255,255,255,0.4) 1px, transparent 0);
background-size: 32px 32px;

/* Glow blob — tertiary-fixed at 20%, blur 80–120px, rounded-full */
```

---

## 4. Typography

Verbatim from the embedded config. `font-*` sets family, `text-*` sets size.

| Style | Family | Size | Weight | Line height | Tracking |
|---|---|---|---|---|---|
| `headline-xl` | Space Grotesk | 48px | 700 | 1.1 | -0.02em |
| `headline-lg` | Space Grotesk | 32px | 600 | 1.2 | -0.01em |
| `headline-lg-mobile` | Space Grotesk | 28px | 600 | 1.2 | — |
| `headline-md` | Space Grotesk | 24px | 600 | 1.3 | — |
| `number-display` | Space Grotesk | 24px | 700 | — | — |
| `label-caps` | Space Grotesk | 12px | 600 | 1.0 | 0.05em |
| `body-lg` | Inter | 17px | 400 | 1.6 | — |
| `body-md` | Inter | 15px | 400 | 1.5 | — |

**Missing, needed:** `number-hero: 60px / 700 / 1.0 / -0.02em` for the balance card.

**Observed problem:** `font-number-display` appears **67 times**, `tabular-nums` only
**19**. Every credit and currency value needs tabular figures or columns misalign in
lists. Bake it into the utility rather than relying on memory.

**Labels are `uppercase tracking-wider`** throughout — part of the system, not incidental.

---

## 5. Spacing, radius, elevation

**Spacing** — 8px base:

| Token | Value |
|---|---|
| `stack-sm` | 8px |
| `stack-md` | 16px |
| `stack-lg` | 24px |
| `gutter` | 24px |
| `container-margin` | 32px |
| `section-gap` | 64px |

**Radius** — the F-3 resolution:

| Token | Value | Applies to |
|---|---|---|
| `sm` | 4px | Tags |
| `DEFAULT` | 8px | Inputs |
| `md` | 12px | **Buttons** |
| `lg` | 16px | **Cards** |
| `xl` | 24px | Modals, hero panels |
| `full` | 9999px | Chips, avatars, pill buttons |

**Elevation** — observed, with real frequencies:

| Level | Definition | Uses |
|---|---|---|
| e1 | `0 1px 8px rgba(0,0,0,0.04)` | **13** — the workhorse |
| e1-up | `0 -1px 8px rgba(0,0,0,0.04)` | 3 — bottom bars |
| divider | `1px 0 0 0 rgba(221,227,233,1)` | 3 — vertical rules |
| e3 | `0 20px 50px -10px rgba(0,0,0,0.3)` | 1 — hero image |
| teal | `0 4px 12px rgba(0,106,98,0.2)` | 1 |
| glow | `0 0 40px rgba(131,242,229,0.4)` | 1 — dark surfaces |
| selected | `inset 0 0 0 2px secondary, 0 10px 30px -5px rgba(0,106,98,0.2)` | 2 |

**Layout:** max width `1280px` (14 uses). Header `h-20` fixed, `bg-background/90
backdrop-blur-md`.

| Breakpoint | Columns | Margin | Gutter |
|---|---|---|---|
| 390px mobile | 4 | 20px | 16px |
| 768px tablet | 8 | 24px | 20px |
| 1024px+ | 12 | 32px | 24px |

---

## 6. Corrected Tailwind config

Resolves F-2, F-3, F-5 and the hard-coded gradient stops.

```ts
// frontend/tailwind.config.ts
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        background: '#FCF9F4',
        surface: {
          lowest: '#FFFFFF', low: '#F6F3EE', DEFAULT: '#F0EDE9',
          high: '#EBE8E3', highest: '#E5E2DD', dim: '#DCDAD5', inverse: '#31302D',
        },
        ink:   { DEFAULT: '#1C1C19', variant: '#44474C', inverse: '#F3F0EB' },
        line:  { DEFAULT: '#75777D', variant: '#C5C6CC' },
        brand: { DEFAULT: '#000000', on: '#FFFFFF', navy: '#101C2B', onNavy: '#798498' },
        teal:  { DEFAULT: '#006A62', on: '#FFFFFF', container: '#83F2E5', onContainer: '#006F67' },
        deep:  { DEFAULT: '#00201C', on: '#009485', glow: '#62FAE3' },
        hero:  { start: '#071322', end: '#11998E' },     // promoted from literals
        ok:    { container: '#DCFCE7', on: '#166534' },   // F-2
        warn:  { DEFAULT: '#B45309' },                     // F-2
        danger:{ DEFAULT: '#BA1A1A', container: '#FFDAD6', onContainer: '#93000A' },
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'system-ui', 'sans-serif'],
        body:    ['Inter', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        'label-caps':    ['12px', { lineHeight: '1',   letterSpacing: '0.05em', fontWeight: '600' }],
        'body-md':       ['15px', { lineHeight: '1.5' }],
        'body-lg':       ['17px', { lineHeight: '1.6' }],
        'number-display':['24px', { lineHeight: '1',   fontWeight: '700' }],
        'headline-md':   ['24px', { lineHeight: '1.3', fontWeight: '600' }],
        'headline-lg':   ['32px', { lineHeight: '1.2', letterSpacing: '-0.01em', fontWeight: '600' }],
        'headline-xl':   ['48px', { lineHeight: '1.1', letterSpacing: '-0.02em', fontWeight: '700' }],
        'number-hero':   ['60px', { lineHeight: '1',   letterSpacing: '-0.02em', fontWeight: '700' }],
        'senior-body':   ['24px', { lineHeight: '1.5' }],
        'senior-tile':   ['32px', { lineHeight: '1.2', fontWeight: '600' }],
      },
      borderRadius: { sm:'4px', DEFAULT:'8px', md:'12px', lg:'16px', xl:'24px' },
      spacing: { 'stack-sm':'8px','stack-md':'16px','stack-lg':'24px',
                 gutter:'24px','container-margin':'32px','section-gap':'64px' },
      boxShadow: {
        e1:      '0 1px 8px rgba(0,0,0,0.04)',
        'e1-up': '0 -1px 8px rgba(0,0,0,0.04)',
        e2:      '0 10px 25px -5px rgba(7,19,34,0.04)',
        e3:      '0 20px 50px -10px rgba(0,0,0,0.3)',
        teal:    '0 4px 12px rgba(0,106,98,0.2)',
        glow:    '0 0 40px rgba(131,242,229,0.4)',
        selected:'inset 0 0 0 2px #006A62, 0 10px 30px -5px rgba(0,106,98,0.2)',
      },
      backgroundImage: {
        hero:      'linear-gradient(to bottom right,#071322,#11998E)',
        'hero-rev':'linear-gradient(to bottom right,#11998E,#071322)',
        balance:   'linear-gradient(to bottom right,#101C2B,#006A62)',
        cta:       'linear-gradient(to right,#000000,#006A62)',
        dots:      'radial-gradient(circle at 2px 2px, rgba(255,255,255,0.4) 1px, transparent 0)',
      },
      backgroundSize: { dots: '32px 32px' },
      maxWidth: { content: '1280px' },
      transitionDuration: { micro:'150ms', panel:'240ms', page:'360ms' },
    },
  },
}
```

---

## 7. Component inventory

Evidence-based. "Observed" = the pattern actually used in the export.

| Component | Observed | Props | States |
|---|---|---|---|
| `Button` primary | `bg-primary text-on-primary rounded-full px-stack-lg py-stack-md uppercase tracking-wider font-label-caps` | `variant` `size` `loading` `icon` | default, hover, active, focus-visible, disabled, loading |
| `Button` on-dark | `bg-on-primary text-primary rounded-[12px] px-stack-lg py-4` | — | — |
| `Button` ghost-on-dark | `bg-transparent border border-tertiary-fixed-dim text-tertiary-fixed-dim` | — | — |
| `Card` | `bg-surface-container-lowest rounded-[16px] p-stack-md shadow-e1 border border-outline-variant/30` | `padding` `interactive` | default, hover `-translate-y-1` |
| `BalanceCard` | `bg-balance p-8 text-white rounded-[16px]` + glow blob + dot grid | `credits` `cad` `scheduled` `onAdd` | normal, low (<50), zero |
| `StatusChip` success | `bg-ok-container text-ok-on rounded-full text-sm font-semibold shadow-sm` | `status` | static |
| `StatusChip` warning | `bg-warn/20 border border-warn/30 rounded-[16px] p-4` | — | — |
| `ServiceCard` | `group rounded-xl` + `absolute inset-0 group-hover:shadow-md` overlay | `service` `credits` `category` `onRequest` | default, hover, focus-within |
| `CreditPack` | selected uses `shadow-selected` (inset 2px teal ring + glow) | `credits` `price` `badge` `selected` | default, hover, selected |
| `ActivityRow` | icon + title + subtitle + `font-number-display tabular-nums` delta + chip | `type` `title` `subtitle` `timestamp` `delta` `status` | default, hover |
| `Nav` top | `fixed h-20 bg-background/90 backdrop-blur-md shadow-e1 max-w-content` | `items` `active` | active = `text-primary font-bold underline underline-offset-8` |
| `Input` | `rounded-[8px] border border-outline-variant`; focus → `shadow-[inset_0_0_0_1px_secondary]` | `label` `error` `helper` | default, focus, filled, error, disabled |
| `EmptyState` | illustration + title + body + one action | `illustration` `title` `body` `action` | — |
| `TxStatus` | *not in the export — build from the states gallery* | `state` `hash` `error` | idle, simulating, awaiting-signature, pending, confirmed, failed |
| `SeniorTile` | 24–80px type range on the confirmation screen | `icon` `label` `onPress` | default, pressed |
| `Skeleton` | `bg-shimmer -translate-x-full animate-[shimmer_1.5s_infinite]` | `lines` | — |

**Observed inconsistency:** `rounded-full` (165) *and* `rounded-[12px]` (12) on buttons.
Standardise — pill for nav and chips, 12px for form and flow buttons.

---

## 8. The three app modes

| | Family | Senior | Provider |
|---|---|---|---|
| Base font | 17px | **24px** | 17px |
| Button label | 12–17px | **32px** | 12–17px |
| Touch target | 48px | **64px** | 48px |
| Choices per screen | unlimited | **max 4** | unlimited |
| Numbers shown | ✅ | **❌ never** | ✅ |
| Currency shown | ✅ | **❌ never** | ✅ |
| Navigation | top / bottom nav | **none** | sidebar |
| Wallet UI | ✅ | **❌ never** | ✅ |

**Senior sizes observed** in `confirmation_ride_requested`: 24, 28, 32, 36, 64, 80px.
Copy observed: *"We'll take care of the rest."* / *"Back Home"*.

### Senior overrides — non-negotiable (FR-S-01 … FR-S-09)

```
Body            24px minimum        Tiles     160px tall, 64px target, 32px label
Layout          max 4 tiles         Persistent "Call for Help", no scroll needed
Forbidden       numbers, currency, menus, settings, login, tooltips, hover-only
Availability    words only          Confirmation  name a person and a time
Contrast        aim 7:1, never below 4.5:1
```

---

## 9. Icons

**Replace Material Symbols with `lucide-react`** — 2px stroke, rounded terminals, which
is what the source design doc specifies. 24px default, 32px in the senior view.

| Material (uses) | lucide |
|---|---|
| `schedule` (14) | `clock` |
| `check_circle` (14) | `check-circle-2` |
| `location_on` (13) | `map-pin` |
| `person` (12) | `user` |
| `arrow_forward` (10) | `arrow-right` |
| `search` (9) | `search` |
| `home` (8) | `home` |
| `medical_services` (7) | `stethoscope` |
| `ac_unit` (6) | `snowflake` |
| `directions_car` (5) | `car` |
| `translate` (3) | `languages` |
| 🔴 `account_balance_wallet` (6) | **remove — F-4** |
| 🔴 `token` (3) | **remove — F-4** |

Icon-only buttons require `aria-label`. No emoji as icons.

---

## 10. Screen inventory

### Canonical — build these

| Screen | Source | Ottawa changes needed |
|---|---|---|
| Landing page | `carecredits_landing_page` | "Winnipeg-based support" → "Ottawa-based support" |
| Family dashboard | `mom_s_care_dashboard_1` | Neighbourhood names |
| Dashboard — low balance | `mom_s_care_dashboard_low_balance` | A **state**, not a screen |
| Service marketplace | `service_marketplace_1` | Feature interpretation (EN↔FR) prominently |
| Service detail | `service_detail_sidewalk_snow_clearing` | Template for all services |
| Add credits — step 1 | `add_carecredits_step_1` | — |
| Add credits — review + success | `review_success_add_carecredits` | — |
| Senior confirmation | `confirmation_ride_requested` | Type-scale reference |
| Provider — available jobs | `available_jobs_carecredits_provider` | 🔴 **map asset must be regenerated**, neighbourhoods, provider name |
| Provider — earnings + completion | `earnings_job_completion_carecredits_provider` | Neighbourhood names |
| States gallery | `states_gallery_carecredits` | Component state reference |

### Discard

| File | Reason |
|---|---|
| `mom_s_care_dashboard_2` | Superseded (16 KB vs 21 KB) |
| `margaret_s_care_dashboard` | 5.9 KB — a fragment |
| `service_marketplace_2` | Superseded |
| `available_jobs_..._high_contrast` | Accessibility reference only |
| `shader_1`, `shader_2` | Background experiments, unused |

### 🔴 Missing — build by hand

| Screen | Build from | Requirement |
|---|---|---|
| **Senior home** — 4 tiles | `confirmation_ride_requested` type scale + §8 | FR-S-01 … FR-S-09 |
| **Dashboard — mobile** | Reflow `mom_s_care_dashboard_1`; do not shrink | NFR-P-03 |
| **Activity history** | `ActivityRow` from the dashboard, full page | FR-F-10 |
| **TxStatus states** | Not in the export at all | FR-F-08 |

---

## 11. Ottawa content reference

Use these consistently across all mock data, so screens look like one coherent product.

**Neighbourhoods:** Alta Vista · Barrhaven · The Glebe · Orléans · Nepean
*(spares: Westboro, Kanata)*

**Sample providers**

| Name | Services |
|---|---|
| Capital Snow Pros | Snow clearing, salting |
| Rideau Home Care | Cleaning, laundry, meal prep |
| Élise T. | Medical interpretation (EN↔FR) |
| Sarah M. | Medical rides, appointment escort |
| Marcus O. | Handyman, gutters, bulbs |

**Sample recipient:** Margaret, 78, Alta Vista.
**Sample funder:** her daughter, currently overseas.

**Featured services for Ottawa** — reordered from the Winnipeg set:

1. **Medical appointment interpretation (70 CC)** — EN↔FR. In Ottawa this is an everyday need, not a niche one.
2. **Sidewalk / driveway snow clearing (35 / 50 CC)** — Ottawa winters carry this easily.
3. **Government forms assistance (45 CC)** — federal pension and benefits paperwork, apt in the capital.
4. **"Is this call a scam?" check (15 CC)** — the emotional differentiator.

---

## 12. Accessibility rules baked into the system

| Rule | Mechanism |
|---|---|
| Body ≥ 4.5:1, large text and borders ≥ 3:1 | `on-surface`, `on-surface-variant` pass on white and cream |
| `outline-variant` `#C5C6CC` is 1.9:1 | **Borders only — never text** |
| `on-primary-container` `#798498` is 3.6:1 | **Large text on dark navy only** |
| Focus visible everywhere | `2px solid #006A62`, 2px offset, `focus-visible` |
| Targets 48px / 64px | Enforced in `Button` and `SeniorTile` |
| Status never colour alone | `StatusChip` renders icon + text |
| Tabular figures on all values | Baked into `number-display` and `number-hero` |
| 200% zoom safe | No fixed heights, no `overflow:hidden` on text |
| Reduced motion | All transitions wrapped |

---

## 13. Known issues in the export

| # | Issue | Evidence | Fix | Session |
|---|---|---|---|---|
| 1 | Images on `lh3.googleusercontent.com` will expire | every `<img>` | `scripts/fetch-design-assets.sh` | 02 |
| 2 | Tailwind from CDN | all 17 files | Real build, §6 | 11 |
| 3 | Material Symbols icons | 100+ spans | `lucide-react`, §9 | 11 |
| 4 | Wallet / token icons in UI | 9 uses | Remove — F-4 | 11 |
| 5 | Success + warning tokens absent | Stitch's own comment | Adopted — F-2 | ✅ |
| 6 | Four radius systems | F-3 | Front-matter scale | ✅ |
| 7 | Two border colours | `#C5C6CC` vs `#DDE3E9` | Standardise — F-5 | ✅ |
| 8 | Gradient stops hard-coded | ×6 | Promoted to `hero.start/end` | ✅ |
| 9 | `tabular-nums` on 19 of 67 numerals | grep counts | Bake into the utility | 11 |
| 10 | Three screens never generated | §10 | Build by hand | 11, 14 |
| 11 | 24 Winnipeg references | F-1 | Replace per F-1 tables | 11 |
| 12 | 🔴 Winnipeg map asset embedded | provider jobs screen | **Regenerate or replace with an abstract panel** | 11 |

---

## Change log

| Date | Version | Change |
|---|---|---|
| 2026-08-14 | v1.1 | Pilot city changed to Ottawa, Ontario. Neighbourhood and provider mapping added (§1 F-1, §11). Featured services reordered to lead with EN↔FR interpretation. Map asset flagged for regeneration. |
| 2026-08-14 | v1.0 | Extracted from the embedded `tailwind.config` and actual class usage across all 17 screens. Five inconsistencies identified and resolved. |
