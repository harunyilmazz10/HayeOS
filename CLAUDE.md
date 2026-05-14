# HayeOS - Contributor & Agent Guidelines

## If You Are an AI Agent

Stop. Read this before doing anything to this repository or to a project that has HayeOS active.

HayeOS v3.0.0 is a memory-first, discipline-first workflow plugin for Claude Code, built on the Superpowers process model. When a session has HayeOS loaded, the SessionStart hook injects `using-hayeos` into your context automatically. You will see `<EXTREMELY_IMPORTANT>You have HayeOS active in this session.` at the start. That message is your behavior contract for the session.

## Working on a Downstream Project (Most Common Case)

Follow the skill chain:

1. New feature, system, or non-trivial change -> `Skill(haye:brainstorming)` (HARD-GATE before any code)
2. Approved spec -> `Skill(haye:writing-plans)` (bite-sized tasks with exact paths)
3. Ready plan -> `Skill(haye:subagent-driven-development)` (implementer + spec reviewer + code quality reviewer per task)
4. Bug report -> `Skill(haye:systematic-debugging)`
5. Implementation complete -> `Skill(haye:finishing-a-development-branch)`

Always invoke `Skill(haye:verification-before-completion)` before claiming any work is done.

## Working on the HayeOS Plugin Itself (Rarer)

If you are modifying the HayeOS plugin repo (not a downstream project):

1. **Do not rewrite existing skills cosmetically.** Skill content is tuned against real agent behavior. Reformatting for style usually breaks triggering.

2. **Do not add domain-specific skills to core.** If it only makes sense for Coolify/Hetzner/Prisma/n8n/Next.js stacks, propose it as a separate `haye-extras` plugin. Domain skills were removed in v3.0.0 for exactly this reason.

3. **Every skill change requires triggering test evidence.** See `tests/skill-triggering/` - write a naive prompt that should fire the skill, prove it does, then ship.

4. **Description format is enforced.** All descriptions start with "Use when" / "You MUST use this" / "Use at/after/before" / "Internal". The verify.sh check rejects other shapes.

5. **Skill chaining is explicit.** If skill A is supposed to call skill B, write "**REQUIRED SUB-SKILL:** Use haye:B" in skill A, not "consider using B".

6. **Use the `writing-skills` skill.** That skill is TDD applied to skill authoring: write a pressure test, watch baseline fail, write the skill, watch the test pass, refactor.

## Skill Philosophy

Skills are not prose. They are behavior code. Each line shapes what Claude does in a real session. Treat them with the discipline of production code:

- Iron Law sections are non-negotiable. Don't soften them.
- Red Flags tables target specific rationalizations. Don't generalize them.
- "Use when X" descriptions activate the skill. Don't reformat to "Helps with X" or the skill stops triggering.

## Subagent-Driven Discipline

HayeOS v3 inherits the Superpowers insight: **one Sonnet self-policing against written rules has a ceiling**. Sonnet 4.6 will quote the Iron Law verbatim and then violate it.

v3 replaces self-policing with **mechanical three-way agreement**:
- Implementer subagent does the task in fresh context
- Spec reviewer subagent confirms code matches plan
- Code quality reviewer subagent confirms quality

The orchestrating Sonnet cannot unilaterally declare success. All three dispatches must approve.

If you are tempted to bypass this chain ("just implement it, it's simple"), you are rationalizing. The chain is the discipline.

## Removed v2.x Concepts

These do not exist in v3 - if you see them, fix them:

- `agents/` directory (plugin agents never worked in Claude Code runtime - removed in v2.1.0)
- `Skill(haye:project-manager)` and other specialist role dispatches (now inline perspectives are gone; subagents are dispatched via Task tool with prompts from `skills/subagent-driven-development/`)
- `feature` skill (replaced by brainstorming -> writing-plans)
- `team-mode` skill (replaced by subagent-driven-development)
- `bugfix`, `fix`, `secure`, `ship`, `refactor`, `migration`, `review`, `test-plan`, `handoff`, `session-close`, `ingest-session`, `memory-lint`, `memory-start`, `context-pack`, `deploy` skills (collapsed into Superpowers process skills)
- All 25 domain skills (nextjs-doctor, prisma-doctor, coolify-doctor, etc. - belong in `haye-extras`)

## User Response Language

- HayeOS user-facing language is Turkish unless user explicitly switches to English.
- Code, paths, package names, identifiers remain English.
- Skill content is written in English. You translate only your reply to the user, not the skill itself.
