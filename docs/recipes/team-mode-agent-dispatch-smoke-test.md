# Team Mode Inline Perspective Smoke Test

Use this on a real Claude Code session with HayeOS enabled after installing v2.1.0 or later.

## Goal

Confirm that Team Mode walks specialist roles as inline perspectives, not as HayeOS skills, plugin agents, or subagents.

## Steps

1. Start Claude Code with HayeOS enabled.
2. Enter a natural-language complex project request:

```text
Next.js ile premium bir doktor landing page projesi oluşturmak istiyorum. Tam çalışan, production-grade yapı kur.
```

3. Confirm `Skill(haye:work)` loads.
4. Confirm Team Mode is offered.
5. Choose:

```text
1. Önerilen modla devam et
```

6. Confirm `Skill(haye:team-mode)` loads.
7. Confirm specialist roles such as `project-manager`, `security-reviewer`, and `token-economist` appear as inline perspective sections.
8. Confirm no `Unknown skill` or `Invalid tool parameters` errors appear for specialist names.

## Expected result

- Skills orchestrate the workflow.
- Inline perspectives provide specialist findings.
- No specialist role is called through `Skill(haye:<role-name>)`.
- Team Mode does not claim specialist perspectives were applied unless the perspective sections contain task-specific findings.
