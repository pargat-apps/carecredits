---
name: react-component-patterns
description: How React components are written in CareCredits — structure, props, state ownership, Tailwind token discipline, required states. Use whenever creating or editing any .tsx file.
---

# React component patterns

## The dependency rule — never break this
Data flows DOWN as props. Events flow UP as callbacks.

    pages/       route screens, own the data wiring
      hooks/     all state and data access lives here
        components/   presentational only

**A component never fetches data.** No `fetch`, no client, no hook that talks to a
network. If a component needs data, it arrives as a prop. This is what makes components
testable without a blockchain running.

## Props
Explicit TypeScript types. No `any`, no implicit any, no `object`.

    Bad:   export function Card(props: any)
    Good:  type CardProps = { title: string; credits: number; onRequest?: () => void }
           export function Card({ title, credits, onRequest }: CardProps)

Optional callbacks use `?`. Required data does not.
Prefer a discriminated union over three boolean flags:

    Bad:   { isLoading: boolean; isError: boolean; isEmpty: boolean }
    Good:  { state: 'loading' | 'error' | 'empty' | 'ready' }

## Tailwind discipline
Use the token scale from `tailwind.config.ts`. **Never an arbitrary value.**

    Bad:   className="text-[17px] p-[13px] rounded-[14px]"
    Good:  className="text-body-lg p-stack-md rounded-lg"

If a value you need is missing, add it to the theme — do not inline it. One arbitrary
value is how a design system starts dying.

## Every component ships these states
default · hover · focus-visible · disabled · loading
Lists additionally need: empty · error

If a state cannot happen for a component, say so in a comment. Do not silently skip it.

## File layout
One component per file, named after the component. Co-locate its types above it.
Order inside the file: types → component → small local helpers.
No default exports except for route-level pages.

## Naming
Components PascalCase. Props types `<Component>Props`. Handlers `onX` for the prop,
`handleX` for the implementation. Booleans read as questions: `isOpen`, `hasBalance`.

## Never
- Fetch data inside a component
- Use an arbitrary Tailwind value
- Use `any` or a non-null assertion `!` to silence TypeScript
- Leave `console.log` or a commented-out block
- Use an index as a React `key` on a list that can reorder
- Put business logic in JSX — extract it to a named variable above the return
