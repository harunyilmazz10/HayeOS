# Dependency Security Policy

Do not blindly use latest. Check package files, lockfiles, audit output and official advisories when available. Prefer patched compatible versions. Document live-check limitations.

## Required behavior

- Inspect `package.json` from configured `.hayeos.json` `sourcePath`.
- Inspect lockfiles when present. If no lockfile exists, report that dependency resolution is not pinned.
- Treat `latest` as an unsafe decision input. Select explicit patched compatible versions instead.
- Run the relevant local audit command when the package manager is available.
- When internet is available, check official sources before recommending versions: package registry, package manager audit, GitHub Security Advisories, React advisories, Next.js/Vercel release notes and Cloudflare changelog.
- When internet is unavailable, state that the result is based on local files and embedded Haye rules only.

## React / Next.js embedded baseline

- Avoid React RSC packages `19.0.0-19.0.5`, `19.1.0-19.1.6`, `19.2.0-19.2.5`.
- Prefer patched compatible RSC packages `19.0.6`, `19.1.7`, `19.2.6` or later compatible patch.
- Next.js 15.x baseline is `15.5.16+`.
- Next.js 16.x baseline is `16.2.5+`.
- Cloudflare WAF is defense-in-depth. It does not replace dependency patching.
