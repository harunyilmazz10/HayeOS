#!/usr/bin/env bash
set -euo pipefail
python3 -m json.tool .claude-plugin/plugin.json >/dev/null
for key in name version description commands skills; do
  grep -q "\"$key\"" .claude-plugin/plugin.json || { echo "plugin manifest missing $key"; exit 1; }
done
if grep -q '"hooks"' .claude-plugin/plugin.json; then
  echo "plugin manifest must not reference standard hooks/hooks.json; Claude Code loads it automatically"; exit 1
fi
test -f hooks/hooks.json || { echo "missing hooks/hooks.json"; exit 1; }
claude plugin validate . >/dev/null
test -f .claude-plugin/marketplace.json || { echo "missing .claude-plugin/marketplace.json"; exit 1; }
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null
claude plugin validate .claude-plugin/marketplace.json >/dev/null
grep -q '"name": "haye-marketplace"' .claude-plugin/marketplace.json || { echo "marketplace name mismatch"; exit 1; }
grep -q '"name": "haye"' .claude-plugin/marketplace.json || { echo "marketplace missing haye plugin"; exit 1; }
grep -q '"source": "./"' .claude-plugin/marketplace.json || { echo "marketplace source must point to plugin root"; exit 1; }
count=$(find skills -name SKILL.md | wc -l | tr -d ' ')
echo "skills: $count"
if [ "$count" -lt 40 ]; then echo "expected at least 40 skills"; exit 1; fi
for f in $(find skills -name SKILL.md); do
  head -n1 "$f" | grep -q -- '---' || { echo "missing frontmatter $f"; exit 1; }
  sed -n '1,8p' "$f" | grep -q '^name:' || { echo "missing skill name $f"; exit 1; }
  sed -n '1,8p' "$f" | grep -q '^description:' || { echo "missing skill description $f"; exit 1; }
done
for cmd in start work fix secure ship close; do
  test -f "commands/$cmd.md" || { echo "missing command: $cmd"; exit 1; }
  grep -q "skills/$cmd/SKILL.md" "commands/$cmd.md" || { echo "command does not route to skill: $cmd"; exit 1; }
  sed -n '1,8p' "commands/$cmd.md" | grep -q '^description:' || { echo "command missing description: $cmd"; exit 1; }
done
grep -q "bin/haye init" commands/start.md skills/start/SKILL.md || { echo "start command does not route missing config to init"; exit 1; }
grep -q "package.json" commands/secure.md skills/secure/SKILL.md || { echo "secure command missing package.json guidance"; exit 1; }
grep -q "lockfile" commands/secure.md skills/secure/SKILL.md || { echo "secure command missing lockfile guidance"; exit 1; }
grep -q "current.md" commands/close.md skills/close/SKILL.md || { echo "close command missing memory update guidance"; exit 1; }
grep -R "Do not blindly use latest" skills docs README.md >/dev/null || { echo "missing safe version policy"; exit 1; }
grep -R "Cloudflare WAF is defense-in-depth" skills docs README.md >/dev/null || { echo "missing Cloudflare WAF policy"; exit 1; }
if grep -R "/hayeos:" README.md docs skills commands CODEX_AUDIT_PROMPT.md CHANGELOG.md SECURITY.md ROADMAP.md CONTRIBUTING.md >/dev/null; then
  echo "old /hayeos:* command reference found"; exit 1
fi
grep -q "Permanent Install" README.md || { echo "README missing permanent install section"; exit 1; }
grep -q "/plugin marketplace add /Users/haye/Desktop/HayeeOS" README.md docs/claude-code-install.md || { echo "docs missing local marketplace install command"; exit 1; }
grep -q "/plugin install haye@haye-marketplace" README.md docs/claude-code-install.md || { echo "docs missing plugin install command"; exit 1; }
test -x bin/haye
(cd examples/sample-project && ../../bin/haye find-vault >/dev/null && ../../bin/haye print-config >/dev/null && ../../bin/haye lint)
(cd examples/sample-project && ../../bin/haye deps-audit || true)
(cd examples/sample-project && ../../bin/haye react-nextjs-audit || true)
echo "verification OK"
