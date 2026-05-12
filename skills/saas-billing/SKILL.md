---
name: saas-billing
description: Work on SaaS auth, plans, billing, webhooks, entitlements, admin controls and payment security.
---

# Haye Skill: saas-billing

## Purpose
Build or review the paid side of a SaaS: plans, checkout, webhooks, entitlement enforcement, admin controls, refunds, and customer-facing billing UI.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. Auth model (NextAuth / custom / Clerk) — entitlements piggyback on user identity.
2. Provider: Stripe (default), Lemon Squeezy, Paddle, crypto. The provider determines the webhook contract.
3. `prisma/schema.prisma` models: `User`, `Subscription`, `Plan`, `Customer`, `Invoice`, `Entitlement`.
4. Webhook endpoints in `app/api/webhooks/stripe/route.ts` (or equivalent).
5. Plan/price definitions: in code? in DB? in Stripe-as-source-of-truth?

## Core design rules

### Source of truth
- Stripe Customer/Subscription IDs live on `User` (1:1) or on a dedicated `Customer` row.
- Plan IDs and price IDs come from Stripe; never hardcode prices in the app.
- Entitlements derived from current subscription status, computed in one place (`getUserEntitlements(userId)`).

### Webhook contract
- ALWAYS verify Stripe signature with `stripe.webhooks.constructEvent(rawBody, sig, secret)`. Constant-time check is in the library.
- Use raw body, not parsed JSON, for signature verification — many frameworks parse body before reaching the handler; bypass that.
- Idempotency: store `event.id` in a table with unique constraint; on duplicate, return 200 immediately.
- Process events out of order: do not assume `customer.subscription.created` arrives before `invoice.paid`. Reconcile from Stripe on every meaningful event.
- Required events to handle:
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.paid`
  - `invoice.payment_failed`
  - `customer.subscription.trial_will_end`
  - `checkout.session.completed`

### Plan and price
- Define plans by name in code (`FREE`, `PRO`, `BUSINESS`), each mapped to a list of Stripe price IDs (monthly + yearly).
- Mapping lives in one config file or DB table; never repeated.
- New plan = config change + redeploy, not migration.

### Entitlement enforcement
- Server-side check on every paid endpoint: `if (!hasEntitlement(user, 'feature-x')) return 403`.
- Client-side gating is presentation, not security.
- Soft fallback when subscription expires: read-only access vs full cut-off, decided per-feature.

### Checkout / portal
- Checkout session: server creates it, frontend redirects. Never trust client-supplied price IDs without validating they belong to your account.
- Billing Portal session: same — server creates with the authenticated user's customer ID.
- Success redirect: do not unlock entitlements based on the redirect; only the webhook is authoritative.

### Refunds, disputes, fraud
- Refund endpoint requires admin auth + ownership check.
- Dispute (`charge.dispute.created`) → freeze the account or flag for review, do not auto-refund.
- Stripe Radar rules — set up minimum (block known-fraud, require 3DS for high-risk).
- Per-user spend cap to limit abuse on metered billing.

### Tax
- If serving EU, you collect VAT; Stripe Tax handles this if enabled.
- Invoice must show tax line; if the customer is a business with a VAT number, reverse charge applies.
- Document the tax model decision in `<resolved memoryPath>/02-decisions/tax.md`.

### Crypto (if applicable to this Haye project)
- Treat each chain/token as a separate provider abstraction.
- Confirmations: wait for N confirmations before crediting (chain-specific).
- Never refund crypto automatically; manual review.

## Common pitfalls
- Client telling the server "I paid" → never trust; only webhooks are authoritative.
- Webhook handler timing out (Stripe retries 3x then gives up); keep handlers fast — write to a queue and process out of band if heavy.
- Forgetting `proration_behavior` on plan changes → customer billed unexpected amount.
- Trial logic: Stripe treats trial as a subscription with status `trialing` — entitlement check must accept that status.
- One stripe customer, multiple subscriptions → list logic, not assume 1:1.

## Output format
```markdown
## Billing posture
- provider:
- plans defined (source):
- entitlement code path:
- webhook events handled:
- missing events:

## Issues
- security (signature, IDOR on customer ID, etc.):
- correctness (race conditions, missing idempotency):
- UX (billing portal missing, cancellation friction):

## Recommended next 3
- smallest fix first
```

## Safety rules
- Real charges are HARD gate. Use Stripe test mode for development; live keys never in dev environments.
- Webhook secret is a critical secret; never log, never echo.
- A failing webhook handler must return non-2xx so Stripe retries; never return 200 to "skip" — fix the handler.
- Refund logic is HARD gate; manual approval per call until a tested admin flow exists.
- Long billing specs go to `docs/billing.md`; chat gets the summary.
