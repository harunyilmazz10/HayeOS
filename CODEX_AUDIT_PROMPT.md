You are auditing and upgrading an existing repository named Haye / HayeOS.

Do not recreate from scratch. Inspect the repo first, then improve it.

Project goal:
Haye is a Claude Code plugin with Obsidian-powered memory, simplified daily commands, advanced workflow skills, dependency security, React/Next/Cloudflare advisory awareness, CLI helpers, agents, hooks and examples.

Important user-facing commands:
/haye:start
/haye:work
/haye:fix
/haye:secure
/haye:ship
/haye:close

Advanced skills must remain available.

Audit checklist:
1. Validate .claude-plugin/plugin.json.
2. Validate every skills/*/SKILL.md has YAML frontmatter and useful operational content.
3. Confirm the simplified commands route clearly to advanced workflows.
4. Confirm .hayeos.json is respected.
5. Confirm Obsidian vault generation creates useful files, not empty placeholders.
6. Confirm CLI works without external dependencies.
7. Confirm dependency security workflow does not blindly use latest.
8. Confirm React/Next.js security baseline exists:
   - RSC packages avoid 19.0.0-19.0.5, 19.1.0-19.1.6, 19.2.0-19.2.5
   - patched 19.0.6 / 19.1.7 / 19.2.6 or later compatible patch
   - Next.js 15.x baseline 15.5.16+
   - Next.js 16.x baseline 16.2.5+
   - Cloudflare WAF is defense-in-depth, not dependency patch replacement
9. Confirm internet/live advisory rule exists: when available, use official sources before choosing dependency versions; when unavailable, document limitation.
10. Strengthen weak/placeholder docs, skills, templates and CLI behavior.
11. Add tests or verification scripts where useful.
12. Run scripts/verify.sh and show results.
13. Produce a final report with changed files, issues fixed, remaining TODOs, and how to install/use.

Do not remove the simple command layer. Do not rename the plugin unless necessary. Keep all content original.
