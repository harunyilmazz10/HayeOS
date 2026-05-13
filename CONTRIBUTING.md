# Contributing

## Local setup

Clone the repo, install it as a local Claude Code plugin when needed, then test from the repository root:

```bash
git clone https://github.com/harunyilmazz10/HayeOS.git
cd HayeOS
bash scripts/verify.sh
```

For a basic CLI sanity test, create a temporary project and run `python3 bin/haye init` or `python bin/haye init`. The generated config must use `./<project-name>_obs` and must not create root-level memory folders.

## Skill authoring rules

- Use proper YAML frontmatter with `name` and `description`.
- Include the User Response Language Rule for user-facing skills.
- Keep chat concise; put deeper technical artifacts in docs or vault files.
- Use `<resolved memoryPath>/...` for memory targets.
- Never write memory files to project root or plugin root.

## Team Mode perspective rules

- Do not add or restore a plugin `agents/` directory.
- Put Team Mode specialist behavior inside `skills/team-mode/SKILL.md`.
- Each perspective must include what it looks for and a concrete output shape.
- Keep each perspective role-specific; avoid generic filler that could apply to any workflow.
- Do not introduce Task-tool or subagent dispatch for Team Mode unless a future runtime proves it works reliably.

## Pre-PR verification checklist

Run:

```bash
bash scripts/verify.sh
```

Also smoke-test CLI changes with `python3 bin/haye --help || python bin/haye --help`.

## Hard requirements for every PR

- Skill bodies stay duplicate-free and operational.
- `verification OK` must appear in a successful verify run.
- No personal hardcode such as `Harun`.
- No broken wrapper regressions.
- No path-safety, init fail-fast, or plugin-root leakage regressions.
