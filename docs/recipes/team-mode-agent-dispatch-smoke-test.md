# Team Mode Agent Dispatch Smoke Test

Use this on a real Claude Code session with HayeOS enabled after installing v2.0.1 or later.

## Goal

Confirm that Team Mode dispatches specialist roles as agents/subagents, not as HayeOS skills.

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
7. Confirm specialist roles such as `project-manager`, `security-reviewer`, and `token-economist` are dispatched as agents/subagents.
8. Confirm no `Unknown skill` errors appear for specialist names.

## Expected result

- Skills orchestrate the workflow.
- Agents provide specialist findings.
- No agent role is called through `Skill(haye:<agent-name>)`.
- Team Mode does not claim specialist perspectives were applied unless agent outputs actually exist.
