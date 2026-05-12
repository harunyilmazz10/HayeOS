---
name: dependency-audit
description: Execute a dependency audit workflow using local manifests, lockfiles, Haye CLI helpers and approved audit commands.
---

# Haye Skill: dependency-audit

## Purpose
Run the dependency audit workflow and produce an honest dependency security report. This skill is execution-focused; use `dependency-security` for policy and `version-policy` for version selection decisions.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa tüm açıklamalar, özetler, uyarılar, sorular ve yönlendirmeler Türkçe verilecek.
- Komutlar, dosya yolları, paket isimleri, config key'leri ve kod blokları orijinal dilinde kalabilir.
- Kullanıcı açıkça İngilizce istemedikçe İngilizce cevap verme.
- HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.

## Scope
- Inspect dependency manifests and lockfiles.
- Run local read-only audit helpers when available.
- Recommend the next verification command.
- Record audit status and limitations.
- Do not choose new versions by itself; route version selection to `version-policy` and policy interpretation to `dependency-security`.

## Inputs to inspect first
1. `.hayeos.json` and resolved `memoryPath`.
2. `package.json`, lockfile name and package manager.
3. Python, Go, Rust or Docker dependency files if present.
4. `docs/security/dependency-notes.md` if present.
5. `<resolved memoryPath>/02-decisions/safe-dependency-versions.md` when present.

## Workflow
1. Identify ecosystems: npm/pnpm/yarn, Python, Go, Rust, Docker.
2. Inspect manifests and lockfiles without installing dependencies.
3. Run Haye CLI helpers when available:
   - `bin/haye deps-audit`
   - `bin/haye react-nextjs-audit` for React/Next.js projects
4. Propose package-manager audit commands, but do not run install/update/remove commands without explicit approval.
5. If an audit command is already available and read-only, run it when safe; otherwise mark it `not run` with the reason.
6. Summarize findings and route decisions:
   - vulnerable range or `latest` policy issue -> `dependency-security`
   - explicit version choice needed -> `version-policy`

## Report format
```markdown
## Dependency Audit
- ecosystems:
- package manager:
- lockfile:

## Commands run
- command:
- result:

## Findings
- vulnerable / unsafe policy:
- missing lockfile:
- React/Next.js baseline:
- Docker/base image:

## Not run
- command:
- reason:

## Decisions to record
- <resolved memoryPath>/02-decisions/...

## Next actions
1.
2.
3.
```

## Safety rules
- Never run `npm install`, `pnpm add`, `yarn add`, `pip install`, `python -m pip install`, `py -m pip install`, `docker pull`, update or remove commands without explicit user approval.
- Do not claim `secure` or `safe` unless audit/advisory verification was actually run.
- If internet/advisory access is unavailable, say: "current vulnerability status was not verified."
- Do not write project memory outside `<resolved memoryPath>`.
