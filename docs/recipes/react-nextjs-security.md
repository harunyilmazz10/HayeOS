# React Next.js Security

Use this recipe for React Server Components, Next.js App Router, middleware/proxy routes, server actions, image optimization, cache components and Cloudflare-fronted apps.

## Local checks

1. Read `.hayeos.json` and inspect the configured `sourcePath`.
2. Inspect `package.json` and the active lockfile.
3. Run `./bin/haye react-nextjs-audit` from the project root or sample root.
4. Run the package manager audit command when dependencies are installed.

## Embedded baseline

- Avoid `react-server-dom-webpack`, `react-server-dom-parcel` and `react-server-dom-turbopack` versions `19.0.0-19.0.5`, `19.1.0-19.1.6`, `19.2.0-19.2.5`.
- Prefer patched compatible versions `19.0.6`, `19.1.7`, `19.2.6` or later compatible patch.
- Next.js 15.x must be `15.5.16+`.
- Next.js 16.x must be `16.2.5+`.
- Do not use `latest` as the basis for remediation.

## Live advisory rule

When internet is available, verify official React, Next.js/Vercel, package registry, GitHub Security Advisory and Cloudflare sources before choosing dependency versions.

When internet is unavailable, explicitly report that the recommendation is based on local package files and embedded Haye rules only.

Cloudflare WAF is defense-in-depth. It can reduce exposure while patching is scheduled, but it is not a dependency patch replacement.
