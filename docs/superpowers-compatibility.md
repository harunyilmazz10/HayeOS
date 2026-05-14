# Superpowers Compatibility

HayeOS v3.0.0 is built on the Superpowers process model. This document clarifies the relationship.

## What HayeOS is to Superpowers

HayeOS v3 takes the 13 core process skills from Jesse Vincent's Superpowers plugin (https://github.com/obra/superpowers) and wraps them with three HayeOS-specific concerns:

1. **Memory vault** — Plans, specs, reviews, sessions all persist in a project-local `<project>_obs/` vault
2. **Turkish UX** — Default user-facing language is Turkish; skill content stays English
3. **Path Separation** — Source code goes to `sourcePath`, memory artifacts go to `memoryPath`, with skill-level enforcement

Each Superpowers-derived skill in HayeOS ends with a "HayeOS Layer" section adding these concerns.

## Skill mapping

| Superpowers skill | HayeOS v3 skill | Status |
|---|---|---|
| `brainstorming` | `haye:brainstorming` | Adapted, with HayeOS Layer |
| `writing-plans` | `haye:writing-plans` | Adapted, with HayeOS Layer |
| `executing-plans` | `haye:executing-plans` | Adapted, with HayeOS Layer |
| `subagent-driven-development` | `haye:subagent-driven-development` | Adapted, with HayeOS Layer |
| `dispatching-parallel-agents` | `haye:dispatching-parallel-agents` | Adapted, with HayeOS Layer |
| `test-driven-development` | `haye:test-driven-development` | Adapted, with HayeOS Layer |
| `verification-before-completion` | `haye:verification-before-completion` | Adapted, with HayeOS Layer |
| `systematic-debugging` | `haye:systematic-debugging` | Adapted, with HayeOS Layer |
| `requesting-code-review` | `haye:requesting-code-review` | Adapted, with HayeOS Layer |
| `receiving-code-review` | `haye:receiving-code-review` | Adapted, with HayeOS Layer |
| `using-git-worktrees` | `haye:using-git-worktrees` | Adapted, with HayeOS Layer |
| `finishing-a-development-branch` | `haye:finishing-a-development-branch` | Adapted, with HayeOS Layer |
| `writing-skills` | `haye:writing-skills` | Adapted, with HayeOS Layer |
| `using-superpowers` | `haye:using-hayeos` | Rewritten as HayeOS master orchestrator |

## Running both plugins together

Both plugins can be installed simultaneously. If they are:

- `Skill(superpowers:brainstorming)` and `Skill(haye:brainstorming)` both work independently
- Skill triggering will fire whichever is most relevant (usually `haye:` because it includes Turkish UX and memory vault directives)
- Conflicts: if you write a HayeOS spec and a Superpowers plan, the spec goes to `<memoryPath>/02-decisions/` and the plan goes to `docs/superpowers/plans/` — different locations, no conflict, but you may want to consolidate

For most users, picking one is cleaner. HayeOS is recommended when:
- You want Turkish UX
- You want project-local memory persistence across sessions
- You want `/haye:start`, `/haye:close` lifecycle commands

Pure Superpowers is recommended when:
- You don't need memory vault or Turkish UX
- You want the latest Superpowers updates immediately (HayeOS may lag)

## Attribution

Substantial portions of `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`, `test-driven-development`, `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `finishing-a-development-branch`, and `writing-skills` skill content originates from Superpowers, used under MIT license with attribution maintained in skill files, README.md, and CHANGELOG.md.
