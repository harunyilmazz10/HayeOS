# HAYE.md

This project uses Haye memory-first workflow.

## Core rules
- Start with `/haye:start`.
- Close with `/haye:close`.
- Do not read the whole vault.
- Do not read `08-raw/` unless explicitly required.
- Do not blindly use `latest` for dependencies.
- Check official advisories when internet is available.
- Record safe dependency decisions in `02-decisions/safe-dependency-versions.md`.

## Framework Security Rule
For React/Next.js projects, Haye must check both dependency advisories and edge/WAF mitigation status. Cloudflare WAF may reduce exposure but vulnerable dependencies must still be patched. Do not mark safe unless dependency patch status and WAF status are documented.
