# Contributing

## Local setup

Clone the repo and verify it locally:

```bash
git clone https://github.com/harunyilmazz10/HayeOS.git
cd HayeOS
bash scripts/verify.sh
```

Expected: `verification OK` and exit code 0.

For a basic CLI sanity test, create a temporary project and run `python3 bin/haye init`. The generated config must use `./<project-name>_obs` and must not create root-level memory folders.

## Skill authoring rules

- Use proper YAML frontmatter with `name` and `description`.
- Skill content stays English; user-facing replies are Turkish (per HayeOS Layer).
- Include the User Response Language Rule for any skill that produces user-facing output.
- Keep chat concise; put deeper technical artifacts in docs or vault files.
- Use `<resolved memoryPath>/...` for memory targets; resolve at runtime from `.hayeos.json`.
- Never write memory files to project root or plugin root.

## Adding a new skill

1. Use `Skill(haye:writing-skills)` to author it - that skill applies TDD to skill documentation.
2. Write a pressure test in `tests/skill-triggering/prompts/<skill-name>.txt`.
3. Run the test against a baseline (no skill loaded) and confirm it fails the way the skill is meant to fix.
4. Write the SKILL.md.
5. Re-run the test with the skill loaded; confirm it passes.
6. Add the skill to `scripts/verify.sh` `check_required_skills_present` list.
7. Add the skill to `using-hayeos` Mandatory Invocation Triggers if relevant.

## Removed v2.x concepts

- Do not restore the `agents/` directory; plugin agents never worked reliably in Claude Code runtime.
- Do not restore `feature` or `team-mode` skills; brainstorming -> writing-plans -> subagent-driven-development replaces them.
- Do not restore domain-specific skills (nextjs-doctor, prisma-doctor, coolify-doctor, etc.); those belong in `haye-extras`.

## Pre-PR verification checklist

```bash
bash scripts/verify.sh
python3 bin/haye --help
python3 bin/haye init  # in a temp directory
```

All must succeed.

## Hard requirements for every PR

- `verification OK` must appear in a successful verify run.
- No personal hardcoded values (names, paths, emails).
- No wrapper regressions for Windows (`bin/haye.cmd`, `hooks/run-hook.cmd`).
- No path-safety regressions (init fail-fast when inside plugin root).
- New skills include a triggering test prompt in `tests/skill-triggering/prompts/`.

## Style

- Markdown only, no smart quotes (use ASCII `'` and `"`).
- Use ASCII arrows (`->`) not Unicode (`→`) in code blocks and tables.
- Code blocks fenced with triple backticks and a language hint when possible.
