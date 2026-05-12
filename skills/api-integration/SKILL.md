---
name: api-integration
description: Use when adding or hardening an external API integration - auth, retries, rate limits, idempotency, observability, graceful failure
---

# Haye Skill: api-integration

## Purpose
Add a new external API integration, or harden an existing one. Skill version of the `api-integrator` agent — same checklist, applied within a single workflow.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir; SDK/parametre isimleri orijinal kalır.

## Inputs to inspect first
1. Provider name + which endpoints we need.
2. Provider's documented rate limits and error model.
3. Existing patterns in the repo (`lib/api/`, `services/`, `integrations/`) — match conventions.
4. Where the secret will live (`.env.example`, Coolify env, secret manager).
5. Whether the SDK is already in `package.json` / `requirements.txt`.

## Token discipline
- Don't fetch every page of the provider docs; pin the endpoint URL and the auth section.
- Don't paste full provider error catalogs; capture the ones we'll handle.

## Workflow

### Step 1 — Contract sheet
Write a 10-line spec before writing code:
- auth method (API key / OAuth / HMAC)
- base URL (prod + sandbox)
- endpoints we will call (max 7)
- rate limits (rpm, rps, burst)
- idempotency support (header name, scope)
- error model (4xx vs 5xx vs 429)
- timeouts to use

### Step 2 — Secret handling
- Add the secret to `.env.example` (placeholder value only).
- Document where to set it in production (Coolify Env section, KMS).
- Confirm it never crosses the client boundary (no `NEXT_PUBLIC_` prefix unless the value is public by design).

### Step 3 — Adapter layer
- One file per provider in `lib/integrations/<provider>.ts` (or `services/<provider>.py`).
- Exports a small, typed surface (`createCustomer`, `chargeCustomer`, etc.) — not a thin re-export of the SDK.
- Internal: configured timeouts, retry policy, logging.
- A `dry_run` mode that returns the same shape without calling out.

### Step 4 — Retry and rate-limit
- Retry only on transient errors (`408`, `429`, `5xx`); never on 4xx other than 429.
- Exponential backoff with jitter, capped attempts (3).
- On 429: honor `Retry-After` header if present.
- Provider rate limit known → enforce locally (token bucket per second/minute) so we never hit it.

### Step 5 — Idempotency for writes
- Generate `Idempotency-Key` (UUID) per logical operation.
- Store in our DB so a retry uses the same key.
- For providers without idempotency support, deduplicate at our boundary with a unique constraint on the natural key.

### Step 6 — Webhooks (if applicable)
- Endpoint at `/api/webhooks/<provider>/route.ts`.
- Verify signature (constant-time, in the SDK's helper).
- Use raw body for signature verification.
- Idempotent processing: `event_id` table.
- Reply 200 fast; heavy work via queue.

### Step 7 — Observability
- Log: method, URL host (not full path with IDs), status, duration, retry count. NO secrets, NO PII.
- Metric per call: `api.<provider>.<endpoint>` with success/failure tags.
- Trace ID propagated.

### Step 8 — Tests
- Mock-based test for the happy path.
- Mock test for each retryable error.
- Contract test: one approved sandbox call to confirm the contract matches.

### Step 9 — Memory
- `<resolved memoryPath>/02-decisions/api-<provider>.md`: endpoints used, auth, idempotency, rate limit, error mapping.

## Anti-patterns to refuse
- Calling the SDK directly from React components / Next.js page code
- Storing API key in a DB row (use env or secret manager)
- "It's just a test call" against a paid API without a cap
- Catching all errors and silencing — at least log them with the trace ID
- Using `latest` for the SDK version
- Assuming a 200 means success without inspecting the response body

## Output format
```markdown
## Provider
- auth:
- base URL:
- endpoints (max 7):

## Adapter shape
- exported functions:
- timeouts:
- retry policy:

## Idempotency
- key strategy:
- storage:

## Webhook (if applicable)
- endpoint:
- signature method:
- replay protection:

## Observability
- log fields:
- metric:

## Tests
- mock:
- contract:

## Verification
- one sandbox call output:
- expected vs actual:

## Memory
- <resolved memoryPath>/02-decisions/api-<provider>.md
```

## Safety rules
- Live paid API calls are a Cost / Risk Gate.
- Never paste real API keys in chat or code.
- Webhook signature verification is non-negotiable.
- SDK version bumps go through `dependency-security`.
- Long integration specs go to `docs/api/<provider>.md`; chat gets the summary.
