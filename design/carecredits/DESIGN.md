---
name: CareCredits
colors:
  surface: '#fcf9f4'
  surface-dim: '#dcdad5'
  surface-bright: '#fcf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ee'
  surface-container: '#f0ede9'
  surface-container-high: '#ebe8e3'
  surface-container-highest: '#e5e2dd'
  on-surface: '#1c1c19'
  on-surface-variant: '#44474c'
  inverse-surface: '#31302d'
  inverse-on-surface: '#f3f0eb'
  outline: '#75777d'
  outline-variant: '#c5c6cc'
  surface-tint: '#545f71'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#101c2b'
  on-primary-container: '#798498'
  inverse-primary: '#bbc7dc'
  secondary: '#006a62'
  on-secondary: '#ffffff'
  secondary-container: '#83f2e5'
  on-secondary-container: '#006f67'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#00201c'
  on-tertiary-container: '#009485'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d7e3f9'
  primary-fixed-dim: '#bbc7dc'
  on-primary-fixed: '#101c2b'
  on-primary-fixed-variant: '#3c4759'
  secondary-fixed: '#86f5e8'
  secondary-fixed-dim: '#68d8cc'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#00504a'
  tertiary-fixed: '#62fae3'
  tertiary-fixed-dim: '#3cddc7'
  on-tertiary-fixed: '#00201c'
  on-tertiary-fixed-variant: '#005047'
  background: '#fcf9f4'
  on-background: '#1c1c19'
  surface-variant: '#e5e2dd'
typography:
  headline-xl:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
  number-display:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 32px
  gutter: 24px
  section-gap: 64px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style
The design system bridges the precision of Web3 technology with the warmth of human-centric family care. The aesthetic is "Trust-Tech": a sophisticated blend of **Corporate Modern** and **Web3 Futuristic**. It utilizes clean layouts and high-end typography to establish reliability, while subtle technical patterns—like dot grids and node networks—signal a modern, secure infrastructure. 

The interface should feel airy and premium, prioritizing clarity and ease of use for families while maintaining a cutting-edge technical edge for the credit-based care economy.

## Colors
The palette is anchored by deep Navy and sophisticated Teals. 
- **Primary/Hero:** Use the deep Navy for primary actions and grounding elements. Use Teal and Aqua for accents, highlights, and interactive progress indicators.
- **Backgrounds:** The primary canvas is Cream (#FBF8F3), providing a warmer, more human feel than a pure sterile white. 
- **Surfaces:** Cards and containers use pure White (#FFFFFF) to pop against the cream background.
- **Status:** Standard semantic colors are used but should be applied primarily to text and subtle backgrounds to maintain the premium feel.

## Typography
This design system uses a dual-font strategy:
- **Space Grotesk** is used for all headings, labels, and numeric data. It provides the "tech" signature. For any currency or credit balances, always enable `tabular-figures` to ensure vertical alignment in lists.
- **Inter** handles all long-form reading and UI body text. It is set at a slightly larger base (17px) to improve accessibility and readability for family members of all ages.
- **Weight Usage:** Use Bold/Semi-bold for headlines and Medium for labels. Avoid Light weights to maintain a sense of stability.

## Layout & Spacing
The layout follows a **Fluid Grid** model with generous white space to evoke a "premium" service feel.
- **Desktop:** 12-column grid, 32px margins, 24px gutters. Content should be centered with a max-width of 1280px.
- **Mobile:** 4-column grid, 20px margins, 16px gutters.
- **Rhythm:** Use 8px increments for internal component spacing. Section-to-section spacing should be significant (48px-64px) to prevent the UI from feeling cluttered or "cheap."
- **Background Details:** Use a 1px dot-grid pattern (15% opacity) or faint connected-node vector illustrations in the background of hero sections to reinforce the Web3 narrative.

## Elevation & Depth
Elevation is achieved through **Tonal Layering** and soft, ambient shadows rather than heavy black shadows.
- **Level 0:** Cream background (#FBF8F3).
- **Level 1 (Cards):** White surface (#FFFFFF) with a 1px border (#DDE3E9).
- **Shadows:** Use a "Large/Soft" shadow for floating elements: `0 10px 25px -5px rgba(7, 19, 34, 0.04)`.
- **Interactions:** On hover, cards may lift slightly by increasing shadow spread and reducing border opacity.

## Shapes
The shape language is "Structured-Soft."
- **Cards/Containers:** 16px corner radius to feel approachable.
- **Buttons:** 12px corner radius, balancing the roundness of the cards with a more functional, defined shape.
- **Status Chips:** Full pill-shape (999px radius) to distinguish them from interactive buttons or static containers.
- **Icons:** Use 2px stroke weight with rounded terminals to match the typography's character.

## Components
- **Buttons:** 
  - *Primary:* Navy background, White text. 
  - *Secondary:* White background, 1px Teal border, Teal text.
  - *Sizing:* Minimum height 48px for touch targets.
- **Cards:** Always use White background and 16px radius. For dashboard summaries, include a subtle 10% opacity Teal gradient in the top-right corner.
- **Status Chips:** Use a light tint of the status color for the background (e.g., Success background #DCFCE7) with dark bold text for high legibility.
- **Input Fields:** 1px border (#DDE3E9), 12px radius. On focus, the border transitions to Teal (#11998E) with a 2px outer glow.
- **Lists:** Use 24px vertical padding for list items. Use thin 1px horizontal dividers (#DDE3E9) that stop 16px short of the container edges.
- **Credit Indicators:** Specific Web3-inspired component displaying "CareCredits" balances using Space Grotesk Bold and a small Aqua dot icon to represent a "live" node.