---
name: team-mode
description: Use when work skill classifies a task as massive, large, or full-architecture - coordinates specialist agent dispatch and produces the architecture plan; never invoked directly by user, only via work skill routing
---

# Haye Skill: team-mode

## Purpose
Internal planning mode for `/haye:work`. Do not expose a separate `/haye:team` user command.

## Agent Invocation Rule

Specialist roles under `agents/` are subagents, dispatched via the **Task tool**. They are NOT skills.

### How to actually dispatch an agent (this is the rule)

To invoke any specialist agent, use the Task tool with this exact shape:

```text
Task(
  description: "<short 3-5 word task description>",
  subagent_type: "<agent-name>",     # e.g. "project-manager", "security-reviewer"
  prompt: "<full instructions for the subagent>"
)
```

Plugin-namespaced form also works in Claude Code:
- `subagent_type: "haye:project-manager"` (preferred for clarity)
- or `subagent_type: "project-manager"` (works if no name collision)

### Concrete dispatch example

To dispatch the project-manager for a Next.js doctor landing page:

```text
Task(
  description: "Scope and phase the landing page work",
  subagent_type: "haye:project-manager",
  prompt: |
    You are the project-manager agent for HayeOS Team Mode.

    Project: Premium doctor landing page (Next.js App Router, TypeScript, Tailwind, Framer Motion)
    Current vault: <resolved memoryPath>

    Read first: .hayeos.json, <resolved memoryPath>/current.md, <resolved memoryPath>/next.md

    Output the agent format defined in agents/project-manager.md (max 7 bullets per section):
    - Scope (in/out, explicit cuts)
    - Phases (with goal, exit criteria)
    - Risks (top 3-5)
    - Blockers (missing decisions, credentials, approvals)
    - Suggested next 3 actions
)
```

### Forbidden - common mistakes

NEVER call agents through:
- `Skill(haye:project-manager)` - produces "Unknown skill" error (test7 evidence: 5 such errors)
- `Bash(bin/haye project-manager)` - the CLI does not accept agent names as commands
- `Bash(haye project-manager)` - same
- Just writing "Now invoking project-manager" without an actual Task() call - this is the prose-instead-of-tool failure mode

If you find yourself typing `Skill(haye:<agent-name>)`, STOP. Use Task instead.

### Natural language form

Claude Code also accepts natural language for subagent dispatch:

> "Use the haye:project-manager subagent to scope and phase this work, then return findings."

This is equivalent to the Task tool call above and Claude Code auto-routes. Either form is acceptable; the Task() form gives more control over the prompt.

### Namespace separation
- Skills live under `skills/` and are invoked with the Skill tool (e.g. `haye:team-mode`, `haye:work`, `haye:checkpoint`).
- Agents live under `agents/` and must be dispatched with the **Task tool**.
- Team Mode coordinates skills + agents; it must not confuse the two namespaces.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## When to use
- sıfırdan proje
- büyük mimari
- çok servisli sistem
- AI pipeline
- media pipeline
- database + API + frontend + deploy beraber
- güvenlik/auth/payment içeren iş
- Kubernetes/Docker/Coolify/deploy işi
- performans/scaling işi
- belirsiz veya çok geniş prompt

## Required roles (always dispatched via Task tool)

For every Team Mode invocation:

- Task(subagent_type: "haye:project-manager", ...)
- Task(subagent_type: "haye:memory-architect", ...)
- Task(subagent_type: "haye:security-reviewer", ...)
- Task(subagent_type: "haye:release-manager", ...)
- Task(subagent_type: "haye:token-economist", ...)

## Conditional roles (Task tool when relevant)

- Task(subagent_type: "haye:database-architect", ...) - when data model, migration, indexing, retention matters
- Task(subagent_type: "haye:api-integrator", ...) - when APIs, service contracts, webhooks, queues matter
- Task(subagent_type: "haye:deployment-doctor", ...) - when Docker, Coolify, Cloudflare, env, healthcheck matters
- Task(subagent_type: "haye:ui-polisher", ...) - when frontend/UX matters
- Task(subagent_type: "haye:bug-investigator", ...) - when debugging/root-cause work is present

## Token-economist rule
`token-economist` is always included. It limits repo scanning, prevents repeated findings, recommends context packs, splits large work into phases/sessions, avoids raw/log reads, and reminds `/haye:close` at phase boundaries.

## Team Mode execution contract
1. `haye:team-mode` skill loads as the orchestration skill.
2. It selects specialist agents.
3. It dispatches selected specialists USING THE TASK TOOL (not Skill, not Bash).
   Each dispatch is a separate Task() call with subagent_type and prompt.
4. It collects agent outputs sequentially or in parallel according to runtime support.
5. It synthesizes outputs into one plan.
6. It writes specialist summaries to `<resolved memoryPath>/10-reviews/team-mode/<agent>-<date>.md` when memory is active.
7. It never claims specialist perspectives were applied unless the relevant agents were actually dispatched or the user explicitly approved skipping them.

## Output format
```markdown
# HayeOS Team Mode Plan

## 1. Task Classification
- task_size:
- task_type:
- risk_level:
- affected_layers:
- recommended_mode:

## 2. Selected Specialist Roles

## 3. Role Findings
Her rol 3-7 kısa, uygulanabilir madde yazar. Uzun teori ve tekrar yok.

## 4. Unified Implementation Plan

## 5. Risks & Assumptions

## 6. Verification Plan

## 7. HayeOS Memory Update Plan

## 8. Approval Question
Bu planı onaylıyor musun? Onaylarsan Phase X ile başlayacağım.
```

## Approval Friction Rule
Plan veya phase onaylandıktan sonra küçük güvenli işleri tek tek sorma. Risk kapısı, scope değişimi veya phase geçişinde onay iste.

## No Fake Completion Rule
Doğrulama çıktısı olmadan tamamlandı/geçti/production-ready deme. Build/test/lint/typecheck çalışmadıysa açıkça belirt.

## Output Budget Rule
- Chat cevabını kısa tut; varsayılan 1500-3000 token, büyük işler için en fazla 5000-6000 token hedefle.
- Role findings kısa olsun: her agent en fazla 3-7 madde yazsın.
- Büyük mimari, roadmap, servis planı, DB planı, event/queue schema ve deployment planı gibi uzun içerikleri chat'e değil dosyalara yaz.
- Full Architecture Mode detaylarını `docs/architecture.md`, `docs/roadmap.md`, `docs/services.md`, `docs/events.md` veya HayeOS vault dosyalarına taşı.
- Chat'te kısa özet, dosya listesi, kararlar, doğrulama durumu, sıradaki 3 adım ve gerekiyorsa onay sorusu kalsın.

## Quality Preservation Rule
- Token discipline must never reduce implementation quality.
- Do not skip necessary code reading, tests, validation, security checks, error handling, or architecture reasoning just to save tokens.
- Save tokens by reducing verbose chat output, repeated explanations, unnecessary repo scans, huge pasted logs, and oversized reports.
- Detailed technical artifacts should be written to files when needed.
- Chat should be concise, but code and project files must remain complete, maintainable, secure, and production-quality.
- If token saving conflicts with correctness, correctness wins.
- If speed conflicts with safety, safety wins.
