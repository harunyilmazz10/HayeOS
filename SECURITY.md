# Security Policy

## Supported versions

The `3.x` release line is supported for security fixes and policy updates. The `2.x` line is end-of-life; users should migrate to v3 (see CHANGELOG.md for migration notes).

## Reporting

Please report security issues through GitHub Security Advisory for this repository. Do not post exploit details in public issues before coordination.

## Coordinated disclosure

HayeOS asks for a coordinated disclosure window of up to 90 days, unless active exploitation or user safety requires a faster public note.

## Scope

HayeOS treats dependency selection, secrets, exposed ports, auth, webhooks, admin routes, and update flows as security-sensitive. The plugin includes general security guidance in `docs/dependency-security-policy.md`, but users remain responsible for validation in their own deployment environment.

## Non-promises

- HayeOS does not magically secure user infrastructure.
- HayeOS cannot protect secrets that users manually paste into prompts.
- HayeOS does not guarantee external packages are currently safe without live advisory/audit verification.
- HayeOS does not exfiltrate, host, or manage vault content externally by itself.

## Defense in depth

Cloudflare WAF or similar edge controls are defense-in-depth. They are not a substitute for patching vulnerable dependencies, fixing auth/RBAC bugs, validating input, or handling secrets correctly.

## User responsibility

Run project-specific tests, dependency audits, deployment checks, and secret scans before production use. If live advisory access is unavailable, the verification report should explicitly note "current vulnerability status was not verified".
