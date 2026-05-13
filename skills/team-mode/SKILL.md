---
name: team-mode
description: Use when work skill classifies a task as massive, large, or full-architecture - produces a multi-perspective plan by sequentially simulating specialist viewpoints inline (no agent dispatch); never invoked directly by user, only via work skill routing
---

# Haye Skill: team-mode

## Purpose

Internal planning mode for `/haye:work`. Produces a Team Mode Plan by walking through 5 mandatory + 4 conditional specialist perspectives **inline, in this skill, in the main conversation**. No Task tool dispatch. No subagent calls.

## Why no Task tool here

In Claude Code, plugin-namespaced agents (`haye:project-manager`, etc.) historically failed:
- `Skill(haye:project-manager)` produced "Unknown skill"
- Task tool calls with `subagent_type="haye:project-manager"` produced "Invalid tool parameters"

Specialist perspectives are now embedded as PROCESS within this skill. You (Sonnet) walk through each perspective sequentially, producing 3-7 bullets per perspective. This works in every environment.

DO NOT call the Task tool from this skill. DO NOT call `Skill(haye:<role-name>)`. Just walk the perspectives below in order.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe; komutlar/path/identifier İngilizce.

## When work skill routes here

Massive Task Classification Rule veya kullanıcının doğrudan "Team Mode" / "Full Architecture Mode" seçtiği durumlarda.

Triggers (work skill from):
- sıfırdan production-grade proje
- çok servisli sistem
- AI/media pipeline
- database + API + frontend + deploy beraber
- güvenlik/auth/payment içeren iş
- belirsiz/çok geniş prompt
- premium/multi-section landing/marketing site (Hero + Services + About + Contact + Form gibi)

## Execution Contract

1. Read `.hayeos.json`, resolve `memoryPath`
2. Read minimal memory: `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/04-tasks/active-task.md` if present
3. Walk through 5 MANDATORY perspectives below in order
4. Walk through 4 CONDITIONAL perspectives ONLY IF triggering signal present in the prompt
5. Produce one unified Team Mode Plan in the output format below
6. Write specialist summaries to `<resolved memoryPath>/10-reviews/team-mode/<perspective>-<YYYY-MM-DD>.md`
7. Ask one approval question
8. STOP - do not proceed to implementation in this skill

## MANDATORY perspectives - walk all 5

Each perspective: 3-7 bullets, applied to THIS specific task, NOT generic advice.

---

### Perspective 1 — Project Manager

What to look for:
- Implicit scope creep: prompt asks for a feature but also infra/monitoring/migration
- Missing phase boundaries: "do everything" without phase 0/1/2 split
- Hidden blockers: missing credentials, decisions, infra, approvals
- Duplicated effort: overlaps with `<resolved memoryPath>/current.md` in-progress work
- Risk concentration: too many high-risk items in one phase

Output for THIS task:

```markdown
**Project Manager — Scope & Phases**

- In scope: <concrete list for this task>
- Out of scope: <what is NOT being built>
- Phase 0 (setup): <what gets scaffolded first>
- Phase 1 (core): <minimum viable deliverable>
- Phase 2 (polish): <enhancements after core is shipped>
- Risk concentration: <high-risk items grouped or split>
- Hidden blockers: <what could block progress>
```

---

### Perspective 2 — Memory Architect

What to look for:
- `<resolved memoryPath>/current.md` or `<resolved memoryPath>/next.md` past 180 lines
- Stale `<resolved memoryPath>/04-tasks/active-task.md` not matching `<resolved memoryPath>/current.md`
- Raw files in `<resolved memoryPath>/08-raw/` never summarized
- Decisions scattered, not in `<resolved memoryPath>/02-decisions/`
- Risks mentioned but missing from `<resolved memoryPath>/12-risks/`
- Duplicate/contradictory entries between core memory files

Output for THIS task:

```markdown
**Memory Architect — Vault Plan**

- New decisions to write to `<resolved memoryPath>/02-decisions/`: <list with filenames>
- Risks to capture in `<resolved memoryPath>/12-risks/`: <list>
- Updates to `<resolved memoryPath>/current.md`: <one-line summary>
- Updates to `<resolved memoryPath>/next.md`: <next concrete action>
- Context pack needed?: <yes/no, with filename if yes>
- Vault health: <issues found, if any>
```

---

### Perspective 3 — Security Reviewer

What to look for:
- Auth: missing session/RBAC on writes; client-only checks
- Authorization: ownership checks on mutations
- Secrets: hardcoded keys, committed env, secrets in logs/errors/bundles
- Dependencies: EOL versions, known-vulnerable baselines
- Exposed ports: DB, Redis, admin reachable publicly
- Webhooks: signature verification, replay protection
- SSRF / open redirect / file upload paths
- CSRF on state-changing endpoints
- Rate limiting on auth/abuse-prone endpoints
- Payment: signature, idempotency, server-side amount
- PII/credentials in logs

Output for THIS task:

```markdown
**Security Reviewer — Surface Area**

- Auth model needed: <none / session-cookie / JWT / Clerk / NextAuth>
- Secrets in scope: <list, where they live>
- Exposed surface: <public endpoints, admin routes, webhooks>
- Rate-limit targets: <endpoints needing limits>
- Top 3 abuse vectors: <listed concretely>
- Out-of-scope security topics: <what does NOT apply to this task>
```

For a static landing page with no backend: security surface is minimal. Note this explicitly - do not invent risks that don't exist.

---

### Perspective 4 — Release Manager

What to look for:
- No verification artifacts: build/test/lint/typecheck not run
- Changelog drift: code changed, no `<resolved memoryPath>/changelog.md` entry
- Version drift: `package.json` version stale or bumped without entry
- Migration not applied locally before merge
- Open high risk in `<resolved memoryPath>/12-risks/`, no mitigation
- Missing rollback path
- "Production-ready" claimed without No Fake Completion evidence

Output for THIS task:

```markdown
**Release Manager — Verification & Release Plan**

- Required verification commands: <list of npm/yarn/pnpm commands to run>
- Exit criteria for "shippable": <concrete bullet list>
- Rollback plan: <how to undo if release fails>
- Changelog entries to add: <list>
- Version bump?: <yes 0.1.0 / no / patch only>
- Risk-to-mitigation map: <if open risks exist>
```

---

### Perspective 5 — Token Economist

What to look for:
- Long pasted logs that should be `head -N` + `grep`
- Full repo scans for one-file question
- Repeated reading of same file
- `<resolved memoryPath>/current.md` past 180 lines
- Architecture content written into chat instead of `docs/`
- Role outputs longer than 7 bullets
- Same explanation re-stated 3+ times

Output for THIS task:

```markdown
**Token Economist — Budget Plan**

- Estimated turn budget: <small / medium / large / very large>
- Context pack recommended?: <yes/no, with target path>
- Files to AVOID reading in full: <list>
- Phase boundaries for /haye:close: <where to split sessions>
- Long artifacts that go to docs/, not chat: <list of file paths>
```

---

## CONDITIONAL perspectives - apply ONLY when triggering signal exists

### Conditional 1 — Database Architect (apply if data model, migration, indexing, retention matters)

What to look for:
- Schema: nullable columns that should be NOT NULL, missing @unique
- Indexes: FKs without matching index, missing compound indexes
- IDs: integer autoincrement leaking in URLs (suggest cuid/uuid/ULID)
- Migrations: rename masquerading as drop+add, no down-migration, DDL+DML same step on large table
- Connection: missing pooler in serverless, connection_limit not set
- Backups: no pg_dump, no PITR, no restore drill
- Exposure: Postgres reachable on 5432 publicly, committed creds

Output for THIS task (only if DB matters):

```markdown
**Database Architect — Schema Plan**

- Tables: <list with key fields>
- Indexes: <listed by table>
- ID strategy: <int / uuid / cuid>
- Migration risks: <if any>
- Backup plan: <yes/no/deferred>
- Connection pooling: <required/optional>
```

### Conditional 2 — API Integrator (apply if APIs, service contracts, webhooks, queues matter)

What to look for:
- Auth shape: API key vs OAuth vs HMAC; secret rotation
- Idempotency on writes
- Bounded retries with jitter, only 408/429/5xx
- Rate limits documented
- Explicit timeouts (no infinite default)
- Webhook signature verification, replay protection
- Observability without secrets in logs
- Cost: paid API behind feature flag/quota
- Secrets never logged/returned/echoed

Output for THIS task (only if API integration matters):

```markdown
**API Integrator — Integration Plan**

- External APIs: <list with auth shape>
- Idempotency keys: <yes/no per endpoint>
- Retry/timeout policy: <concrete numbers>
- Webhook validation: <signature/secret source>
- Cost guards: <feature flag / quota>
```

### Conditional 3 — Deployment Doctor (apply if Docker, Coolify, Cloudflare, env, healthcheck matters)

What to look for:
- Dockerfile: multi-stage missing, npm ci not used, `:latest` base
- Compose: top-level `version` (obsolete), `depends_on` without health, host port binds
- Coolify: missing healthcheck, env mismatch, build pack wrong
- Traefik: placeholder Host rule, missing certResolver
- Cloudflare: SSL "Flexible" instead of "Full strict"
- 522/524: origin slow start, healthcheck mismatch
- Env: DATABASE_URL sslmode mismatch, NEXTAUTH_URL drift, secrets in build logs
- Healthcheck doing DB query (bad)
- Rollback: no tagged image, no migrate resolve note
- Observability: no log shipping, no error tracker

Output for THIS task (only if deployment matters):

```markdown
**Deployment Doctor — Deployment Plan**

- Container strategy: <Dockerfile / Nixpacks / static>
- Orchestrator: <Coolify / Docker Compose / Vercel / static host>
- Healthcheck endpoint: <path, response shape>
- Env vars: <list>
- SSL/CDN config: <Cloudflare mode, Traefik / Vercel auto>
- Rollback path: <concrete steps>
```

### Conditional 4 — UI Polisher (apply if frontend/dashboard/UX matters)

What to look for:
- Missing states: loading skeleton, empty (CTA), error (retry), success (confirm)
- Layout: content shifting on async load, button size jumps, table overflow on mobile
- A11y: form labels, icon button aria-label, color-only error, focus rings, alt text
- Forms: inline validation, aria-invalid, disabled+spinner on submit
- Touch targets < 40px on mobile
- Copy: replace "Submit"/"Click here"/"Something went wrong" with verb + cause
- Dark mode: hardcoded text-gray-900 without dark variant
- Motion: large animations without prefers-reduced-motion

Output for THIS task (only if UI matters):

```markdown
**UI Polisher — Quality Bar**

- States to implement per component: <list>
- A11y must-haves: <list>
- Mobile/responsive plan: <breakpoints, touch targets>
- Dark mode strategy: <yes/no/system-only>
- Motion approach: <transitions, reduced-motion respect>
```

### Conditional 5 — Bug Investigator (apply only if debugging/root-cause work present)

This is a different mode entirely - only walked if `/haye:fix` was invoked or the task is explicitly debugging.

For Team Mode planning of NEW work, skip bug investigator.

## Output format — Unified Team Mode Plan

After walking through all applicable perspectives, produce:

```markdown
# HayeOS Team Mode Plan

## 1. Task Classification
- task_size: <small / medium / large / massive>
- task_type: <feature / refactor / migration / full-build / launch / fix>
- risk_level: <low / medium / high>
- affected_layers: <list>
- recommended_mode: <Team Mode / Full Architecture Mode>

## 2. Specialist Perspectives Applied
<list which perspectives ran, why others were skipped>

## 3. Findings — by perspective
<insert each perspective's output here, in order>

## 4. Unified Implementation Plan
- Phase 0 (setup): <concrete steps with file paths and commands>
- Phase 1 (core): <concrete steps>
- Phase 2 (polish): <concrete steps>
- Phase 3 (verify+ship): <concrete steps>

## 5. Risks & Assumptions
- <list>

## 6. Verification Plan
- <command per layer with expected output>

## 7. HayeOS Memory Update Plan
- Files to create in `<resolved memoryPath>/02-decisions/`: <list>
- Files to create in `<resolved memoryPath>/12-risks/`: <list>
- `<resolved memoryPath>/current.md` update: <one-line summary>
- `<resolved memoryPath>/next.md` update: <next action>

## 8. Approval Question
Bu planı onaylıyor musun? Onaylarsan Phase 0 ile başlayacağım.
```

## Approval Friction Rule

Plan onaylandıktan sonra küçük güvenli işleri tek tek sorma. Risk kapısı (rm, drop, deploy, migration, payment) veya scope değişiminde onay iste.

## No Fake Completion Rule

Doğrulama çıktısı olmadan tamamlandı/geçti/production-ready deme. Build/test/lint/typecheck çalışmadıysa açıkça belirt.

## Quality Preservation Rule

Token discipline implementation quality'yi azaltamaz. Test/validation/security/error handling/architecture reasoning skip edilemez. Token tasarrufu: verbose chat çıktısı, gereksiz repo scan, büyük log paste, fazla rapor.

## Stub Plan Ban

Specialist perspective output'larında YASAK ifadeler:
- "burada oluşturulacak"
- "ileride detaylandırılacak"
- "X yapılandırılacaktır"
- "..." section body olarak
- "TBD" / "TBA"

Her perspective output'u 3-7 GERÇEK madde içerir veya skip edilir.
