#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(pwd)"

check_plugin_root_clean() {
  for path in .hayeos.json 09-context-packs 05-sessions 04-tasks current.md next.md memory; do
    test ! -e "$ROOT_DIR/$path" || { echo "plugin root polluted with project memory: $path"; exit 1; }
  done
  if find "$ROOT_DIR" -maxdepth 1 -type d -name '*_obs' | grep -q .; then
    echo "plugin root polluted with project vault directory"; exit 1
  fi
}

check_plugin_root_clean
bad_project="yt""shorts"
bad_vault="${bad_project}_obs"
bad_win_user='C:\Us'"ers\hayed"
bad_mac_user='/Us'"ers/haye"
bad_win_users_root='C:\Us'"ers"
bad_unix_users_root='/Us'"ers/"
bad_proj_desktop='Desktop\'"Projeler"
bad_desktop_hayeos='Desktop/'"HayeOS"
if rg -F "$bad_project" . >/dev/null || rg -F "$bad_vault" . >/dev/null; then
  echo "project-specific hardcoded name found"; exit 1
fi
if rg -F "$bad_win_user" . >/dev/null || rg -F "$bad_mac_user" . >/dev/null || rg -F "$bad_win_users_root" . >/dev/null || rg -F "$bad_unix_users_root" . >/dev/null || rg -F "$bad_proj_desktop" . >/dev/null || rg -F "$bad_desktop_hayeos" . >/dev/null; then
  echo "user-specific hardcoded path found"; exit 1
fi
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
for cmd in start work fix secure ship close init-memory update; do
  test -f "commands/$cmd.md" || { echo "missing command: $cmd"; exit 1; }
  grep -q "skills/$cmd/SKILL.md" "commands/$cmd.md" || { echo "command does not route to skill: $cmd"; exit 1; }
  sed -n '1,8p' "commands/$cmd.md" | grep -q '^description:' || { echo "command missing description: $cmd"; exit 1; }
done
for cmd in start work fix secure ship close init-memory update; do
  grep -q "User Response Language Rule" "commands/$cmd.md" || { echo "commands/$cmd.md missing language rule"; exit 1; }
done
for skill in start work fix secure ship close init-memory update memory-start session-close context-pack dependency-security react-nextjs-security; do
  grep -q "User Response Language Rule" "skills/$skill/SKILL.md" || { echo "skills/$skill/SKILL.md missing language rule"; exit 1; }
done
grep -q "User Response Language Rule" commands/init-memory.md skills/init-memory/SKILL.md || { echo "init-memory missing language rule"; exit 1; }
grep -qi "fallback" skills/init-memory/SKILL.md || { echo "init-memory missing manual fallback"; exit 1; }
grep -q "CLAUDE_PLUGIN_ROOT" skills/init-memory/SKILL.md commands/init-memory.md || { echo "init-memory missing CLAUDE_PLUGIN_ROOT"; exit 1; }
test -f bin/haye.cmd || { echo "missing bin/haye.cmd"; exit 1; }
test -f bin/haye.ps1 || { echo "missing bin/haye.ps1"; exit 1; }
test -f docs/windows-install.md || { echo "missing docs/windows-install.md"; exit 1; }
grep -q "/haye:start" README.md || { echo "README missing /haye:start"; exit 1; }
grep -q "otomatik oluştur" README.md || { echo "README missing automatic memory setup"; exit 1; }
grep -q "Bu projede Haye hafızası bulunamadı" commands/start.md skills/start/SKILL.md || { echo "start command does not ask Turkish init question"; exit 1; }
grep -q "/haye:init-memory" commands/start.md skills/start/SKILL.md || { echo "start command does not route missing config to init-memory"; exit 1; }
grep -q "Start Light Rule" commands/start.md || { echo "commands/start.md missing Start Light Rule"; exit 1; }
grep -q "Start Light Rule" skills/start/SKILL.md || { echo "skills/start missing Start Light Rule"; exit 1; }
grep -q "must not use subagents" skills/start/SKILL.md || { echo "skills/start must forbid subagents"; exit 1; }
grep -q "must not enter plan mode" skills/start/SKILL.md || { echo "skills/start must forbid plan mode"; exit 1; }
grep -q "ask before creating \`.hayeos.json\`" skills/start/SKILL.md || { echo "skills/start must ask before creating .hayeos.json"; exit 1; }
if grep -q "project-map\\|token-audit" commands/start.md skills/start/SKILL.md; then echo "start must not route to heavy workflows"; exit 1; fi
grep -q "package.json" commands/secure.md skills/secure/SKILL.md || { echo "secure command missing package.json guidance"; exit 1; }
grep -q "lockfile" commands/secure.md skills/secure/SKILL.md || { echo "secure command missing lockfile guidance"; exit 1; }
grep -q "current.md" commands/close.md skills/close/SKILL.md || { echo "close command missing memory update guidance"; exit 1; }
grep -R "Do not blindly use latest" skills docs README.md >/dev/null || { echo "missing safe version policy"; exit 1; }
grep -R "Cloudflare WAF is defense-in-depth" skills docs README.md >/dev/null || { echo "missing Cloudflare WAF policy"; exit 1; }
if grep -R "/hayeos:" README.md docs skills commands CODEX_AUDIT_PROMPT.md CHANGELOG.md SECURITY.md ROADMAP.md CONTRIBUTING.md >/dev/null; then
  echo "old /hayeos:* command reference found"; exit 1
fi
grep -q "Permanent Install" README.md || { echo "README missing permanent install section"; exit 1; }
grep -q "/plugin marketplace add <hayeos-plugin-root>" README.md docs/claude-code-install.md || { echo "docs missing generic local marketplace install command"; exit 1; }
grep -q "/plugin install haye@haye-marketplace" README.md docs/claude-code-install.md || { echo "docs missing plugin install command"; exit 1; }
grep -q "Smart Work Router" commands/work.md || { echo "commands/work.md missing Smart Work Router"; exit 1; }
grep -q "Work Strategy Selection Rule" skills/work/SKILL.md || { echo "skills/work missing Work Strategy Selection Rule"; exit 1; }
grep -q "Work Strategy Selection Rule" commands/work.md || { echo "commands/work missing Work Strategy Selection Rule"; exit 1; }
grep -q "Work Strategy Selection Rule" docs/commands.md || { echo "docs/commands missing Work Strategy Selection Rule"; exit 1; }
grep -q "Massive Task Classification Rule" skills/work/SKILL.md || { echo "skills/work missing Massive Task Classification Rule"; exit 1; }
grep -q "Massive Task Classification Rule" docs/commands.md || { echo "docs/commands missing Massive Task Classification Rule"; exit 1; }
grep -q "Team Mode Offer Rule" skills/work/SKILL.md || { echo "skills/work missing Team Mode Offer Rule"; exit 1; }
grep -q "Team Mode Offer Rule" docs/commands.md || { echo "docs/commands missing Team Mode Offer Rule"; exit 1; }
grep -q "Fast Single Agent" skills/work/SKILL.md || { echo "skills/work missing Fast Single Agent"; exit 1; }
grep -q "Standard Single Agent" skills/work/SKILL.md || { echo "skills/work missing Standard Single Agent"; exit 1; }
grep -q "Plan First" skills/work/SKILL.md || { echo "skills/work missing Plan First"; exit 1; }
grep -q "Team Mode" skills/work/SKILL.md || { echo "skills/work missing Team Mode"; exit 1; }
grep -q "Full Architecture Mode" skills/work/SKILL.md || { echo "skills/work missing Full Architecture Mode"; exit 1; }
grep -q "task_size" skills/work/SKILL.md || { echo "skills/work missing task_size"; exit 1; }
grep -q "risk_level" skills/work/SKILL.md || { echo "skills/work missing risk_level"; exit 1; }
grep -q "recommended_mode" skills/work/SKILL.md || { echo "skills/work missing recommended_mode"; exit 1; }
grep -q "Approval Friction Rule" skills/work/SKILL.md || { echo "skills/work missing Approval Friction Rule"; exit 1; }
grep -q "No Fake Completion Rule" skills/work/SKILL.md || { echo "skills/work missing No Fake Completion Rule"; exit 1; }
grep -q "Output Budget Rule" skills/work/SKILL.md || { echo "skills/work missing Output Budget Rule"; exit 1; }
grep -q "64000 output token" skills/work/SKILL.md docs/commands.md README.md || { echo "missing output token limit prevention note"; exit 1; }
grep -q "Quality Preservation Rule" skills/work/SKILL.md || { echo "skills/work missing Quality Preservation Rule"; exit 1; }
grep -q "token-economist" skills/work/SKILL.md || { echo "skills/work missing token-economist"; exit 1; }
grep -q "strategy approval" skills/work/SKILL.md commands/work.md || { echo "work missing strategy approval semantics"; exit 1; }
grep -q "No Placeholder Production Rule" skills/work/SKILL.md docs/commands.md commands/work.md || { echo "missing No Placeholder Production Rule"; exit 1; }
grep -q "Foundation Quality Gate" skills/work/SKILL.md docs/commands.md || { echo "missing Foundation Quality Gate"; exit 1; }
grep -q "myapp:latest" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing myapp:latest forbidden pattern"; exit 1; }
grep -q "image: latest" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing image latest forbidden pattern"; exit 1; }
grep -q "Docker Compose top-level" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing Docker Compose version field rule"; exit 1; }
grep -q "python:3.8" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing python:3.8 forbidden pattern"; exit 1; }
grep -q "assert True" skills/work/SKILL.md docs/commands.md || { echo "missing assert True forbidden pattern"; exit 1; }
grep -qi "hello world" skills/work/SKILL.md docs/commands.md commands/work.md || { echo "missing hello world placeholder rule"; exit 1; }
test -f skills/team-mode/SKILL.md || { echo "missing internal team-mode skill"; exit 1; }
test -f skills/checkpoint/SKILL.md || { echo "missing checkpoint skill"; exit 1; }
test -f skills/checkpoint/templates/latest-checkpoint.md || { echo "missing latest checkpoint template"; exit 1; }
grep -q "Auto Checkpoint Rule" skills/work/SKILL.md || { echo "skills/work missing Auto Checkpoint Rule"; exit 1; }
grep -q "Safe Resume Rule" skills/start/SKILL.md || { echo "skills/start missing Safe Resume Rule"; exit 1; }
grep -q "latest-checkpoint.md" skills/start/SKILL.md || { echo "skills/start missing latest-checkpoint.md"; exit 1; }
grep -q "latest-checkpoint.md" skills/close/SKILL.md || { echo "skills/close missing latest-checkpoint.md"; exit 1; }
grep -q "Auto Checkpoint Rule" docs/commands.md || { echo "docs/commands missing Auto Checkpoint Rule"; exit 1; }
grep -q "Safe Resume Rule" docs/commands.md || { echo "docs/commands missing Safe Resume Rule"; exit 1; }
grep -q "Auto Checkpoint Rule" skills/init-memory/templates/HAYE.md || { echo "HAYE template missing Auto Checkpoint Rule"; exit 1; }
grep -q "Fast Mode" docs/commands.md || { echo "docs/commands missing Fast Mode"; exit 1; }
grep -q "Standard Mode" docs/commands.md || { echo "docs/commands missing Standard Mode"; exit 1; }
grep -q "Team Mode" docs/commands.md || { echo "docs/commands missing Team Mode"; exit 1; }
grep -q "Full Architecture Mode" docs/commands.md || { echo "docs/commands missing Full Architecture Mode"; exit 1; }
grep -q "Approval Friction Rule" docs/commands.md || { echo "docs/commands missing Approval Friction Rule"; exit 1; }
grep -q "Output Budget Rule" docs/commands.md || { echo "docs/commands missing Output Budget Rule"; exit 1; }
grep -q "Quality Preservation Rule" docs/commands.md || { echo "docs/commands missing Quality Preservation Rule"; exit 1; }
if ! grep -q "Output Budget Rule" README.md && ! grep -q "large outputs go to files" README.md; then
  echo "README missing Output Budget Rule"; exit 1
fi
grep -q "Quality Preservation Rule" skills/init-memory/templates/HAYE.md || { echo "HAYE template missing Quality Preservation Rule"; exit 1; }
grep -q "memoryPath" skills/context-pack/SKILL.md || { echo "context-pack missing memoryPath rule"; exit 1; }
grep -q "Never write project context packs to \`CLAUDE_PLUGIN_ROOT\`" skills/context-pack/SKILL.md || { echo "context-pack missing plugin root guard"; exit 1; }
grep -q "memoryPath" skills/checkpoint/SKILL.md || { echo "checkpoint missing memoryPath rule"; exit 1; }
grep -q "<resolved memoryPath>/05-sessions/latest-checkpoint.md" skills/checkpoint/SKILL.md skills/work/SKILL.md docs/commands.md docs/obsidian-vault-standard.md || { echo "missing resolved memoryPath checkpoint target"; exit 1; }
grep -q "<resolved memoryPath>/04-tasks/active-task.md" skills/checkpoint/SKILL.md skills/work/SKILL.md || { echo "missing resolved memoryPath active task target"; exit 1; }
grep -q "Plugin root" skills/start/SKILL.md || { echo "start missing Plugin root distinction"; exit 1; }
grep -q "Memory vault" skills/start/SKILL.md || { echo "start missing Memory vault distinction"; exit 1; }
grep -q "Plugin root and project memory vault are different" docs/obsidian-vault-standard.md || { echo "vault docs missing plugin/project distinction"; exit 1; }
grep -q "Plugin root vs project vault" skills/init-memory/templates/HAYE.md || { echo "HAYE template missing plugin/project distinction"; exit 1; }
test -f commands/update.md || { echo "missing commands/update.md"; exit 1; }
test -f skills/update/SKILL.md || { echo "missing skills/update/SKILL.md"; exit 1; }
grep -q "git pull --ff-only" skills/update/SKILL.md || { echo "update skill missing ff-only pull"; exit 1; }
grep -q "Never run \`git init\`" skills/update/SKILL.md || { echo "update skill must explicitly forbid git init"; exit 1; }
grep -q "Never run \`git remote add\`" skills/update/SKILL.md || { echo "update skill must explicitly forbid git remote add"; exit 1; }
bad_placeholder='[your_'"repository_url_here]"
if rg -F "$bad_placeholder" skills/update/SKILL.md commands/update.md docs/commands.md >/dev/null; then echo "update must not use placeholder remote"; exit 1; fi
if grep -q "reset --hard" skills/update/SKILL.md; then echo "update skill must not mention reset --hard"; exit 1; fi
grep -q "/haye:update" docs/commands.md || { echo "docs/commands missing /haye:update"; exit 1; }
if grep -q "force" skills/update/SKILL.md commands/update.md README.md docs/commands.md; then echo "update docs must not recommend force behavior"; exit 1; fi
test -x bin/haye
(cd examples/sample-project && ../../bin/haye find-vault >/dev/null && ../../bin/haye print-config >/dev/null && ../../bin/haye lint)
(tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/hayeos-verify-XXXXXX") && cp -R examples/sample-project "$tmpdir/sample-project" && out=$(cd "$tmpdir/sample-project" && "$ROOT_DIR/bin/haye" context-pack verify-target-path) && expected=$(cd "$tmpdir/sample-project/Sample_obs/09-context-packs" && pwd -P) && actual=$(dirname "$out") && actual=$(cd "$actual" && pwd -P) && test "$actual" = "$expected" || { echo "context-pack wrote outside sample memoryPath: $out"; exit 1; })
(tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/hayeos-init-verify-XXXXXX") && project_name=final-start-test && mkdir -p "$tmpdir/$project_name" && cd "$tmpdir/$project_name" && python3 "$ROOT_DIR/bin/haye" init >/dev/null && python3 "$ROOT_DIR/bin/haye" health >/dev/null && vault="${project_name}_obs" && test -f .hayeos.json && test -d "$vault" && test ! -d memory && test -f "$vault/HAYE.md" && test -f "$vault/index.md" && test -f "$vault/current.md" && test -f "$vault/next.md" && test -f "$vault/changelog.md" && test -f "$vault/health.md" && test -d "$vault/04-tasks" && test -d "$vault/05-sessions" && test -d "$vault/09-context-packs" && python3 - <<'PY'
import json
import os
from pathlib import Path
cfg=json.loads(Path('.hayeos.json').read_text())
project_name=Path.cwd().name
assert cfg == {
    'project': project_name,
    'memoryPath': f'./{project_name}_obs',
    'sourcePath': '.',
    'defaultWorkflow': 'memory-first',
    'sessionCloseRequired': True,
}
assert not cfg['memoryPath'].startswith(('C:', 'c:', '/', '\\\\'))
assert '\\' not in cfg['memoryPath']
assert cfg['memoryPath'] != './memory'
assert cfg['sourcePath']=='.'
PY
)
check_plugin_root_clean
(cd examples/sample-project && ../../bin/haye deps-audit || true)
(cd examples/sample-project && ../../bin/haye react-nextjs-audit || true)
check_plugin_root_clean
echo "verification OK"
