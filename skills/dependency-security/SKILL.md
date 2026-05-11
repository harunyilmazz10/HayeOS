---
name: dependency-security
description: Check dependencies and version choices using package files, audit tools, official advisories and Haye safe-version policy.
---

# Haye Skill: dependency-security

## Purpose
Check dependencies and version choices using package files, audit tools, official advisories and Haye safe-version policy.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS komutları Harun için varsayılan olarak Türkçe konuşur.

## When to use
- Use when the user's request matches this workflow.
- Use when the current project has `.hayeos.json` or an Obsidian memory vault.
- Use instead of loading a huge old conversation or scanning the entire repository.

## Inputs to inspect first
1. `.hayeos.json` if present.
2. Memory root from `memoryPath`.
3. Only minimal memory files:
   - `HAYE.md`
   - `index.md`
   - `current.md`
   - `next.md`
   - `04-tasks/active-task.md` when present.

## Token discipline
- Do not scan the whole Obsidian vault.
- Do not read `08-raw/` unless explicitly required.
- Do not read the whole repo before a context pack is created.
- Prefer summaries, file paths, root causes, decisions and verification outputs over pasted logs.
- If context is growing, recommend `/clear` plus `/haye:start` after `/haye:close`.

## Workflow
1. Locate project config and memory path.
2. Read minimal memory.
3. Identify task type, risks and affected files.
4. Create or reuse a context pack when work is non-trivial.
5. Execute the smallest safe step.
6. Verify with real commands when possible.
7. Update memory through `/haye:close` or session-close rules.

## Output format
- What I found
- What I will do / did
- Risks
- Files touched or to inspect
- Verification command/result
- Memory updates required

## Safety rules
- Do not run destructive commands without explicit approval.
- Do not auto-upgrade dependencies without approval.
- Do not claim safe/fixed/done without verification output or a clear limitation note.

## Dependency / Base Image Safety Rule
- Do not use latest tags in Docker images.
- Do not use placeholder image names like `myapp:latest`.
- Do not use fake image names like `your-*-image` or `placeholder-image`.
- Do not use `image: latest`.
- Do not include Docker Compose top-level `version` field.
- Use modern supported base images with explicit version tags.
- For Python service images, prefer a current supported slim base such as `python:3.12-slim` only if compatible, and record the decision.
- Do not use old/EOL examples such as `python:3.8`.
- If unsure, write the decision to dependency/security notes and mark as pending verification.
- Do not install dependencies blindly.
- Dependency install/update/remove is a risk gate: ask before `pip install`, `python -m pip install`, `py -m pip install`, `npm install`, `pnpm add`, `yarn add`, `docker pull` or Docker commands that pull unknown images.
- Before `docker compose up`, check compose has no fake images, build contexts exist, referenced Dockerfiles exist, no top-level obsolete `version` field and no `latest` tags unless explicitly justified.
- Do not assume `pip` exists on Windows; prefer `py -m pip` or `python -m pip` after checking, and still require approval.
- Do not pin vulnerable EOL versions.


## Embedded React / Next.js security baseline
When a project uses React Server Components, Next.js App Router, middleware/proxy routes, server actions, image optimization or cache components:

- Avoid `react-server-dom-webpack`, `react-server-dom-parcel`, `react-server-dom-turbopack` versions:
  - `19.0.0` through `19.0.5`
  - `19.1.0` through `19.1.6`
  - `19.2.0` through `19.2.5`
- Prefer compatible patched versions:
  - `19.0.6+`
  - `19.1.7+`
  - `19.2.6+`
- For Next.js:
  - 15.x should be `15.5.16+`
  - 16.x should be `16.2.5+`
- Cloudflare WAF is defense-in-depth. It does not replace dependency patching.

## Live advisory rule
If internet is available, check official sources before recommending versions:
- npm registry
- npm audit / pnpm audit / yarn audit
- GitHub Security Advisories
- React advisories
- Next.js/Vercel release notes
- Cloudflare changelog

If live checking is unavailable, state that the result is based on local files and embedded Haye rules only.
