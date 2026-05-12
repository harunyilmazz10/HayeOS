---
name: ai-agent-system
description: Use when building manager/worker AI agent systems - approval gates, tool permissions, structured logs, memory, cost ceilings, safe loops
---

# Haye Skill: ai-agent-system

## Purpose
Build or extend AI agent systems where one or more LLM-driven workers operate with tools and constraints. Patterns drawn from ARB21-style trading bots, scraping pipelines, and the manager/worker layout HayeOS itself uses.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. `.hayeos.json` for project context.
2. Existing agent code if any: `agents/`, `workers/`, `lib/agent/`.
3. Database tables for runs, decisions, tool calls (logs).
4. Tool surface: what can the agent call? (HTTP APIs, DB writes, file system, money?)
5. Cost/safety controls already in place.

## Core design rules

### Architecture
- Always separate: **planner** (decides what to do), **worker** (executes one tool call), **arbiter** (final go/no-go on high-impact action), **logger** (persists everything).
- Never let one LLM call both plan and execute high-impact actions without an arbiter check.
- The arbiter is the cheapest insurance against a model-stuck-in-loop bill.

### Tool design
- Each tool: idempotent where possible; explicit `dry_run` flag; bounded inputs (length, schema); rate-limited.
- High-impact tools (money, send email, post to platform, deploy, DB destructive) require an explicit human-or-arbiter approval flag passed in the call.
- Tool errors are typed: transient (retryable), permanent (give up), user-fixable (escalate).
- Tool descriptions in the system prompt are kept short; long docs go to a tool-help endpoint the agent can request.

### Cost / loop control
- Per-run cost ceiling (USD or tokens) — refuse to start a new step beyond it.
- Per-run wall-clock ceiling — hard kill.
- Per-run tool-call ceiling — prevents infinite loops.
- Detect repeated identical tool calls (same args 3 times in 10 steps) → escalate, do not retry.
- Detect "thrashing" (alternating between two states) → halt.

### Memory
- Short-term: rolling summary of last N steps (let the agent decide what to keep, with a token cap).
- Long-term: structured DB writes for facts, decisions, and contradictions. Not free-form notes.
- Project memory in HayeOS vault — write to `<resolved memoryPath>/01-project/agent-design.md` for design decisions.

### Auth / secret handling
- Tools that need API keys: keys come from a vault/secret store, never from prompt or DB rows in plaintext.
- The model never sees raw secrets — it sees a handle ("use credential `polymarket-prod`").
- AES-256 at rest for any secret the system stores (ARB21 pattern: per-user encrypted keys with a derived KEK).

### Observability
- Every step logged: prompt input hash, model name, model version, tool called, tool args (redacted), tool result (truncated), tokens used, latency.
- Per-run trace ID propagates to logs and DB rows.
- Errors include the full prompt context for replay.

### Safety against prompt injection
- Treat tool outputs (especially scraped web content, user messages) as untrusted.
- Sanitize / structure: parse tool output into typed fields before re-feeding into the model.
- Out-of-band channels for human instructions; do not let scraped content escalate the agent's permissions.

## Common pitfalls (from real systems)
- "It worked in testing" — eval set wasn't representative; test with adversarial inputs (long, multilingual, attempting prompt injection).
- Letting the agent compose its own SQL → bound to a typed query builder or a fixed query set.
- Streaming response into a UI without showing tool calls → user can't tell what's happening; show the trace.
- Retrying on a 4xx (other than 429) — that's a logic bug, not a transient error.
- Running multiple agents that can write to the same record → optimistic locking or queue-based ordering.

## Output format (when reviewing or designing)
```markdown
## Agent topology
- planner / worker / arbiter / logger boundaries:

## Tool catalog
- name | impact | idempotent | approval needed | rate limit | retry policy

## Run lifecycle
- start: ... | step: ... | halt conditions: ... | finalize: ...

## Cost controls
- per-run cap:
- per-tool cap:

## Failure modes considered
- prompt injection:
- infinite loop:
- partial write:
- secret leak:

## Verification
- offline eval set:
- sandbox run:
- one approved live run with hard caps:
```

## Safety rules
- Live API/paid model calls are a Cost / Risk Gate. Always cap and require approval.
- Trading or money-moving actions are HARD gates: dry-run only, then real with explicit user approval per run for the first N runs.
- Do not log raw API keys, OAuth tokens, or private user data.
- Long design docs go to `docs/agent-architecture.md`; chat gets the summary.
