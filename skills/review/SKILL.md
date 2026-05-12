---
name: review
description: Review a diff, a plan, or a design with structure - correctness, security, maintainability, scope discipline.
---

# Haye Skill: review

## Purpose
Review someone else's work (or your own from yesterday) with structure. Output is actionable feedback ordered by priority, not a wall of nits.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa geri bildirim Türkçe verilir.

## Inputs to inspect first
1. The diff (`git diff`, PR link, or pasted patch) — read it twice.
2. The stated goal: feature, fix, refactor, infra? Different priorities apply.
3. Related files not in the diff (callers of changed functions, tests).
4. `<resolved memoryPath>/02-decisions/` for constraints that the change should respect.

## Token discipline
- Read the full diff; don't skim.
- For large diffs, ask which file is the main change and review that file deeply, others by scan.

## Workflow

### Step 1 — Restate the goal
- What is this PR/change supposed to do? If you can't say it in one sentence, the PR is too big.

### Step 2 — Read for correctness
- Does it do what it says?
- Edge cases: null/empty/zero, very large, concurrent calls, second-time-running.
- Error paths: are they handled, or silently swallowed?
- For each `try/except` or `try/catch`: is the catch specific, or did we just hide a bug?

### Step 3 — Read for security
- Does this expand the attack surface? New endpoint, new input, new dependency.
- Auth/authorization check on every new mutation endpoint.
- Input validated before reaching the database / external API.
- No secret in code, logs, or response.

### Step 4 — Read for maintainability
- Is this code findable in 3 months? Names, file location, comments-on-why.
- Public API additions: are they minimal? Removing later is hard.
- Duplication: did we add a third copy of a thing that should be a function?
- Tests: critical paths covered? Test names readable?

### Step 5 — Scope discipline
- Anything in this diff that doesn't serve the stated goal? Flag it; it belongs in a separate change.
- Drive-by formatting / refactors mixed with feature work → reject and split.
- New dependency for the change? Justified or accidental?

### Step 6 — Output the review
- Priority-ordered feedback. Not file-by-file (the diff already is).
- Each item: `(severity) (file:line) — what's wrong — what to do`.

## Severity ladder
- **block**: correctness, security, data loss. Must fix before merge.
- **strong**: maintainability or robustness issue that will hurt within weeks.
- **suggestion**: better way to express; reviewer would prefer it; not blocking.
- **nit**: typo, style. Optional unless it's a class of issue.

## Anti-patterns to refuse (in reviewing)
- Drive-by rewrites in review comments — leave the substantive code as a suggestion, not a rewrite.
- Style debates without a style guide — point to the guide, or accept the variation.
- "I would have built it differently" without a concrete reason — let it ship.
- Approving without reading the tests.
- Refusing to approve because "you should also do X" when X was explicitly out of scope.

## Output format
```markdown
## Stated goal (one sentence)

## Overall verdict
- approve / approve with comments / request changes / block

## Block (must fix)
- (file:line) — issue — required change

## Strong (please address)
- (file:line) — issue — recommended change

## Suggestion
- (file:line) — alternative

## Out of scope (do not block on this here)
- ...

## Tests
- coverage on changed lines: present / partial / absent
- new tests reviewed: yes/no

## Scope discipline
- in-scope changes: yes/no
- mixed-purpose commits: list
```

## Safety rules
- Don't approve a security-impacting change without security review (or run `security-reviewer` agent first).
- Don't approve a destructive migration without a tested rollback.
- Don't sign off on "no tests" for critical changes.
- Don't accept "we'll fix it later" for `block`-level issues.
- Long review write-ups go to PR comments or `<resolved memoryPath>/10-reviews/`; chat gets the verdict.
