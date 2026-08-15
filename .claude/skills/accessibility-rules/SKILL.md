---
name: accessibility-rules
description: WCAG 2.1 AA rules and the stricter senior-view rules for CareCredits. Use whenever building or reviewing any user interface.
---

# Accessibility rules

The primary end user is 70–90 years old, possibly with reduced vision, hearing or fine
motor control. These are product requirements, not polish.

## Everywhere in the app

**Contrast** — body text 4.5:1 minimum, large text and UI borders 3:1.
Verified pairs from the design system:

    on-surface        #1C1C19 on white   16.4:1  OK any size
    on-surface-variant #44474C on white   9.4:1  OK any size
    outline           #75777D on white    4.6:1  OK body text
    outline-variant   #C5C6CC on white    1.9:1  BORDERS ONLY, never text
    on-primary-container #798498 on navy  3.6:1  LARGE TEXT ONLY

**Focus** — every interactive element shows a visible ring on `:focus-visible`:
2px solid `#006A62`, 2px offset. Never `outline: none` without a replacement.

**Targets** — 48px minimum in the family and provider apps.

**Keyboard** — every flow completable without a mouse. Logical tab order. No traps.
Nothing important behind hover only.

**Status is never colour alone.** Always colour + icon + text label.

    Bad:   <span className="text-green-600">●</span>
    Good:  <Chip icon={<CheckCircle2/>} label="Completed" tone="ok" />

**Semantics** — real `<button>` for actions, real `<a>` for navigation. Headings in
order, never skipping a level. Form controls have visible labels, not just placeholders.
Icon-only buttons need `aria-label`.

**Zoom** — usable at 200%. No fixed heights on text containers, no `overflow: hidden`
that clips text.

**Motion** — respect `prefers-reduced-motion: reduce`.

## Senior view — stricter, non-negotiable

    Body text        24px minimum
    Button labels    32px minimum
    Touch targets    64px minimum
    Tiles            160px tall minimum
    Choices          maximum 4 visible at once
    Contrast         aim 7:1, never below 4.5:1

**Forbidden in the senior view:**
numbers · currency · credit counts · menus · settings · login · breadcrumbs ·
tooltips · hover-only affordances · multi-step forms · navigation depth

**Required:**
- "Call for Help" always visible without scrolling
- Availability in words: "You have plenty of help available"
- Confirmations name a person and a time: "Sarah will call you within an hour"
- One idea per screen

## Checking your own work
State the actual contrast ratio when you use a new colour pair. "Looks fine" is not a
check. `#44474C on #FFFFFF = 9.4:1` is.
