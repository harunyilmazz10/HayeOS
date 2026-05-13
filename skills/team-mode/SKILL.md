---
name: team-mode
description: Use when work skill classifies a task as massive, large, or full-architecture - coordinates specialist agent dispatch and produces the architecture plan; never invoked directly by user, only via work skill routing
---

# Haye Skill: team-mode

## Purpose
Internal planning mode for `/haye:work`. Do not expose a separate `/haye:team` user command.

## Agent Invocation Rule

Specialist roles under `agents/` are not skills. They are subagents/agents.

NEVER attempt to call specialist roles through the Skill tool. Agent-as-skill calls such as using `project-manager`, `token-economist`, or `security-reviewer` with a `Skill(haye:<agent-name>)` shape are invalid and produce `Unknown skill`.

Team Mode must use the Claude Code agent/subagent execution mechanism for these roles.
Skills orchestrate. Agents investigate, design, review, and advise.

### Namespace separation
- Skills live under `skills/` and are invoked with the Skill tool, for example `haye:team-mode`, `haye:work`, `haye:feature`, `haye:checkpoint`.
- Agents live under `agents/` and must be dispatched as agents/subagents, for example `project-manager`, `memory-architect`, `database-architect`, `api-integrator`, `security-reviewer`, `deployment-doctor`, `release-manager`, `token-economist`, `bug-investigator`, `ui-polisher`.
- Team Mode coordinates skills plus agents; it must not confuse the two namespaces.

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

## Required roles
- Dispatch the `project-manager` agent.
- Dispatch the `memory-architect` agent.
- Dispatch the `security-reviewer` agent.
- Dispatch the `release-manager` agent.
- Dispatch the `token-economist` agent.

## Conditional roles
- Dispatch the `database-architect` agent when data model, migration, indexing or retention matters.
- Dispatch the `api-integrator` agent when APIs, service contracts, webhooks or queue/events matter.
- Dispatch the `deployment-doctor` agent when Docker, Coolify, Cloudflare, env, healthcheck, rollback or observability matters.
- Dispatch the `ui-polisher` agent when frontend/dashboard/UX matters.
- Dispatch the `bug-investigator` agent when debugging/root-cause work is present.

## Token-economist rule
`token-economist` is always included. It limits repo scanning, prevents repeated findings, recommends context packs, splits large work into phases/sessions, avoids raw/log reads, and reminds `/haye:close` at phase boundaries.

## Team Mode execution contract
1. `haye:team-mode` skill loads as the orchestration skill.
2. It selects specialist agents.
3. It dispatches selected specialists as agents/subagents, not skills.
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
