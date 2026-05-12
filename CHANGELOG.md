# Changelog

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
