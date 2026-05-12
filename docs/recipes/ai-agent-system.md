# Recipe: AI Agent System (manager/worker/arbiter)

Quick reference. Full design via `ai-agent-system` skill.

## Architecture
- Planner decides what to do
- Worker executes one tool call at a time
- Arbiter gates high-impact actions
- Logger persists prompts, tool calls, results, costs

## Tool design rules
- Idempotent where possible; explicit `dry_run` flag
- Bounded inputs (length, schema); rate-limited
- High-impact tools require approval flag passed in the call
- Errors typed: transient / permanent / user-fixable

## Cost & loop control
- Per-run cost ceiling (USD or tokens) — refuse to start a new step beyond it
- Per-run wall-clock ceiling — hard kill
- Per-run tool-call ceiling
- Detect repeated identical tool calls → escalate, don't retry

## Memory
- Short-term: rolling summary with token cap
- Long-term: structured DB writes for facts, decisions, contradictions
- Project memory in HayeOS vault for design decisions

## Secret handling
- Model never sees raw secrets — only handles ("credential `polymarket-prod`")
- AES-256 at rest for stored secrets
- Per-user keys, never shared

## Prompt injection defense
- Tool outputs treated as untrusted (web content, user messages)
- Parse outputs into typed fields before re-feeding
- Scraped content cannot escalate agent permissions

## When to escalate
- Full architecture → `ai-agent-system` skill
- Trading-specific → `trading-terminal` skill
- Content-specific → `content-automation` skill
