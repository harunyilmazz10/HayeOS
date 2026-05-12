# Recipe: SaaS Billing (Stripe)

Quick reference. Full design via `saas-billing` skill.

## Stack assumed
- Stripe (live + test mode)
- Webhooks at `/api/webhooks/stripe`
- Subscription model in Prisma referencing Stripe customer ID

## Plan definition
- Plans in code: `FREE`, `PRO`, `BUSINESS` → list of Stripe price IDs (monthly + yearly)
- Single config file; never hardcoded prices in components

## Webhook events to handle (minimum)
- `checkout.session.completed`
- `customer.subscription.created` / `updated` / `deleted`
- `invoice.paid` / `payment_failed`
- `customer.subscription.trial_will_end`

## Idempotency
- `event_id` table with unique constraint
- Reply 200 immediately on duplicate
- Use Stripe's raw body for signature verification (constructEvent)

## Entitlement check
- Server-side on every paid endpoint
- `getUserEntitlements(userId)` reads from local subscription state
- Reconcile from Stripe on each webhook event

## Common breakage
- Webhook timeout (3 retries then drop) → keep handler fast, queue heavy work
- Signature failure → body parser stripped raw bytes; use raw middleware
- Plan change not prorated → set `proration_behavior` explicitly

## When to escalate
- Full billing architecture → `saas-billing` skill
- API integration shape → `api-integration` skill
- Security of webhook → `auth-audit` skill
