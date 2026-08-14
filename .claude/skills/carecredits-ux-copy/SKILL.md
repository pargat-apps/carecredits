---
name: carecredits-ux-copy
description: Use when writing any user-facing string — button labels, error messages, empty states, confirmations — in frontend/src/pages or frontend/src/components for the Family, Senior, or Provider apps.
---

# CareCredits UX Copy

Applies to every string a Family, Senior, or Provider user reads. Grounded in
NFR-U-01 through NFR-U-05 and FR-S-01 through FR-S-09.

## Banned words — NFR-U-01
Never let these reach a user, in any of the three apps:
| Banned | Use instead |
|---|---|
| wallet | app, account |
| token | credit |
| gas | (omit — never mention network fees) |
| mint | add |
| burn | use, redeem |
| blockchain | (omit — describe the outcome, not the mechanism) |
| smart contract | (omit) |
| transaction hash | (omit, or "confirmation" if something must be shown) |
| seed phrase | (never applicable) |

Bad: "Minting 300 tokens to your mother's wallet."
Good: "Adding 300 credits for Mom."

## Grade 6 reading level — NFR-U-02
Short sentences, common words, active voice, one idea per sentence.
Bad: "Insufficient balance detected; the requested redemption could not be processed."
Good: "This service needs 250 credits. Mom has 120."

## Three-part errors — NFR-U-03
Every error states what happened, what it means, and what to do next.
Bad: "Error: transaction reverted."
Good: "This didn't go through. Mom doesn't have enough credits for this service yet.
Add more credits, or choose something smaller."

## Show credits AND CAD, except in the senior app — NFR-U-05
Bad (family/provider app): "You have 320 credits."
Good: "You have 320 credits ($320 CAD)."
The senior app shows neither — see below.

## Three-part empty states — NFR-U-04
Every empty list gets an illustration or icon, a plain-language title, and one action.
Bad: a blank list with no message.
Good: icon + "No requests yet." + "Browse services to get started" button.

## Senior view — stricter rules, not softer ones (FR-S-01 … FR-S-09)
These are safety requirements, not a style choice for older users.
- **No numbers, ever.** Not a credit count, not a dollar figure, not "3 of 4 tiles
  used." Availability is words only: "You have plenty of help available."
- **No currency symbol, ever.** Not "$", not "CAD," not "credits."
- Confirmations **name a person and a time**: "Sarah will call you within an hour."
  Never "Request #4821 confirmed."
- Body text ≥ 24px, targets ≥ 64px, max 4 choices on screen, no menus or settings.
- No wallet, signature, or gas language can appear here even by accident — see the
  viem-tx-lifecycle skill's senior-app rule.

Bad: "You have 3 tiles remaining today (approx. $75)."
Good: "You have plenty of help available."

## Tone
Warm, plain, respectful of an intelligent adult who is not a technologist. Never
cute, never alarmed. "Done! Sarah will call you within an hour" — not "Success!! 🎉"
and not "WARNING: low balance."

## Provider app privacy in copy (FR-P-03, FR-P-06)
Before a job is accepted, show the client's first name only — never a full name,
address, or phone number.
Bad: "Margaret Chen, 42 Riverside Dr."
Good: "A ride for Margaret in Alta Vista."

## Never
- Never use a banned word from the table above, in any app.
- Never show a number, dollar amount, or credit count in the senior app.
- Never write an error without saying what to do next.
- Never ship an empty list with no message.
- Never show a client's full name or address before a provider accepts the job.
- Never use alarmed or overly cheerful tone for routine states — low balance is
  informative, not scary.
