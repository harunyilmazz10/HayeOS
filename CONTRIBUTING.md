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

## Agent authoring rules

- Include `Inputs to read first`, `What this agent looks for`, `Output format`, and `Safety rules`.
- Make the role specific; avoid generic filler that could apply to any agent.
- State what the agent must not do and when it should escalate.

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
