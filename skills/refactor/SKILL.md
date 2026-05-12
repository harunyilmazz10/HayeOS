---
name: refactor
description: Use when changing code structure without changing behavior - bounded scope, tested before/after, rollback plan
---

# Haye Skill: refactor

## Purpose
Change shape without changing behavior. The hard part isn't writing new code; it's proving the old behavior survived.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. The file(s) the user named, plus everything that imports/calls them.
2. Existing tests covering the area — if none, this is the first task.
3. The motivation: readability, performance, correctness, deprecation? Each leads to a different shape.
4. `<resolved memoryPath>/02-decisions/` — any decisions that constrain the refactor?

## Token discipline
- Do not refactor a 10-file area in one pass; pick the smallest unit and ship.
- Do not paste the whole before/after into chat; the diff or a description is enough.

## Workflow

### Step 1 — Define what behavior must be preserved
- List the contract: public methods/exports, side effects, error shape, performance bounds.
- Anything not on the list is fair game; anything on the list must survive verification.

### Step 2 — Ensure tests exist that cover the contract
- If tests exist: identify which ones cover which contract item. Gap → add tests FIRST.
- If no tests: add a minimal characterization test that captures current behavior (golden output, snapshot, or assertion of a known sequence).
- This step is non-negotiable. A refactor without behavior tests is hope, not engineering.

### Step 3 — Plan the change in small commits
- Commit 1: extract / rename without changing behavior; tests still green.
- Commit 2: introduce new shape alongside old; tests green.
- Commit 3: switch callers one at a time; tests green at each.
- Commit 4: remove old shape; tests green.
- Squash at the end if the user prefers; the small-step history is for your safety.

### Step 4 — Execute
- After each commit: run tests, typecheck, lint.
- If a step turns red, revert that step alone; don't pile changes on top.

### Step 5 — Performance regression check (if applicable)
- If the refactor touches a hot path, measure before and after with the same benchmark.
- Smaller code is not faster code by default.

### Step 6 — Memory update
- `<resolved memoryPath>/02-decisions/refactor-<scope>.md`: what changed, why, what stayed the same.
- If the refactor reveals architectural friction, add to `<resolved memoryPath>/12-risks/` for future planning.

## Anti-patterns to refuse
- "Refactor while you're at it" added to a feature task → no; two changes, two reviews.
- Rewriting working code "because it's ugly" without a measurable benefit → reject or postpone.
- Replacing a function with a library — that's a dependency change, gated separately.
- Renaming public API without a deprecation path → external callers break.
- Changing types in TypeScript to make errors go away without understanding why they were errors → no.

## Output format
```markdown
## Scope
- files in:
- files out (callers updated):

## Contract preserved
- public surface:
- side effects:
- error shape:

## Plan
1. (step) tests green: yes
2. (step) tests green: yes
3. ...

## Verification
- tests:
- typecheck:
- lint:
- perf (if relevant):

## Risks
- list:

## Rollback
- revert: <commit range>

## Memory update
- <resolved memoryPath>/02-decisions/refactor-<scope>.md
```

## Safety rules
- Don't refactor without tests. Add them first.
- Don't combine refactor and feature in the same commit.
- Don't ship a refactor that you haven't verified end-to-end (build, test, smoke).
- Don't auto-format the entire repo as part of a "refactor"; format changes are noise that hides intent.
- Long refactor plans go to `docs/refactors/<scope>.md`; chat gets the summary.
