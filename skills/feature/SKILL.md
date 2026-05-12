---
name: feature
description: Ship a small, vertical feature slice end-to-end with a clear scope, a test, and a memory note. Not a redesign.
---

# Haye Skill: feature

## Purpose
Ship a single, vertical feature slice: smallest piece of new behavior that a user can notice, fully wired from UI → API → DB → back.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. The user's prompt — what is the user-visible outcome?
2. `<resolved memoryPath>/current.md` and `<resolved memoryPath>/04-tasks/active-task.md` — does this fit the active phase?
3. Existing patterns: where does similar logic live? Match it.
4. Data model — does this require schema change? If yes, this is also a `migration` task.
5. Auth/RBAC — who can access this feature?

## Token discipline
- Read only the files in the vertical slice (UI component + route handler + service + maybe a model).
- Do not read the whole repo to "get a feel" — pick the closest analog and read that.

## Workflow

### Step 1 — Scope cut
- Smallest visible behavior change. If it can be split, split.
- Out of scope (explicit): polish, edge-case states for unimplemented downstream flows, refactor adjacent code.
- Phases (if even this slice is too big): scaffold → core path → error paths → polish.

### Step 2 — Contract
- API: request shape, response shape, error shape.
- DB: any new column / table — that's a separate `migration` step that must happen first.
- UI: states (loading, empty, error, success).
- Permission rule: who can do this?

### Step 3 — Implementation order
1. Migration (if schema change) → applied locally first.
2. Service / business logic with unit test.
3. Route handler (API) with one happy-path integration test.
4. UI wiring, all four states.
5. Manual smoke through the full flow.

### Step 4 — Verification
- Build green.
- Typecheck green.
- Lint green.
- New tests pass.
- Existing tests still pass.
- Manual flow: walk through it once as a user would.

### Step 5 — Polish (only after the core works)
- Loading skeleton, empty state copy, error retry button.
- Accessibility: labels, aria, keyboard.
- This step is bounded — do not re-design.

### Step 6 — Memory and changelog
- `<resolved memoryPath>/current.md`: shift the active task forward.
- `<resolved memoryPath>/changelog.md`: one entry: "Added: <feature>".
- `<resolved memoryPath>/04-tasks/`: archive if complete, else update.

## Anti-patterns to refuse
- "While I'm here, let me also..." — separate task, separate review
- Adding three new dependencies for one feature — separate `dependency-audit` discussion
- Skipping the empty / error states because "it usually works"
- Writing the migration last (after the code is wired) — that's how you ship a feature that 500s in production
- Shipping without one test — at minimum the happy-path integration test

## Output format
```markdown
## Feature in one sentence

## Slice
- in scope:
- out of scope:

## Contract
- API:
- DB change (if any → migration first):
- UI states:
- permission:

## Implementation order (file by file)
1.
2.
3.

## Verification
- build: pass
- tests: pass
- typecheck: pass
- lint: pass
- manual smoke: pass

## Memory updates
- <resolved memoryPath>/current.md: ...
- <resolved memoryPath>/changelog.md: Added: ...
```

## Safety rules
- Don't ship without at least one test.
- Don't push a schema change in the same commit as feature wiring; migration is separate.
- Don't claim "done" without manual smoke through the user flow.
- Don't add `latest` deps for "one helper function"; the skill `dependency-audit` gates it.
- Long feature designs go to `docs/features/<name>.md`; chat gets the summary.

## Path Separation Rule (project source vs memory vault)

Proje dosyaları ve memory dosyaları FARKLI dizinlerde yaşar. Birbirine karıştırılmaz.

### sourcePath (proje kökü) - buraya yazılır
Kullanıcının projesinin gerçekten çalıştığı her şey:
- Kod: `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.html`, `.css`
- Infra: `Dockerfile`, `docker-compose*.yml`, `Procfile`, `.dockerignore`, helm/kustomize
- Config: `.env.example`, `next.config.*`, `tsconfig.json`, `package.json`, `requirements.txt`, `pyproject.toml`, `Makefile`
- Docs: `README.md`, `CHANGELOG.md`, `docs/`, `ADR/`, API specs
- Klasörler: `services/`, `apps/`, `packages/`, `infra/`, `scripts/`, `tests/`, `public/`, `assets/`

### memoryPath (vault) - SADECE memory için
Yapısal proje hafızası:
- `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md`, `<resolved memoryPath>/changelog.md`, `<resolved memoryPath>/health.md`
- `<resolved memoryPath>/01-prompts/`, `<resolved memoryPath>/02-decisions/`, `<resolved memoryPath>/03-bugs/`, `<resolved memoryPath>/04-tasks/`, `<resolved memoryPath>/05-sessions/`, `<resolved memoryPath>/06-prompts/`, `<resolved memoryPath>/07-checklists/`, `<resolved memoryPath>/08-raw/`, `<resolved memoryPath>/09-context-packs/`, `<resolved memoryPath>/10-reviews/`, `<resolved memoryPath>/11-metrics/`, `<resolved memoryPath>/12-risks/`, `<resolved memoryPath>/99-archive/`

### Hard rule
Bir hedef path `<resolved memoryPath>` altındaysa VE şu isimlerden/uzantılardan biriyse -> DUR ve Türkçe uyar:
- `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.html`, `.css`, `.sh`, `.yaml`, `.yml`, `.toml`, `Dockerfile`, `docker-compose*`, `package.json`, `requirements.txt`, `pyproject.toml`, `next.config.*`
- Memory subfolder olmayan klasörler: `services/`, `apps/`, `packages/`, `infra/`, `scripts/`, `tests/`, `public/`, `assets/`

Uyarı mesajı:
"Bu dosya memory vault'una yazılmaya çalışılıyor ama bu proje kodu/dökümanı. Proje kök dizinine (sourcePath) yazılmalı."

Proje için `docs/` gerekiyorsa `<sourcePath>/docs/`'a yazılır, `<memoryPath>/docs/`'a değil.
Proje `README.md`'si `<sourcePath>/README.md`'ye yazılır, `<memoryPath>/README.md`'ye değil.

## Tech stack adherence

Kullanıcı promptu spesifik teknoloji adlandırırsa (FastAPI, Postgres, Prisma, Redis, RabbitMQ, vb.), HayeOS onları kullanır.

### Adı geçen stack'ten sapma
- Açık kabul gerektirir: "Kullanıcı X istedi. Z sebebiyle Y kullanıyorum."
- Kod yazılmadan önce kullanıcı onayı gerektirir
- Sık görülen drift: prompt FastAPI istemiş, HayeOS "daha basit" diye Flask'a uzanmış - bu ihlaldir

### Default safe versions (prompt sessizse)
- Python: 3.12 (3.8/3.9/3.10 yeni projelerde yasak - EOL)
- Node: 20 LTS veya 22 LTS (18 LTS sadece kilitlenmişse)
- Postgres: 16 minimum, 17 tercih
- Docker Compose: v2 syntax (top-level `version: '3'` YOK)

### Sürüm karar kaynağı
Her dependency seçimi ve version pin `<resolved memoryPath>/02-decisions/dependencies-<date>.md`'ye kaydedilir.
