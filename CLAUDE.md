# HayeOS - Contributing & Behavior

## If You Are an AI Agent

Stop. Read this before doing anything to this repository or to a project that has HayeOS active.

HayeOS is a memory-first workflow plugin for Claude Code. When a session has HayeOS loaded, the SessionStart hook injects `using-hayeos` into your context automatically. You will see `<EXTREMELY_IMPORTANT>You have HayeOS active in this session.` at the start. That message is your behavior contract for the session.

If you are working on the HayeOS plugin repo itself (not a downstream project):

1. **Do not rewrite existing skills cosmetically.** Skill content was tuned against real agent behavior. Reformatting "for style" usually breaks triggering.
2. **Do not add domain-specific skills to core.** If it only makes sense for Coolify/Hetzner/Prisma/n8n stacks, propose it as a separate `haye-extras` plugin.
3. **Every skill change requires triggering test evidence.** See `tests/skill-triggering/` - write a naive prompt that should fire the skill, prove it does, then ship.
4. **Description format is enforced.** All descriptions start with "Use when" / "You MUST use this" / "Use at/after/before" / "Internal". The verify.sh check will reject other shapes.
5. **Skill chaining is explicit.** If skill A is supposed to call skill B, write "**REQUIRED SUB-SKILL:** Use haye:B" in skill A, not "consider using B".

## Skill Philosophy

Skills are not prose. They are behavior code. Each line shapes what Claude does in a real session. Treat them with the discipline you'd treat production code:

- Iron Law sections are non-negotiable. Don't soften them.
- Red Flags tables target specific rationalizations Claude makes. Don't generalize them.
- "Use when X" descriptions activate the skill. Don't reformat to "Helps with X" or skill stops triggering.

## Skill vs Agent Namespace

- `skills/` are invoked with the Skill tool.
- `agents/` are specialist subagents and must be dispatched with the Claude Code agent/subagent mechanism.
- Do not name agent roles as if they were skills.
- A repo change that introduces `Skill(haye:<agent-name>)` or similar is a regression.

## User Response Language

- HayeOS user-facing language is Turkish unless user explicitly switches to English.
- Code, paths, package names, identifiers remain English.
