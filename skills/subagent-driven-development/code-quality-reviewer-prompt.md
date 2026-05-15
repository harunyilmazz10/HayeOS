# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
```

**In addition to standard code quality concerns, the reviewer should check:**
- Does each file have one clear responsibility with a well-defined interface?
- Are units decomposed so they can be understood and tested independently?
- Is the implementation following the file structure from the plan?
- Did this implementation create new files that are already large, or significantly grow existing files? (Don't flag pre-existing file sizes — focus on what this change contributed.)

## Severity Rules (v3.0.4 — required, not optional)

The reviewer MUST classify every finding into ONE of three severity levels and return a verdict accordingly:

### P0 — BLOCKED (security or data-loss risk)
Examples:
- XSS, SQL injection, command injection, path traversal
- Secret leaked in code (API key, password, token)
- Unhandled `localStorage.setItem` that can silently drop user data on quota exceeded
- Race condition that corrupts shared state
- Authentication bypass

**Verdict if any P0 finding exists: `## Karar: BLOCKED`** — implementer must rework before merge.

### P1 — REJECTED (a11y, error handling, runtime risk)
Examples:
- Missing `<label>` on form input (WCAG 3.3.2)
- No `try/catch` around storage / network / parse operations that can throw
- Missing `aria-live` on dynamic error/status regions
- No double-submit guard on submit handlers (causes duplicate state)
- Validation logic on client only with no server check (when server exists)
- Memory leak from listeners not cleaned up
- Missing input length cap (DoS via huge payload)

**Verdict if P1 findings exist (and no P0): `## Karar: REJECTED`** — must fix BEFORE merge, but plan-level acceptable scope.

### P2 — APPROVED WITH NOTES (style, maintainability)
Examples:
- Magic numbers without constants
- CSS hard-coded colors when custom properties could be used
- Repeated code that could be extracted
- Function too long (>50 lines), could be split
- Inconsistent naming
- Suboptimal but functional patterns

**Verdict if only P2 findings: `## Karar: APPROVED WITH NOTES`** — merge allowed, file an improvement note in `next.md`.

### Clean code (no findings)
**Verdict: `## Karar: APPROVED`**

## Anti-pattern the reviewer MUST avoid

The most common reviewer failure is downgrading P1 issues to P2 to "be nice." This breaks the system because the orchestrator treats APPROVED WITH NOTES as merge-allowed.

**Specific examples that MUST be P1 (REJECTED), NOT P2:**
- "Storage try/catch is missing" — NEVER P2. Runtime error risk = P1 (REJECTED).
- "Form input has no label, just placeholder" — NEVER P2. WCAG violation = P1 (REJECTED).
- "No ARIA live region for error messages" — NEVER P2. Screen reader users miss errors = P1 (REJECTED).
- "Same listener registered twice in two DOMContentLoaded blocks" — P2 if no functional impact, P1 if memory leak risk.

If you find yourself wanting to write "APPROVED WITH NOTES, but the user really should fix these production-critical issues," that's the signal to RESCORE to P1 REJECTED. Recommendations the implementer is unlikely to act on are worthless.

**Code reviewer returns:** Strengths, Issues (P0/P1/P2 with line numbers), Verdict (one of the four above)
