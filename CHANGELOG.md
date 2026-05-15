# Changelog

## 3.0.1 — HARD-GATE Hook Enforcement

v3.0.0 enforced HARD-GATE in markdown only. Real-world test (`/haye:start` + `/haye:work` "basit hello world") showed Sonnet 4.6 bypasses markdown rules — auto-running `bin/haye init` without asking, and `Write(hello_world.py)` without presenting a design. v3.0.1 moves the enforcement from markdown to the tool layer via Claude Code PreToolUse hooks.

### Hooks (deterministic enforcement)

- **dangerous-command-guard** extended: blocks any `bin/haye init` / `haye.cmd init` / `haye.ps1 init` / `haye init-config` invocation that doesn't include the env var prefix `HAYE_INIT_APPROVED=1`. The init-memory skill is the only place that should set this env var, and it only runs after `/haye:start` has explicitly asked "Bu projede HayeOS hafızası bulunamadı. Şimdi otomatik oluşturayım mı?" and received "evet" / "tamam" / "onayla".
- **brainstorming-gate** new hook (PreToolUse:Write|Edit|MultiEdit): denies code/file creation outside the memory vault while the marker file `.hayeos-state/awaiting-design-approval` exists. `/haye:work` creates this marker before invoking brainstorming; brainstorming deletes it only after the user explicitly approves the design.

### Skill updates

- `skills/start/SKILL.md` — explicit 4-step ABSOLUTE WORKFLOW at the top, with no-op branch when `.hayeos.json` exists, ask-and-stop branch when it doesn't, no auto-loading of init-memory.
- `skills/work/SKILL.md` — adds marker file creation step (`.hayeos-state/awaiting-design-approval`) before brainstorming handoff.
- `skills/brainstorming/SKILL.md` — checklist step 9 is now "Remove the brainstorming-gate marker — once the user has explicitly approved the design." Includes Windows + Unix delete commands.
- `skills/init-memory/SKILL.md` — every init command in the cross-platform attempt order is now prefixed with `HAYE_INIT_APPROVED=1`. First successful attempt stops the chain (no more 6-attempt token waste).
- `skills/using-hayeos/SKILL.md` — adds `<HARD-GATE-HOOKS>` block to the SessionStart context, explaining how the two hooks enforce the workflow.

### Quality-of-life

- `bin/haye.cmd` — adds `PYTHONUNBUFFERED=1`, `PYTHONIOENCODING=utf-8`, and `python -u` flag. Fixes Windows stdout buffering that caused Claude Code to mark first call as "Waiting..." and silently retry with 5 alternatives.

### Verify additions

`scripts/verify.sh` now runs 20 checks (4 new):
- brainstorming-gate hook present and executable
- dangerous-command-guard enforces init HARD-GATE
- hooks.json registers brainstorming-gate for Write|Edit|MultiEdit
- init-memory uses HAYE_INIT_APPROVED=1 env var

## 3.0.0 — Major Architectural Reset

This release is a foundational rebuild. HayeOS v2.x and earlier tried to instill discipline by adding more written rules. Real-world testing (test6, test7, test8 sessions) proved this hits a ceiling: Sonnet 4.6 reads the rules, even quotes the Iron Law verbatim, but routinely violates them at execution time.

v3.0.0 takes a different path: **mechanical discipline through the Superpowers process model**. Instead of one Sonnet self-policing against written rules, work flows through brainstorming -> writing-plans -> subagent-driven-development, where each task is implemented by a fresh subagent and then verified by two separate review subagents (spec compliance + code quality). The orchestrator cannot unilaterally declare success; three dispatches must agree.

### What's NEW

Thirteen new core skills, adapted from Obra's Superpowers plugin (https://github.com/obra/superpowers), with permission and credit:

- **brainstorming** — HARD-GATE: no implementation skill, no code, no scaffolding until a design is presented and the user approves. Applies to every project regardless of perceived simplicity.
- **writing-plans** — turns approved spec into a bite-sized implementation plan with exact file paths, complete code in every step, expected command output, and frequent commits. No "TBD", no "implement later", no stub sections.
- **subagent-driven-development** — executes plan task-by-task: dispatch implementer subagent, then spec-reviewer subagent, then code-quality-reviewer subagent. Re-dispatch on findings. Move to next task only when both reviews approve.
- **executing-plans** — fallback for environments where subagent dispatch isn't ideal.
- **dispatching-parallel-agents** — 2+ independent failures investigated in parallel via concurrent subagent dispatch.
- **test-driven-development** — Iron Law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Watch the test fail, write minimal code, refactor.
- **verification-before-completion** — Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE. Gate function before every "done"/"works"/"passes"/"başarıyla" claim.
- **systematic-debugging** — strict procedure for bugs, errors, unexpected behavior.
- **requesting-code-review** — dispatch a code reviewer subagent after each task, before merge, on major features.
- **receiving-code-review** — when feedback arrives, verify technically against codebase reality before implementing; reasoned pushback over performative agreement.
- **using-git-worktrees** — isolated workspace via native tooling or git worktree fallback before feature work or plan execution.
- **finishing-a-development-branch** — merge/PR/cleanup decision flow when implementation is complete.
- **writing-skills** — TDD applied to skill documentation: write pressure test, watch baseline fail, write skill, watch test pass, refactor.

Each Superpowers-derived skill includes a HayeOS Layer section adding Turkish UX rules, memory vault integration (plans -> `04-plans/`, specs -> `02-decisions/`, reviews -> `10-reviews/`), and Path Separation enforcement.

### What's REMOVED (BREAKING)

The following v2.x skills are removed because v3 process skills cover their roles more rigorously:

**Process skills removed (replaced by Superpowers chain):**
- `feature` — replaced by brainstorming -> writing-plans
- `team-mode` — replaced by subagent-driven-development (real subagent dispatch, not inline perspective simulation)
- `bugfix` — replaced by systematic-debugging
- `fix` — replaced by systematic-debugging
- `refactor` — handled by brainstorming -> writing-plans
- `migration` — handled by brainstorming -> writing-plans
- `review` — replaced by subagent-driven-development's reviewer subagents
- `test-plan` — replaced by test-driven-development
- `handoff` — handled by writing-plans + close
- `session-close` — collapsed into close
- `ingest-session` — collapsed into start
- `memory-lint` — collapsed into close
- `memory-start` — collapsed into start
- `context-pack` — moved to writing-plans as "Context Section" of plan format
- `secure` — generic security guidance, project-specific concerns belong in user's CLAUDE.md
- `ship` — generic deployment, belongs in finishing-a-development-branch

**Domain skills removed (will move to `haye-extras` plugin in a future release):**
nextjs-doctor, prisma-doctor, docker-doctor, coolify-doctor, cloudflare-doctor, database-doctor, auth-audit, secrets-audit, exposed-port-audit, react-nextjs-security, dependency-audit, dependency-security, version-policy, api-integration, ai-agent-system, saas-billing, trading-terminal, video-factory, mobile-app, content-automation, n8n-pipeline, security, project-map, token-audit, deploy

Rationale: Superpowers core contains general-purpose skills only. Domain skills belong in dedicated plugins.

### What's KEPT

These HayeOS-specific skills are retained because they encode value not present in Superpowers:

- **using-hayeos** — master orchestrator (rewritten to route through Superpowers chain)
- **start** — session start, memory vault detection, Turkish welcome
- **init-memory** — canonical project-local vault creation
- **work** — entry router (simplified: routes to brainstorming-as-first-step)
- **checkpoint** — write current state to vault (5+ files modified, risky operation, phase boundary)
- **close** — meaningful work block end, vault update
- **update** — pull plugin updates from GitHub

### What CHANGED

- `bin/haye init` now creates `04-plans/` directory alongside `04-tasks/`.
- All Superpowers-derived skills end with a "HayeOS Layer" section adding Turkish UX rules and memory vault paths.
- `<resolved memoryPath>` placeholder used in skill text is intended for AI runtime substitution from `.hayeos.json` — same as v2.x.
- Plugin description updated to reflect process-first identity.

### Migration from v2.x

For existing projects with `<project>_obs/` vaults from v2.x:
- Vault structure is compatible. `04-plans/` directory will be created on first `bin/haye init` re-run, or you may create it manually.
- Slash commands `/haye:start`, `/haye:work`, `/haye:close`, `/haye:update`, `/haye:version` work unchanged.
- `/haye:fix`, `/haye:secure`, `/haye:ship`, `/haye:bugfix`, `/haye:deploy` are removed. Use `/haye:work` and let routing pick systematic-debugging or finishing-a-development-branch as appropriate.

### Credits

The Superpowers process model is by Jesse Vincent (Obra) and contributors:
https://github.com/obra/superpowers

HayeOS v3 wraps that model with Turkish UX, project-local memory vaults, and HayeOS-specific session management. Substantial portions of `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `test-driven-development`, `verification-before-completion`, `systematic-debugging`, and `finishing-a-development-branch` skill content originates from that project, used with attribution and adapted under MIT.

---

## 2.1.0
- **BREAKING (internal)**: Removed `agents/` directory entirely. Plugin agents (project-manager, security-reviewer, etc.) never worked reliably in Claude Code runtime - Skill() invocation produced "Unknown skill", Task subagent dispatch produced "Invalid tool parameters". User-facing slash commands and vault structure are unchanged.
- Specialist perspectives (10 of them) are now embedded as inline process inside `skills/team-mode/SKILL.md`. Sonnet walks through them sequentially in the main conversation. No tool dispatch, no namespace issues.
- Added **ABSOLUTE FIRST STEP** block to `skills/work/SKILL.md` - work skill MUST produce a Task Classification + mode recommendation + approval question before any sub-skill routing. Prevents the work -> feature drift seen in test6/test7/test8.
- Added **Auto-Invoke Ban** to `skills/feature/SKILL.md` - feature skill cannot be auto-invoked from a user prompt. Only via work skill's Mandatory Routing AFTER mode approval.
- Added **Gate Function** to `skills/using-hayeos/SKILL.md` - mechanical pre-claim check that catches "başarıyla / tamamlandı / oluşturuldu" claims following tool errors.
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
