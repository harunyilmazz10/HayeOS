# HayeOS / Haye Claude Code Plugin

**Haye** is an Obsidian-powered, memory-first operating system for Claude Code. It is built for long-running Haye Labs projects: AI agents, SaaS panels, Next.js/Coolify deployments, n8n automations, video factories, trading terminals, mobile apps and content automation.

## Why it exists

Claude Code sessions can become expensive and unstable when old conversations, full repositories, raw logs and huge context are repeatedly loaded. Haye fixes this with:

- Obsidian project memory
- minimal context starts
- task-specific context packs
- session close handoffs
- dependency security and safe version policy
- React / Next.js / Cloudflare advisory rules
- smart daily commands
- advanced expert workflows when needed

## Simple daily commands

Use these first. They are smart routers over the advanced HayeOS workflows.

```text
/haye:start   # start from Obsidian memory with minimal context
/haye:work    # feature/refactor/API/migration/test work
/haye:fix     # debugging and root-cause-first fixes
/haye:secure  # security, dependency and safe version checks
/haye:ship    # deploy/release readiness
/haye:close   # update Obsidian memory and close the session
/haye:update  # update the installed HayeOS plugin safely
```

### /haye:work Smart Modes

`/haye:work "görev"` Smart Work Router olarak çalışır. Görevi `task_size`, `task_type`, `risk_level`, `affected_layers` ve `recommended_mode` alanlarıyla sınıflandırır.

Modes:
- Fast Single Agent: small + low risk işler için kısa planla direkt uygular.
- Standard Single Agent: medium işler için plan + implementation + verification yapar.
- Plan First: önce sadece plan çıkarır, kod yazmadan onay bekler.
- Team Mode: large veya high risk işlerde uzman rollere böler; ayrı user-facing team komutu yoktur.
- Full Architecture Mode: massive veya sıfırdan production-grade sistemlerde kodlamadan önce mimari plan çıkarır ve onay ister.

Work Strategy Selection Rule: large, massive, high-risk veya belirsiz işlerde HayeOS önce önerilen çalışma modunu açıklar ve Türkçe onay ister; small + low-risk işlerde sormadan Fast Single Agent ile ilerler.

Original Prompt Preservation Rule: large, massive, architecture ve full-system `/haye:work` isteklerinde HayeOS orijinal kullanıcı promptunu özetlemeden `<resolved memoryPath>/01-prompts/` altına kaydeder. İlk master prompt `<resolved memoryPath>/01-prompts/initial-master-prompt.md`, sonraki work promptları `<resolved memoryPath>/01-prompts/work-request-YYYY-MM-DD-HHMM.md` olur.

HayeOS minimizes approval friction. It asks for approval at phase boundaries and risk gates, not after every small edit.

No Fake Completion Rule: HayeOS doğrulama çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready" veya "başarılı" demez. Build/test/lint/typecheck çalışmadıysa bunu açıkça yazar.

Output Budget Rule: large outputs go to files. HayeOS büyük mimari, roadmap, servis planı, DB planı, event/queue schema ve deployment planı gibi uzun çıktıları chat'e basmak yerine `docs/` veya HayeOS vault dosyalarına yazar; chat'te kısa özet, dosyalar, kararlar, doğrulama durumu ve sıradaki 3 adım kalır. Bu kural 64000 output token hatasına yol açabilecek büyük chat çıktılarının önüne geçer.

Quality Preservation Rule: token discipline must never reduce implementation quality. HayeOS token tasarrufunu uzun chat, tekrar, gereksiz repo taraması ve dev logları azaltarak yapar; gerekli kod okuma, test, validation, security check, error handling ve mimari akıl yürütmeden ödün vermez. Doğruluk hızdan ve token tasarrufundan önce gelir.

Auto Checkpoint Rule: HayeOS uzun veya riskli işlerde `/haye:close` beklemeden `<resolved memoryPath>/05-sessions/latest-checkpoint.md`, `<resolved memoryPath>/04-tasks/active-task.md`, `<resolved memoryPath>/current.md` ve `<resolved memoryPath>/next.md` dosyalarını günceller. Claude Code API 400, output limit veya bağlantı hatasıyla kapanırsa yeni oturumda `/haye:start` latest checkpoint'i okur, kısa recovery özeti verir ve kullanıcı onayı olmadan kodlamaya devam etmez.

Plugin root and project memory vault are different. `CLAUDE_PLUGIN_ROOT` or the HayeOS install path is only the plugin code root. All project memory is stored under the current project's `.hayeos.json` `memoryPath`; HayeOS must not write context packs, checkpoints, `<resolved memoryPath>/current.md`, `<resolved memoryPath>/next.md` or `<resolved memoryPath>/changelog.md` into the plugin repository.

`/haye:update` updates the installed HayeOS plugin repo from GitHub. It stops when local changes exist, does not commit or push, validates the plugin after updating, and recommends restarting Claude Code.

Recommended daily flow:

```text
/haye:start
/haye:work "Add the package billing screen"
/haye:secure
/haye:ship
/haye:close
/haye:update
```

## Internal Skills / Routed Workflows

These are internal skills and routed workflows, not user-facing slash commands. HayeOS invokes them through the daily commands such as `/haye:work`, `/haye:secure`, `/haye:ship`, `/haye:start` and `/haye:close` when needed.

```text
memory-start
context-pack
session-close
dependency-security
react-nextjs-security
cloudflare-doctor
coolify-doctor
bugfix
deploy
memory-lint
token-audit
```

## Install locally

```bash
git clone https://github.com/harunyilmazz10/hayeos.git
cd hayeos
claude --plugin-dir .
```

## Permanent Install

Use this when you want the Haye commands to appear in normal `claude` sessions without passing `--plugin-dir` every time.

```text
claude
/plugin marketplace add <hayeos-plugin-root>
/plugin install haye@haye-marketplace
```

After install, new Claude Code sessions should expose:

```text
/haye:start
/haye:work
/haye:fix
/haye:secure
/haye:ship
/haye:close
```

For one-off development testing, keep using:

```bash
claude --plugin-dir <hayeos-plugin-root>
```

## Memory Setup

After Haye is installed permanently, users normally do not need to run `bin/haye` manually. In any project, start with:

```text
/haye:start
```

If the project does not have `.hayeos.json` or an Obsidian vault yet, `/haye:start` asks in Turkish:

```text
Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?
```

`/haye:start` is intentionally light: it does not use subagents, does not enter plan mode, does not scan the whole repository and does not create `.hayeos.json` until you approve. When you approve, Haye creates `.hayeos.json` and the `<project-name>_obs` vault, then performs only the lightweight memory-start read. You can also run the setup directly:

```text
/haye:init-memory
```

Manual CLI use is only a fallback. On Windows, use one of these instead of trying to run the Python script through bash:

```text
C:\Path\To\HayeOS\bin\haye.cmd init
powershell -ExecutionPolicy Bypass -File C:\Path\To\HayeOS\bin\haye.ps1 init
```

## Project setup

At the root of your project, create or let Haye create `.hayeos.json`:

```json
{
  "project": "<project-name>",
  "memoryPath": "./<project-name>_obs",
  "sourcePath": ".",
  "defaultWorkflow": "memory-first",
  "sessionCloseRequired": true
}
```

Then run:

```text
/haye:init-memory
/haye:start
```

## Dependency security and safe versions

Haye never blindly uses `latest`. When dependencies are added or changed it checks:

- `package.json`
- lockfiles
- audit output
- official advisories and changelogs when internet is available
- embedded Haye security rules
- Obsidian safe dependency decisions

If internet/advisory access is unavailable, Haye must clearly say that live advisory verification was not performed.

### React / Next.js / Cloudflare rule

For React Server Components, Next.js App Router, middleware/proxy, server actions, image optimization and cache components, Haye uses the internal `react-nextjs-security` skill or routes through `/haye:secure`.

Known embedded baseline from the May 2026 React/Next.js advisory set:

- Avoid React RSC packages `19.0.0-19.0.5`, `19.1.0-19.1.6`, `19.2.0-19.2.5`
- Prefer patched RSC packages `19.0.6`, `19.1.7`, `19.2.6` or later compatible patch
- Next.js 15.x baseline: `15.5.16+`
- Next.js 16.x baseline: `16.2.5+`
- Cloudflare WAF is defense-in-depth, not a replacement for patching dependencies

## CLI

```bash
./bin/haye --help
./bin/haye init
./bin/haye find-vault
./bin/haye health
./bin/haye lint
./bin/haye react-nextjs-audit
./bin/haye deps-audit
```

## Haye vs normal CLAUDE.md

`CLAUDE.md` gives instructions. Haye adds a full operating model: Obsidian memory, context packs, session handoff, CLI checks, security workflows and project recipes.

## Haye vs Superpowers

Superpowers focuses on software engineering discipline. Haye focuses on project memory, token economy, dependency/security policy, Haye-specific ops and long-running project continuity. They can be used together: start with Haye memory, use engineering workflows when needed, close with Haye memory updates.
