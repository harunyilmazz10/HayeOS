---
name: trading-terminal
description: Work on trading or prediction-market terminals with risk controls, exchange/market API adapters, position sizing, region constraints and safety boundaries.
---

# Haye Skill: trading-terminal

## Purpose
Build or review trading systems (e.g., ARB21-style Polymarket bot, options/futures terminals, prediction markets). Safety, not throughput, is the lead concern.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir; emir komutları ve API isimleri orijinal kalır.

## Inputs to inspect first
1. Which market(s): exchange or prediction market name (Polymarket, Binance, Bybit, etc.).
2. Region / regulatory constraint of the user (some markets are geo-restricted).
3. Current adapter code (`lib/exchanges/`, `services/market/`).
4. Risk engine: position sizing rule (Kelly, fixed fraction, etc.), max exposure, kill switch.
5. Where API keys live (must be encrypted at rest, not in `.env` of a public repo).
6. The 6 analysis engines + arbiter pattern from ARB21 if relevant — they exist for a reason; do not collapse them.

## Core design rules

### Adapter layer
- One adapter per venue; one interface. Domain code never imports a vendor SDK directly.
- Adapter responsibilities: auth, rate-limit, retry, normalize order shape, normalize market data, normalize errors.
- Every adapter has a `dry_run` mode that returns the same shape without sending real orders.

### Order safety
- Every order has a `client_order_id` (UUID) for idempotency.
- Pre-trade checks (hard, in this order):
  1. Authentication ok and account state is normal
  2. Symbol is valid and tradable now
  3. Notional within `max_notional_per_trade`
  4. Total exposure with this trade < `max_exposure`
  5. Daily P&L floor not breached (kill switch)
  6. Risk-of-ruin (Kelly fraction) within bounds
- Order types: prefer LIMIT with explicit TIF (`IOC`, `GTC`, `GTT`); avoid MARKET for thin books.
- Position reconciliation: every N seconds, compare adapter's view of position vs internal state; drift → halt new entries.

### Risk engine
- Kelly Criterion sizing: never raw Kelly. Use 1/2 or 1/4 Kelly. Hardcode a floor and a ceiling.
- Edge estimation: any model output is fed through a "is this reasonable?" sanity check before sizing.
- Correlation: do not size as if uncorrelated when assets actually move together. Cluster exposure.
- Drawdown rule: at -X% daily, stop opening new positions; at -Y%, force-flatten.

### Region constraints
- US users on Polymarket, KuCoin, Bybit etc.: blocked. Detect via IP and self-attestation; refuse to onboard with a clear message.
- Geo-block enforcement at the edge (Cloudflare WAF rule) AND at the app level (defense in depth).
- Sanctions screening if real money flows: name + country check.

### Secrets and keys
- API keys: AES-256-GCM encrypted at rest with a KEK held outside the DB (env var, KMS).
- Per-user keys, never shared.
- Withdraw permission: encourage users to issue trade-only keys (no withdraw scope).
- Display key suffix only in UI; never full key after creation.

### Data and observability
- Every order: input snapshot (market state at decision), all engine outputs, arbiter decision, final order, exchange response, fill events.
- Replay: any past decision can be replayed against archived market data.
- Trace ID per decision propagates to all logs and DB rows.
- Real-time dashboard: positions, daily P&L, kill-switch state, last 10 orders.

### Failure modes
- Exchange returns 5xx → bounded retry with jitter, then halt the strategy until human reviews.
- Lost connection during in-flight order → reconcile by `client_order_id`; do NOT re-send blindly.
- Stale market data feed → halt; never trade on stale prices.
- Model returns out-of-distribution signal (confidence very high or zero) → halt, log, alert.

### Backtest vs live
- Same code path for backtest and live, switched at the adapter boundary.
- Latency simulated in backtest (don't assume instant fills).
- Slippage model in backtest; do not pretend zero slippage.

## ARB21-specific notes (from project memory)
- Six independent analysis engines feed a Sonnet-based central arbiter. Do not merge engines "for simplicity".
- AES-256 encrypted API key storage via the settings UI — preserve this pattern.
- Turkish-language UI is the user-facing layer; analysis engines and logs stay in code-default language.
- Real-time dashboard is the operator's window — degraded performance there is itself a halt condition.

## Output format
```markdown
## Trading system review
- adapter layer: ok / mixed / coupled
- risk engine: implemented / partial / missing
- kill switch: tested / untested / missing
- reconciliation: present / missing

## Findings
- critical (can lose money silently):
- high:
- medium:

## Recommended next steps
- smallest safe change first

## Verification
- backtest replay of last N decisions
- dry-run live for M minutes
- one approved live order with tightest caps
```

## Safety rules
- Real money trading is HARD gate. Default to dry-run.
- Never widen `max_notional` or disable kill switch as a fix for "it's not trading enough".
- Never log API secret keys.
- Never propose changes to the arbiter or risk engine without an approval and a backtest.
- Long design notes go to `docs/trading-architecture.md`; chat gets the summary.
