---
name: content-automation
description: Build automated content pipelines - source ingest, LLM rewrite, scheduling, multi-channel posting, analytics feedback.
---

# Haye Skill: content-automation

## Purpose
Build or maintain content pipelines that ingest sources, generate or rewrite, schedule and post across channels (blogs, X/Twitter, LinkedIn, newsletters, Telegram channels). Sibling of `video-factory` but text-first.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. Source strategy: RSS, scraped sites, internal CMS, user-submitted, AI-generated from a topic list.
2. Channels in use: WordPress, Ghost, Substack, X, LinkedIn, Telegram, email (Mailgun, Postmark, Resend).
3. Orchestrator: n8n, Celery, Temporal, plain cron.
4. Approval workflow: full-auto, draft-approval, human-in-the-loop?
5. Brand voice / style guide if any (`docs/brand.md`).

## Core design rules

### Source ingest
- RSS feeds via a dedicated fetcher with conditional GET (`If-Modified-Since`, `ETag`).
- Scraped sources: respect `robots.txt`, rate-limit aggressively, identify the user-agent honestly, cache.
- Dedup by content hash (after normalization: strip tracking params, lowercase, collapse whitespace).
- Source quality score: track per-source signal (how often a source's items get published) to weight ingest.

### Generation / rewrite
- Always start from a structured input (title + summary + facts + URL), not free-form prompt.
- LLM prompt template versioned (`prompts/blog-rewrite/v3.md`); changes ship in a release.
- Output constraints in prompt and validated post-hoc: word count band, no banned phrases, link count limit.
- Citation: include the source URL in the output; if it's a "summary of X" piece, attribution is non-negotiable.

### Style and voice
- Style guide enforced via prompt + a second-pass LLM judge that scores adherence.
- House rules (e.g., "no exclamation marks", "use Oxford comma") in a single file referenced by every prompt.
- Banned topics list for compliance.

### Scheduling
- Per-channel calendar with slot capacity (e.g., LinkedIn max 1/day, X 5/day, blog 3/week).
- Time-zone aware (audience-relative, not server-relative).
- Best-time-to-post per channel learned over weeks, not assumed.

### Publishing
- API per channel: each as an adapter with `dry_run` mode.
- Idempotent: `(channel, content_hash) → channel_post_id` stored, retry never duplicates.
- Token / auth refresh per channel (LinkedIn rotates fast).
- Image: handle resize per channel (square for X header, 1:1 for IG, 1.91:1 for LinkedIn link preview).

### Analytics feedback
- Per-post: impressions, engagement, click-through, follower delta.
- Per-source: aggregate ROI of items originating from each source.
- Per-prompt-version: A/B comparing prompt revisions.
- Feed back into ingest weighting and generation prompt choice.

### Approval / safety
- Default to draft-approval for new sources or new prompt versions.
- Banned phrases / forbidden topics list — fail the post if hit.
- Per-channel review for first 20 posts after any major change.

## Common pitfalls
- "Spammy" cadence triggers shadowbans → vary length, hooks, posting time.
- Re-publishing the same item across channels verbatim → most platforms penalize; rewrite per channel voice.
- Auto-translation without review → cultural misses, embarrassing literal translations.
- Hot-takes scraped from drama threads → reputational risk; filter for tone.
- Long article LLM-generated without source check → hallucinations; require source URLs in the prompt input.

## Output format
```markdown
## Pipeline state
- channels active:
- sources active:
- pending drafts:
- last 24h: <generated> / <published> / <rejected by QA>

## Findings
- correctness / quality:
- compliance (TOS, attribution):
- cost:

## Recommended next 3

## Verification
- one dry-run from source to draft
- one channel adapter sandbox post
```

## Safety rules
- Live posting is a Cost/Risk Gate; first post on a new channel requires approval.
- Never republish copyrighted text without permission; rewriting != licensed.
- Never post on behalf of a person without explicit auth scope they granted.
- Channel API rate limits are hard; pipeline must respect them — do not retry through them.
- Long content specs go to `docs/content-pipeline.md`; chat gets the summary.
