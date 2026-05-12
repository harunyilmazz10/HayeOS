---
name: test-plan
description: Use when designing tests for a change - what to test, how, what NOT to test, regression detection
---

# Haye Skill: test-plan

## Purpose
Decide what tests are worth writing before writing code. Not "100% coverage" but "every behavior that matters and would silently break without a test".

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa plan Türkçe verilir.

## Inputs to inspect first
1. The change being planned (a feature, a refactor, a bug fix).
2. Existing test layout: unit (Jest, Vitest, Pytest), integration, E2E (Playwright, Cypress).
3. The CI config — what already runs?
4. Coverage gaps in the area being changed.

## Token discipline
- Don't read every existing test; read the ones in the same module to match style.
- Don't propose 50 tests; propose the 5 that matter most.

## Workflow

### Step 1 — Map behaviors to test
For the change, list user-visible behaviors and internal invariants. Each one is a candidate test target.

### Step 2 — Categorize each candidate
- **Critical**: silent failure would damage data, money, or trust. MUST be tested.
- **Important**: silent failure would degrade UX but is recoverable. SHOULD be tested.
- **Cosmetic**: silent failure is noticeable and trivially fixable. SKIP automated tests; rely on smoke.

### Step 3 — Pick the right level
- **Unit**: pure functions, one piece of logic, deterministic.
- **Integration**: API endpoint with DB, multi-module flow.
- **E2E**: critical user paths only (signup, checkout, the main feature).
- E2E is expensive; reserve for paths that would close the company if broken.

### Step 4 — Write the testability requirements
- Inputs that can vary; outputs that can be asserted.
- Side effects that need a mock vs real boundary.
- Test data: factory or fixture? Fresh per test or shared?
- Test DB: per-test transaction roll-back, or migrated-and-truncated?

### Step 5 — Identify what NOT to test
- Framework behavior (React renders props; Prisma serializes JSON) — already tested by the framework.
- Trivial getters/setters.
- Snapshot tests on the entire UI — they catch noise, not regressions; use them surgically.
- Implementation details (private methods) — test the public surface.

### Step 6 — Regression test for known bug area
- If a bug was fixed once in this area, the test that protects it must exist. If it doesn't, add it as part of this plan.

### Step 7 — CI signal
- New tests run in CI by default.
- Flaky tests are not allowed; quarantine and fix.
- Test names describe behavior, not implementation (`it("returns 401 when token is missing")`, not `it("calls getSession")`).

## Anti-patterns to refuse
- "Aim for X% coverage" as a goal — coverage isn't a quality metric on its own
- Mocking what you're testing
- Testing a single method by mocking every dependency — that's a unit test of the mocks, not the code
- Tests that hit a real third-party API in CI
- "We'll add tests later" — later doesn't happen
- Asserting on log output as the main check

## Output format
```markdown
## Behaviors and invariants
- (behavior) — category: critical/important/cosmetic — level: unit/integration/e2e

## Tests to write (prioritized)
1. (name) — what it asserts — file location
2. ...

## Tests NOT to write (and why)
- ...

## Test data strategy
- factories vs fixtures:
- DB setup:
- mocks:

## Regression coverage
- existing tests covering this area:
- gaps to fill:

## CI
- where it runs:
- expected runtime:
```

## Safety rules
- Don't ship a critical-category change without at least one test in that category.
- Don't push flaky tests; quarantine or fix.
- Don't test against live paid APIs in CI; use sandboxes.
- Don't propose deleting "all integration tests" to speed up CI — find the slow one.
- Long test specs go to `docs/testing.md`; chat gets the prioritized list.
