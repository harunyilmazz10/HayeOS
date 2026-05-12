# Dependency Security Policy

Do not blindly use latest. Check package files, lockfiles, audit output and official advisories when available. Prefer patched compatible explicit versions. Document live-check limitations.

If internet/advisory access is unavailable, write: "current vulnerability status was not verified." Do not claim a dependency choice is secure or safe unless advisory/audit verification was actually run and supports that claim.

## Required behavior

- Inspect `package.json` from configured `.hayeos.json` `sourcePath`.
- Inspect lockfiles when present. If no lockfile exists, report that dependency resolution is not pinned.
- Treat `latest` as an unsafe decision input. Select explicit patched compatible versions instead.
- Run the relevant local audit command when the package manager is available.
- When internet is available, check official sources before recommending versions: package registry, package manager audit, GitHub Security Advisories, React advisories, Next.js/Vercel release notes and Cloudflare changelog.
- When internet is unavailable, state that the result is based on local files and embedded Haye rules only.

## Dependency / Base Image Safety Rule

- Do not use latest tags in Docker images.
- Do not use placeholder image names like `myapp:latest`.
- Do not use fake image names like `your-*-image` or `placeholder-image`.
- Do not use `image: latest`.
- Do not include Docker Compose top-level `version` field.
- Use modern supported base images with explicit version tags.
- For Python service images, prefer a current supported slim base such as `python:3.12-slim` only if compatible, and record the decision.
- Do not use old/EOL examples such as `python:3.8`.
- If unsure, write the decision to dependency/security notes and mark as pending verification.
- Do not install dependencies blindly.
- Dependency install/update/remove is a risk gate: ask before `pip install`, `python -m pip install`, `py -m pip install`, `npm install`, `pnpm add`, `yarn add`, `docker pull` or Docker commands that pull unknown images.
- Never run package manager install/update/remove commands without explicit user approval.
- Record selected dependency decisions in `<resolved memoryPath>/02-decisions/` or project `docs/security/dependency-notes.md`.

## React / Next.js policy
- Choose `next`, `react` and `react-dom` as a compatible explicit-version set.
- Do not use `latest` in `package.json`.
- Check known RSC, SSR, middleware/proxy, server action, image optimization and cache-related advisories.
- Do not use vulnerable version ranges.
- Run `npm audit`, `pnpm audit`, `yarn audit` or equivalent when approval and tooling are available; if not run, report `not run`.
- Before `docker compose up`, check compose has no fake images, build contexts exist, referenced Dockerfiles exist, no top-level obsolete `version` field and no `latest` tags unless explicitly justified.
- Do not assume `pip` exists on Windows; prefer `py -m pip` or `python -m pip` after checking, and still require approval.
- Do not pin vulnerable EOL versions.

## React / Next.js embedded baseline

- Avoid React RSC packages `19.0.0-19.0.5`, `19.1.0-19.1.6`, `19.2.0-19.2.5`.
- Prefer patched compatible RSC packages `19.0.6`, `19.1.7`, `19.2.6` or later compatible patch.
- Next.js 15.x baseline is `15.5.16+`.
- Next.js 16.x baseline is `16.2.5+`.
- Cloudflare WAF is defense-in-depth. It does not replace dependency patching.

## Baseline lifecycle

- Embedded React/Next.js baseline last refreshed: May 2026.
- Review embedded baselines at least every 90 days.
- If the baseline is materially stale, perform live advisory/version verification when internet access is available.
- If live advisory access is unavailable, write: "current vulnerability status was not verified."
- Treat embedded baselines as a minimum floor, not a guarantee that no newer patched version exists.
