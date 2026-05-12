---
name: version-policy
description: Decide explicit dependency versions using semver, compatibility, lifecycle status and advisory evidence.
---

# Haye Skill: version-policy

## Purpose
Choose explicit dependency versions without blindly using `latest`. This skill is a decision framework; use `dependency-audit` to collect evidence and `dependency-security` to interpret security policy.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Decision inputs
1. Current manifest and lockfile versions.
2. Framework compatibility matrix (`next`, `react`, `react-dom` together).
3. Advisory evidence from package manager audit or official sources.
4. Runtime compatibility: Node/Python version, Docker base image, platform constraints.
5. Existing decisions in `<resolved memoryPath>/02-decisions/` or `docs/security/dependency-notes.md`.

## Version selection rules
- Prefer the smallest stable patched explicit version that resolves the risk and remains compatible.
- Avoid unplanned major upgrades unless the current major is EOL or vulnerable with no patched release.
- Never recommend `latest`, floating Docker tags, or fake placeholder image tags.
- Do not pin vulnerable EOL versions.
- If live advisory/version access is unavailable, say: "current vulnerability status was not verified."
- If the embedded React/Next.js baseline is older than 90 days, prefer a live advisory check before finalizing.

## Semver decision framework
```markdown
## Version Decision
- package:
- current:
- proposed:
- change type: patch / minor / major
- reason:
- advisory evidence:
- compatibility checks:
- rollback plan:
- install/update command: requires approval / not run
- decision file: <resolved memoryPath>/02-decisions/<topic>.md
```

## React / Next.js compatibility
- Choose `next`, `react` and `react-dom` as a compatible explicit-version set.
- Check known RSC, SSR, middleware/proxy, server action and image optimization advisories.
- Do not upgrade only one package in the set unless official compatibility notes support it.
- Record whether `npm audit`, `pnpm audit`, `yarn audit` or live advisory checks were run.

## Docker/base images
- Use supported explicit tags, for example a current `python:3.12-slim` only when compatible.
- Do not use `python:3.8`, `image: latest`, `myapp:latest`, `your-*-image` or `placeholder-image`.
- Check compose has no obsolete top-level `version` field before recommending Docker verification.

## Safety rules
- Version choice is not the same as installing it. Dependency install/update/remove remains an approval risk gate.
- Record selected version decisions in `<resolved memoryPath>/02-decisions/` or `docs/security/dependency-notes.md`.
- Do not claim a version is `secure` or `safe` without audit/advisory evidence.
