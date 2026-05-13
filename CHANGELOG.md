# Changelog

## 2.0.2
- Fixed `/haye:start` regression that wrote `.hayeos.json` and `<project-name>_obs` into Claude internal `~/.claude/projects/...` storage instead of the real project root
- Restored canonical project-local vault initialization: `./<project-name>_obs`
- Fixed `/haye:start` / init-memory regression that manually synthesized invalid Windows `.hayeos.json`
- Re-established the real current working directory as the only default project root for HayeOS init
- Re-established `bin/haye init` as the single source of truth for default config generation
- Prevented accidental fallback to `~/.claude/projects/.../memory` as the default project memory path
- Updated `/haye:start` to show the full active semantic version, e.g. `HayeOS v2.0.2 aktif`
- Added dynamic anti-regression verification for canonical init behavior and valid JSON config generation

## 2.0.1
- Fixed Team Mode specialist dispatch: HayeOS agents are subagents, not skills
- Prevented invalid `Skill(haye:<agent-name>)` calls that caused `Unknown skill` runtime errors
- Added explicit Skill vs Agent namespace guidance to Team Mode, work routing, using-hayeos, README, docs, and CLAUDE.md
- Added anti-regression verification to reject agent-as-skill references
- Added HayeOS version visibility via start/version/update flows
- Added `/haye:version` command for quick local version inspection
- Upgraded `/haye:update` to report before/after version, safe pull status, and HayeOS-specific plugin cache refresh guidance
- Added anti-regression verification for version/update contract

## 2.0.0
- BREAKING: skill description format zorunlu trigger-style oldu
- BREAKING: SessionStart hook ile using-hayeos master skill her oturumda otomatik enjekte ediliyor
- NEW: using-hayeos master orchestrator skill (Red Flags tablosu, Iron Law, mandatory invocation triggers)
- NEW: Iron Law + Red Flags + Gate Function blokları work, feature, fix, secure, ship skill'lerinde
- NEW: Skill chaining REQUIRED SUB-SKILL blokları feature->work, work->checkpoint, work->close, close->session-close
- NEW: tests/skill-triggering/ test infrastructure (run-test.sh + naive prompt'lar + run-all.sh)
- NEW: tests/explicit-skill-requests/ - skill adı açıkça verilen senaryolar
- NEW: CLAUDE.md plugin root'unda - contributor + behavior philosophy
- NEW: hooks/session-start.sh + Windows-safe hook invocation strategy
- CHANGED: 47 skill description hepsi yeniden yazıldı (trigger-style format)
- ANTI-REGRESSION: check_skill_descriptions_use_when_pattern, check_test_infrastructure_exists verify.sh'a eklendi

## 1.0.1
- Path Separation Rule eklendi (sourcePath <-> memoryPath ayrımı; vault'a kod/infra/docs yazımı yasak)
- Plan Depth Rule eklendi (Full Architecture Mode için stub-plan reddi, service count adherence)
- No Fake Completion Rule güçlendirildi (docker compose ps şartı, echo endpoint disclaimer'ı, kanıtsız yasak ifadeler)
- Team Mode mandatory enforcement: token-economist her zaman zorunlu, adı geçen agent atlanamaz
- Loop ve confirmation spam prevention eklendi (aynı output/dosya tekrarı, "devam edelim" yorumu)
- Tech stack adherence: prompt'taki teknolojiden sapma onay gerektirir, default Python 3.12 / Node 20+/Postgres 16+
- verify.sh'a check_path_separation_and_workflow_rules anti-regression check'i

## 1.0.0
- Full Haye plugin with simplified daily commands, advanced skills, Obsidian memory, dependency security, React/Next/Cloudflare rules, CLI and examples.
