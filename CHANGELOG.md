# Changelog

## 2.1.0
- **BREAKING (internal)**: Removed `agents/` directory entirely. Plugin agents (project-manager, security-reviewer, etc.) never worked reliably in Claude Code runtime - Skill() invocation produced "Unknown skill", Task subagent dispatch produced "Invalid tool parameters". User-facing slash commands and vault structure are unchanged.
- Specialist perspectives (10 of them) are now embedded as inline process inside `skills/team-mode/SKILL.md`. Sonnet walks through them sequentially in the main conversation. No tool dispatch, no namespace issues.
- Added **ABSOLUTE FIRST STEP** block to `skills/work/SKILL.md` - work skill MUST produce a Task Classification + mode recommendation + approval question before any sub-skill routing. Prevents the work -> feature drift seen in test6/test7/test8.
- Added **Auto-Invoke Ban** to `skills/feature/SKILL.md` - feature skill cannot be auto-invoked from a user prompt. Only via work skill's Mandatory Routing AFTER mode approval.
- Added **Gate Function** to `skills/using-hayeos/SKILL.md` - mechanical pre-claim check that catches "başarıyla / tamamlandı / oluşturuldu" claims following tool errors. Direct fix for test8 fake-completion-after-invalid-tool-parameters pattern.
- ANTI-REGRESSION: Six new verify.sh checks for the v2.1.0 contracts.

## 2.0.4
- Fixed agent dispatch failure mode: team-mode skill now shows explicit Task tool syntax (subagent_type, prompt) with concrete examples; banned Skill(haye:<agent-name>) shape that produces "Unknown skill"
- Fixed `/haye:start` version placeholder bug (`HayeOS v<full semantic plugin version> aktif` was being literal-copied); replaced with `HayeOS aktif.` + pointer to `/haye:version`
- Added Next.js Project Initialization Defaults to work skill: App Router default, Tailwind 4 PostCSS config, forbidden Pages Router after create-next-app
- Added Windows Shell Awareness to work skill: rmdir /S /Q and del do not work in Bash tool; use POSIX or PowerShell wrapper
- Added File Modification Tool Preference to work skill: prefer Edit over Update for existing files (Update can duplicate lines)
- Updated session-close-reminder.sh as best-effort fake-completion-and-no-close warning (non-blocking)
- Added Stub Plan Trap section to using-hayeos with banned phrase examples from test7 evidence
- Added Path Resolution Rule to init-memory: memoryPath always resolves against cwd, never `~`
- ANTI-REGRESSION: check_stub_plan_phrases_banned added to verify.sh

## 2.0.3
- Fixed feature skill description that incorrectly used brainstorming-skill phrasing, causing wrong-skill routing after work mode selection
- Fixed feature skill Verification template that emitted "build: pass / tests: pass" placeholder language; replaced with checklist requiring actual command output and exit codes
- Added Landing Page / Static UI Scope Guard to prevent marketing-site requests from being silently expanded into CRUD/API/database work
- Added Prompt Fidelity Guard so plans must preserve the user's actual objective and may not silently shift domains
- Fixed work skill routing after mode selection: explicit mapping Full Architecture / Team Mode -> `Skill(haye:team-mode)`, no inline plan improvisation
- Fixed `/haye:start` init approval flow: explicit "IMMEDIATELY call `Skill(haye:init-memory)`" + "DO NOT Write directly" instead of soft `/haye:init-memory` wording
- Added Windows SessionStart execution robustness: `hooks/session-start.cmd` + `hooks/session-start.py` + thin `.sh` wrapper
- Strengthened triggering descriptions for team-mode, checkpoint, close, init-memory skills
- Added Verification Template Trap, Init Memory Trap, Mode Selection Trap sections to `using-hayeos`

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
