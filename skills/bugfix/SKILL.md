---
name: bugfix
description: Reproduce, hypothesize, narrow, fix at root and add a regression test. The skill version of the bug-investigator agent.
---

# Haye Skill: bugfix

## Purpose
Fix a bug correctly with the smallest safe change, leaving a regression test and a memory entry behind. Mirrors the `bug-investigator` agent for use outside Team Mode.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. The user's symptom description verbatim — read it twice.
2. Stack trace or error message: first 10 lines + last 30 lines (skip the middle).
3. `<resolved memoryPath>/03-bugs/recurring/` — has this been seen?
4. The single file mentioned in the trace, plus its direct callers.
5. The most recent git diff that could have introduced it (`git log --oneline -10`, then check the suspect commit).

## Token discipline
- Do not read the whole repo. Start at the failing file, expand only when needed.
- Do not paste full logs into chat. Quote the 1-3 lines that matter.
- If reproduction needs setup, ask for a minimal repro the user already has.

## Workflow

### Step 1 — Restate the symptom
- One sentence. If ambiguous ("the page is broken"), ask one clarifying question with a concrete example.

### Step 2 — Reproduce
- Exact command, exact input, exact expected, exact actual.
- "It happens sometimes" is not reproduced; measure rate (run N times, count failures).

### Step 3 — Hypothesize
- 2–3 hypotheses, ranked by prior probability.
- Each hypothesis must be falsifiable with a cheap test.

### Step 4 — Narrow
- Run the cheapest disproving test for the most likely hypothesis.
- If it survives, refine; if it doesn't, move on.
- When stuck: bisect (commit / code path / input).

### Step 5 — Fix at root, not symptom
- A retry around a NullPointer is not a fix.
- A try/except that swallows is not a fix.
- A version bump without reading the changelog is not a fix.
- The fix is the smallest change that addresses the root cause.

### Step 6 — Regression test
- One test that fails before the fix and passes after.
- Test name describes the bug ("test_user_cannot_login_with_uppercase_email").
- A whole test suite is not required; one is enough.

### Step 7 — Verify
- Re-run the failing case; it now passes.
- Run the existing test suite; nothing else broke.
- If neither suite exists, run the affected code path manually and document the command.

### Step 8 — Memory update
- `<resolved memoryPath>/03-bugs/solved/<short-name>.md` — symptom, root cause, fix, regression test.
- If this is the 2nd+ occurrence, link from `03-bugs/recurring/index.md`.
- If the root cause is a class of issue (e.g., "always forget to update lock file"), add to `<resolved memoryPath>/02-decisions/`.

## Anti-patterns to refuse
- "Should work" without running it
- Adding logging "to see what happens" without a hypothesis
- Changing two things at once (now neither is testable)
- Speculative async/await rewrites for non-timing bugs
- Calling it "intermittent" without measurement
- "Restart fixed it" recorded as resolved

## Output format
```markdown
## Symptom (one line)

## Reproduction
- command:
- expected:
- actual:

## Hypotheses
1. ... → test → result
2. ...

## Root cause
- file:line — one-paragraph explanation

## Fix
- diff scope:
- side effects:

## Regression test
- name / file / what it asserts

## Verification
- failing case now passes:
- existing suite: <passed/failed/not present>

## Memory update
- 03-bugs/solved/<id>.md
```

## Safety rules
- Don't push a fix without reproducing first; if the user insists, mark the resolution as "tentative" in memory.
- Don't bump a dependency to "fix" without reading what changed in that version.
- Don't claim "fixed" without showing the failing case now passes.
- Long traces and bisect logs go to `<resolved memoryPath>/03-bugs/<id>/`; chat gets the summary.
