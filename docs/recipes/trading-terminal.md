# Recipe: Trading Terminal (ARB21-style)

Quick reference. Full design via `trading-terminal` skill.

## Stack assumed
- Multiple analysis engines (6 in ARB21) feeding a central arbiter
- Adapter per venue (Polymarket, etc.); domain code never imports vendor SDK directly
- AES-256 encrypted user API key storage with KEK outside DB
- Kelly Criterion position sizing (1/2 or 1/4 Kelly, never raw)

## Risk gates (in order, hard)
1. Auth + account state ok
2. Symbol tradable now
3. Notional ≤ `max_notional_per_trade`
4. Total exposure ≤ `max_exposure`
5. Daily P&L floor not breached (kill switch)
6. Risk-of-ruin within bounds

## Order safety
- `client_order_id` (UUID) per order for idempotency
- LIMIT with explicit TIF; avoid MARKET on thin books
- Position reconciliation every N seconds; drift → halt new entries

## Region constraints
- US users blocked on Polymarket, KuCoin, Bybit, etc.
- Enforce at edge (Cloudflare) AND in app

## Observability
- Per-decision trace ID propagated to all logs and DB rows
- Replay: any past decision replayable against archived data
- Dashboard: positions, daily P&L, kill-switch state, last 10 orders

## Common breakage
- Stale market data feed → halt; never trade on stale prices
- Repeated identical signal → loop detection; halt and alert
- Withdraw-scope API key → encourage trade-only keys

## When to escalate
- Full design or new venue → `trading-terminal` skill
- Adapter contract → `api-integration` skill
- Risk model → arbiter / risk engine review (don't collapse engines)
