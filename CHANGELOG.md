# Changelog

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
