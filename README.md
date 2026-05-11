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
```

### /haye:work Smart Modes

`/haye:work "görev"` Smart Work Router olarak çalışır. Görevi `task_size`, `task_type`, `risk_level`, `affected_layers` ve `recommended_mode` alanlarıyla sınıflandırır.

Modes:
- Fast Mode: small + low risk işler için kısa planla direkt uygular.
- Standard Mode: medium işler için plan + implementation + verification yapar.
- Team Mode: large veya high risk işlerde uzman rollere böler; ayrı `/haye:team` komutu yoktur.
- Full Architecture Mode: massive veya sıfırdan production-grade sistemlerde kodlamadan önce mimari plan çıkarır ve onay ister.

HayeOS minimizes approval friction. It asks for approval at phase boundaries and risk gates, not after every small edit.

No Fake Completion Rule: HayeOS doğrulama çıktısı olmadan "çalışıyor", "tamamlandı", "geçti", "production-ready" veya "başarılı" demez. Build/test/lint/typecheck çalışmadıysa bunu açıkça yazar.

Recommended daily flow:

```text
/haye:start
/haye:work "Add the package billing screen"
/haye:secure
/haye:ship
/haye:close
```

## Advanced commands

The detailed skills remain available for direct use:

```text
/haye:memory-start
/haye:context-pack
/haye:session-close
/haye:dependency-security
/haye:react-nextjs-security
/haye:cloudflare-doctor
/haye:coolify-doctor
/haye:bugfix
/haye:deploy
/haye:memory-lint
/haye:token-audit
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
/plugin marketplace add /Users/haye/Desktop/HayeeOS
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
claude --plugin-dir /Users/haye/Desktop/HayeeOS
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

When you approve, Haye automatically creates `.hayeos.json` and the `<project-name>_obs` vault, then continues with memory-start. You can also run the setup directly:

```text
/haye:init-memory
```

Manual CLI use is only a fallback. On Windows, use one of these instead of trying to run the Python script through bash:

```text
C:\Users\hayed\Desktop\HayeOS\bin\haye.cmd init
powershell -ExecutionPolicy Bypass -File C:\Users\hayed\Desktop\HayeOS\bin\haye.ps1 init
```

## Project setup

At the root of your project, create or let Haye create `.hayeos.json`:

```json
{
  "project": "Arb21",
  "memoryPath": "./Arb21_obs",
  "sourcePath": ".",
  "stack": ["Next.js", "TypeScript", "Postgres", "Prisma", "Coolify", "Cloudflare"],
  "riskLevel": "high",
  "defaultWorkflow": "memory-first",
  "sessionCloseRequired": true,
  "rawReadPolicy": "explicit-only"
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

For React Server Components, Next.js App Router, middleware/proxy, server actions, image optimization and cache components, Haye runs `/haye:react-nextjs-security` or routes through `/haye:secure`.

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
