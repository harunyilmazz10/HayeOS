# Philosophy

HayeOS v3.0.0 is built on three principles, in priority order.

## 1. Memory-first

Preserve what matters across sessions. The project-local memory vault (`<project>_obs/`) is the unit of continuity:

- Original prompts preserved in `01-prompts/` (no summarization before persistence)
- Decisions captured in `02-decisions/` (specs from brainstorming, architectural choices)
- Plans persisted in `04-plans/` (implementation plans from writing-plans)
- Reviews logged in `10-reviews/` (subagent reviewer outputs)
- Session state in `05-sessions/latest-checkpoint.md`

Future sessions resume cleanly because state lives outside Claude's context window.

## 2. Discipline-first via mechanical agreement

Earlier HayeOS versions tried to enforce discipline through written rules: longer Iron Law, sharper Red Flags, more Mandatory Triggers. Real testing showed Sonnet 4.6 hits a ceiling: it can quote the Iron Law verbatim and immediately violate it.

v3.0.0 replaces self-policing with **mechanical three-way agreement** via the Superpowers `subagent-driven-development` chain:

- **Implementer** subagent does the task in fresh context
- **Spec reviewer** subagent confirms code matches plan
- **Code quality reviewer** subagent confirms quality

The orchestrating Sonnet cannot unilaterally claim "başarıyla tamamlandı". All three dispatches must approve. This is structural - not a rule to be remembered, but a procedure to be followed.

## 3. Verify before claiming

Every claim of completion requires fresh evidence in the same turn:

- "Build passes" -> requires `npm run build` exit code 0 in the most recent action
- "Tests pass" -> requires test command output with zero failures
- "Bug fixed" -> requires the original symptom verified absent
- "Production-ready" -> requires the full checklist of build/test/lint/typecheck/manual smoke

The Iron Law line "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" is enforced by the Gate Function in `verification-before-completion` skill - a mechanical pre-claim check, not an aspirational guideline.

## Why these three together

Memory without discipline produces a tidy vault full of placeholders and lies. Discipline without memory produces work that disappears between sessions. Verification without either produces empty correctness claims about no real work.

HayeOS v3 stacks the three so each load-bearing rule has structural support:
- Memory vault preserves the spec and plan that discipline references
- Subagent dispatch enforces the discipline that verification protects
- Verification gates the claims that memory then records as fact
