#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(pwd)"

check_markdown_frontmatter() {
  python3 - <<'PY'
from pathlib import Path
import sys

errors = []
files = sorted(Path("commands").glob("*.md")) + sorted(Path("skills").glob("*/SKILL.md"))
for path in files:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        errors.append(f"{path}: frontmatter must start with standalone ---")
        continue
    try:
        close_idx = next(i for i in range(1, min(len(lines), 20)) if lines[i].strip() == "---")
    except StopIteration:
        errors.append(f"{path}: frontmatter must close with standalone ---")
        continue
    fm = "\n".join(lines[1:close_idx])
    if path.parts[0] == "commands":
        if "description:" not in fm:
            errors.append(f"{path}: command frontmatter missing description")
    else:
        if "name:" not in fm:
            errors.append(f"{path}: skill frontmatter missing name")
        if "description:" not in fm:
            errors.append(f"{path}: skill frontmatter missing description")
    if close_idx + 1 >= len(lines) or lines[close_idx + 1].strip() != "":
        errors.append(f"{path}: frontmatter closing --- must be followed by a blank line")
    if close_idx + 2 >= len(lines) or not lines[close_idx + 2].startswith("# "):
        errors.append(f"{path}: markdown title must start after frontmatter")
    if lines[0].strip() != "---" or " ---" in lines[0]:
        errors.append(f"{path}: frontmatter marker must not share a line with metadata")

if errors:
    print("Markdown/frontmatter format errors:")
    for error in errors:
        print("-", error)
    sys.exit(1)
PY
}

check_memory_path_contract() {
  python3 - <<'PY'
from pathlib import Path
import re
import sys

errors = []
files = sorted(Path("commands").glob("*.md")) + sorted(Path("skills").glob("*/SKILL.md"))
target_re = re.compile(
    r"(?<!<resolved memoryPath>/)"
    r"(05-sessions/|04-tasks/|09-context-packs/|02-decisions/|12-risks/|"
    r"current\.md|next\.md|changelog\.md|health\.md)"
)
for path in files:
    text = path.read_text(encoding="utf-8")
    for match in target_re.finditer(text):
        line = text.count("\n", 0, match.start()) + 1
        errors.append(f"{path}:{line}: bare memory target `{match.group(1)}` must use <resolved memoryPath>/...")

init_text = Path("skills/init-memory/SKILL.md").read_text(encoding="utf-8")
if "./_obs" in init_text or '"project": ""' in init_text or '"memoryPath": "./_obs"' in init_text:
    errors.append("skills/init-memory/SKILL.md: fallback must use <project-name> and ./<project-name>_obs, never ./_obs")
if "If memory is missing, initialize it automatically" in init_text:
    errors.append("skills/init-memory/SKILL.md: start flow must not say memory initializes automatically without approval")

checkpoint = Path("skills/checkpoint/SKILL.md").read_text(encoding="utf-8")
if "Checkpoint file locations under resolved `memoryPath`" not in checkpoint:
    errors.append("skills/checkpoint/SKILL.md: checkpoint locations must be explicitly under resolved memoryPath")
if "<resolved memoryPath>/05-sessions/latest-checkpoint.md" not in checkpoint:
    errors.append("skills/checkpoint/SKILL.md: missing resolved checkpoint target")

context = Path("skills/context-pack/SKILL.md").read_text(encoding="utf-8")
if "Write context packs ONLY to `<resolved memoryPath>/09-context-packs/`" not in context:
    errors.append("skills/context-pack/SKILL.md: context packs must target resolved memoryPath")

if errors:
    print("Memory path contract errors:")
    for error in errors:
        print("-", error)
    sys.exit(1)
PY
}

check_special_skill_contracts() {
  python3 - <<'PY'
from pathlib import Path
import sys

errors = []
special = [
    Path("skills/memory-start/SKILL.md"),
    Path("skills/start/SKILL.md"),
    Path("skills/init-memory/SKILL.md"),
    Path("skills/context-pack/SKILL.md"),
    Path("skills/checkpoint/SKILL.md"),
    Path("skills/close/SKILL.md"),
    Path("skills/session-close/SKILL.md"),
    Path("skills/update/SKILL.md"),
]
forbidden = [
    "Execute the smallest safe step",
    "Create or reuse a context pack when work is non-trivial",
    "Identify task type, risks and affected files",
    "Verify with real commands when possible",
    "Update memory through `/haye:close` or session-close rules",
]
for path in special:
    text = path.read_text(encoding="utf-8")
    for phrase in forbidden:
        if phrase in text:
            errors.append(f"{path}: forbidden generic workflow phrase: {phrase}")

memory_start = Path("skills/memory-start/SKILL.md").read_text(encoding="utf-8")
for phrase in [
    "must not execute implementation",
    "must not create context packs",
    "must not run tests/build/lint",
    "must not load `/haye:work`",
    "Hangi görevle devam edelim?",
]:
    if phrase not in memory_start:
        errors.append(f"skills/memory-start/SKILL.md missing contract phrase: {phrase}")

for path in [Path("skills/close/SKILL.md"), Path("skills/session-close/SKILL.md")]:
    text = path.read_text(encoding="utf-8")
    for phrase in [
        "must not start implementation",
        "must not create context packs",
        "must write only under `<resolved memoryPath>`",
        "<resolved memoryPath>/05-sessions/latest-checkpoint.md",
        "<resolved memoryPath>/changelog.md",
        "<resolved memoryPath>/current.md",
        "<resolved memoryPath>/next.md",
        "<resolved memoryPath>/04-tasks/active-task.md",
    ]:
        if phrase not in text:
            errors.append(f"{path} missing close contract phrase: {phrase}")

context = Path("skills/context-pack/SKILL.md").read_text(encoding="utf-8")
for phrase in [
    "Write context packs ONLY to `<resolved memoryPath>/09-context-packs/`",
    "must not execute implementation",
    "must not run tests/build/lint",
]:
    if phrase not in context:
        errors.append(f"skills/context-pack/SKILL.md missing contract phrase: {phrase}")

forbidden_user_name = "Ha" + "run"
for path in (
    sorted(Path("bin").glob("*"))
    + sorted(Path("commands").glob("*.md"))
    + sorted(Path("skills").glob("*/SKILL.md"))
    + sorted(Path("docs").rglob("*.md"))
    + [Path("README.md")]
    + sorted(Path(".claude-plugin").glob("*.json"))
):
    if path.is_file() and forbidden_user_name in path.read_text(encoding="utf-8", errors="ignore"):
        errors.append(f"{path}: user-specific hardcode found")

if errors:
    print("Special skill contract errors:")
    for error in errors:
        print("-", error)
    sys.exit(1)
PY
}

check_init_fallback_and_readme_commands() {
  python3 - <<'PY'
from pathlib import Path
import re
import sys

errors = []

init_text = Path("skills/init-memory/SKILL.md").read_text(encoding="utf-8")
bad_root_phrases = [
    "memory files in the current project root",
    "create the memory files in the current project root",
]
for phrase in bad_root_phrases:
    if phrase in init_text:
        errors.append(f"skills/init-memory/SKILL.md: unsafe fallback wording remains: {phrase}")

critical_haye_sections = [
    "Plugin root vs project vault",
    "Approval Friction Rule",
    "No Fake Completion Rule",
    "Output Budget Rule",
    "Quality Preservation Rule",
    "Auto Checkpoint Rule",
    "Safe Resume Rule",
    "Scope Control Rule",
    "Framework Security Rule",
]
uses_canonical = "skills/init-memory/templates/HAYE.md" in init_text and "canonical template" in init_text
if uses_canonical:
    for section in critical_haye_sections:
        if section not in init_text:
            errors.append(f"skills/init-memory/SKILL.md: canonical fallback reference missing critical section name: {section}")
else:
    for section in critical_haye_sections:
        if section not in init_text:
            errors.append(f"skills/init-memory/SKILL.md: fallback HAYE content missing critical section: {section}")

allowed = {path.stem for path in Path("commands").glob("*.md")}
readme = Path("README.md").read_text(encoding="utf-8")
unknown = sorted({match.group(1) for match in re.finditer(r"/haye:([A-Za-z0-9_-]+)", readme) if match.group(1) not in allowed})
if unknown:
    errors.append("README.md: unknown user-facing slash command references: " + ", ".join(f"/haye:{name}" for name in unknown))
if "/haye:react-nextjs-security" in readme:
    errors.append("README.md: internal react-nextjs-security skill must not be documented as /haye:react-nextjs-security")

for cmd in sorted(allowed):
    if f"/haye:{cmd}" not in readme:
        errors.append(f"README.md: missing user-facing command reference /haye:{cmd}")

after_install = re.search(r"After install, new Claude Code sessions should expose:\n\n```text\n(?P<body>.*?)\n```", readme, re.S)
if not after_install:
    errors.append("README.md: missing after-install exposed command list")
else:
    body = after_install.group("body")
    for cmd in sorted(allowed):
        if f"/haye:{cmd}" not in body:
            errors.append(f"README.md: after-install command list missing /haye:{cmd}")

if errors:
    print("Init fallback / README command accuracy errors:")
    for error in errors:
        print("-", error)
    sys.exit(1)
PY
}

check_work_consistency_and_template_failfast() {
  python3 - <<'PY'
from pathlib import Path
import re
import sys

errors = []

work_cmd = Path("commands/work.md").read_text(encoding="utf-8")
required_modes = [
    "Fast Single Agent",
    "Standard Single Agent",
    "Plan First",
    "Team Mode",
    "Full Architecture Mode",
]
recommended_lines = [line for line in work_cmd.splitlines() if "`recommended_mode`" in line]
if not recommended_lines:
    errors.append("commands/work.md: missing recommended_mode line")
else:
    combined = "\n".join(recommended_lines)
    for mode in required_modes:
        if mode not in combined:
            errors.append(f"commands/work.md: recommended_mode line missing {mode}")
old_enum = re.compile(r"`recommended_mode`:\s*`fa" + r"st`,\s*`stan" + r"dard`,\s*`te" + r"am`,\s*`full-archi" + r"tecture`")
if old_enum.search(work_cmd):
    errors.append("commands/work.md: old recommended_mode enum remains")

bad_close_phrase = "leave memory updates" + " for `/haye:close`"
bad_close_phrase_plain = "leave memory updates" + " for /haye:close"
if bad_close_phrase in work_cmd or bad_close_phrase_plain in work_cmd:
    errors.append("commands/work.md: checkpoint/update wording still conflicts with Auto Checkpoint Rule")
for phrase in [
    "Checkpoint and active task state may be updated during `/haye:work` according to Auto Checkpoint Rule",
    "Final session handoff and close-time memory consolidation belong to `/haye:close`",
]:
    if phrase not in work_cmd:
        errors.append(f"commands/work.md: missing checkpoint/close separation phrase: {phrase}")

old_loop_phrase = "bölümlere ayır" + " ve kullanıcıdan devam onayı iste"
old_loop_phrase_passive = "bölümlere ayrılır" + " ve kullanıcıdan devam onayı istenir"
for path in [
    Path("commands/work.md"),
    Path("skills/work/SKILL.md"),
    Path("skills/context-pack/SKILL.md"),
    Path("docs/commands.md"),
]:
    text = path.read_text(encoding="utf-8")
    if old_loop_phrase in text or old_loop_phrase_passive in text:
        errors.append(f"{path}: old output continuation loop wording remains")
    for phrase in [
        "prefer writing the detailed content to `docs/` or the HayeOS vault",
        "Ask for continuation only if the user explicitly requested a long multi-part chat response",
    ]:
        if phrase not in text:
            errors.append(f"{path}: missing output budget anti-loop phrase: {phrase}")

bin_text = Path("bin/haye").read_text(encoding="utf-8")
if "Canonical HAYE template is missing; refusing to initialize an incomplete vault." not in bin_text:
    errors.append("bin/haye: missing canonical template fail-fast error")
if "return f'''# HAYE.md" in bin_text or 'return f"""# HAYE.md' in bin_text:
    errors.append("bin/haye: short embedded fallback HAYE template remains")

if errors:
    print("Work consistency / output budget / template fail-fast errors:")
    for error in errors:
        print("-", error)
    sys.exit(1)
PY
}

check_cli_failure_modes() {
  python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import json
import subprocess
import sys
import tempfile

root = Path(sys.argv[1]).resolve()
bin_haye = root / "bin" / "haye"
errors = []

with tempfile.TemporaryDirectory(prefix="hayeos-cli-failure-") as tmp:
    project = Path(tmp) / "unsafe-project"
    project.mkdir()
    unsafe_target = str(root)
    (project / ".hayeos.json").write_text(json.dumps({
        "project": "unsafe-project",
        "memoryPath": unsafe_target,
        "sourcePath": ".",
        "defaultWorkflow": "memory-first",
        "sessionCloseRequired": True,
    }), encoding="utf-8")
    proc = subprocess.run([sys.executable, str(bin_haye), "init"], cwd=project, text=True, capture_output=True)
    if proc.returncode == 0:
        errors.append("bin/haye init returned 0 for unsafe memoryPath under plugin root")
    if "vault ready" in (proc.stdout + proc.stderr):
        errors.append("bin/haye init printed vault ready for unsafe memoryPath")

with tempfile.TemporaryDirectory(prefix="hayeos-cli-invalid-json-") as tmp:
    project = Path(tmp) / "invalid-json-project"
    project.mkdir()
    (project / ".hayeos.json").write_text("{ invalid json", encoding="utf-8")
    proc = subprocess.run([sys.executable, str(bin_haye), "init"], cwd=project, text=True, capture_output=True)
    if proc.returncode == 0:
        errors.append("bin/haye init returned 0 for invalid .hayeos.json")
    if (project / "invalid-json-project_obs").exists():
        errors.append("bin/haye init created vault despite invalid .hayeos.json")

with tempfile.TemporaryDirectory(prefix="hayeos-cli-nonobject-json-") as tmp:
    project = Path(tmp) / "nonobject-json-project"
    project.mkdir()
    (project / ".hayeos.json").write_text("[]", encoding="utf-8")
    proc = subprocess.run([sys.executable, str(bin_haye), "init"], cwd=project, text=True, capture_output=True)
    if proc.returncode == 0:
        errors.append("bin/haye init returned 0 for non-object .hayeos.json")
    if (project / "nonobject-json-project_obs").exists():
        errors.append("bin/haye init created vault despite non-object .hayeos.json")

if errors:
    print("CLI failure mode errors:")
    for error in errors:
        print("-", error)
    sys.exit(1)
PY
}

check_plugin_root_clean() {
  for path in .hayeos.json 09-context-packs 05-sessions 04-tasks current.md next.md memory; do
    test ! -e "$ROOT_DIR/$path" || { echo "plugin root polluted with project memory: $path"; exit 1; }
  done
  if find "$ROOT_DIR" -maxdepth 1 -type d -name '*_obs' | grep -q .; then
    echo "plugin root polluted with project vault directory"; exit 1
  fi
}

check_markdown_frontmatter
check_memory_path_contract
check_special_skill_contracts
check_init_fallback_and_readme_commands
check_work_consistency_and_template_failfast
check_cli_failure_modes
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
grep -q "must not load \`/haye:work\`" skills/start/SKILL.md || { echo "skills/start must forbid loading work"; exit 1; }
grep -q "must not start a task classification wizard" skills/start/SKILL.md || { echo "skills/start must forbid classification wizard"; exit 1; }
grep -q "Şimdi hafızayı başlatmamı ister misiniz" commands/start.md skills/start/SKILL.md docs/commands.md || { echo "start must forbid second memory-start question"; exit 1; }
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
grep -q "affected_layers" skills/work/SKILL.md || { echo "skills/work missing affected_layers"; exit 1; }
grep -q "Full Architecture Mode Gate" skills/work/SKILL.md docs/commands.md || { echo "missing Full Architecture Mode Gate"; exit 1; }
grep -q "Approval Friction Rule" skills/work/SKILL.md || { echo "skills/work missing Approval Friction Rule"; exit 1; }
grep -q "No Fake Completion Rule" skills/work/SKILL.md || { echo "skills/work missing No Fake Completion Rule"; exit 1; }
grep -q "Output Budget Rule" skills/work/SKILL.md || { echo "skills/work missing Output Budget Rule"; exit 1; }
grep -q "64000 output token" skills/work/SKILL.md docs/commands.md README.md || { echo "missing output token limit prevention note"; exit 1; }
grep -q "Quality Preservation Rule" skills/work/SKILL.md || { echo "skills/work missing Quality Preservation Rule"; exit 1; }
grep -q "token-economist" skills/work/SKILL.md || { echo "skills/work missing token-economist"; exit 1; }
grep -q "strategy approval" skills/work/SKILL.md commands/work.md || { echo "work missing strategy approval semantics"; exit 1; }
grep -q "Original Prompt Preservation Rule" skills/work/SKILL.md commands/work.md docs/commands.md README.md || { echo "missing Original Prompt Preservation Rule"; exit 1; }
grep -q "<resolved memoryPath>/01-prompts/initial-master-prompt.md" skills/work/SKILL.md commands/work.md docs/commands.md README.md || { echo "missing initial master prompt target"; exit 1; }
grep -q "<resolved memoryPath>/01-prompts/work-request-YYYY-MM-DD-HHMM.md" skills/work/SKILL.md commands/work.md docs/commands.md README.md || { echo "missing work prompt timestamp target"; exit 1; }
grep -q "Original prompt verbatim" skills/work/SKILL.md || { echo "work missing verbatim prompt preservation"; exit 1; }
grep -q "No Placeholder Production Rule" skills/work/SKILL.md docs/commands.md commands/work.md || { echo "missing No Placeholder Production Rule"; exit 1; }
grep -q "Foundation Quality Gate" skills/work/SKILL.md docs/commands.md || { echo "missing Foundation Quality Gate"; exit 1; }
grep -q "myapp:latest" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing myapp:latest forbidden pattern"; exit 1; }
grep -q "your-\\*-image" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing your-*-image forbidden pattern"; exit 1; }
grep -q "placeholder-image" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing placeholder-image forbidden pattern"; exit 1; }
grep -q "image: latest" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing image latest forbidden pattern"; exit 1; }
grep -q "Docker Compose top-level" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing Docker Compose version field rule"; exit 1; }
grep -q "python:3.8" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing python:3.8 forbidden pattern"; exit 1; }
grep -q "assert True" skills/work/SKILL.md docs/commands.md || { echo "missing assert True forbidden pattern"; exit 1; }
grep -qi "hello world" skills/work/SKILL.md docs/commands.md commands/work.md || { echo "missing hello world placeholder rule"; exit 1; }
grep -q "2-line docs" skills/work/SKILL.md docs/commands.md || { echo "missing shallow docs forbidden rule"; exit 1; }
grep -q "Aşama tamamlandı" skills/work/SKILL.md docs/commands.md || { echo "missing pre-gate completion wording rule"; exit 1; }
grep -q "pip install" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing pip install risk gate"; exit 1; }
grep -q "npm install" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing npm install risk gate"; exit 1; }
grep -q "docker pull" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing docker pull risk gate"; exit 1; }
grep -q "docker compose up" skills/work/SKILL.md docs/commands.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing docker compose preflight rule"; exit 1; }
grep -q "Do not assume \`pip\` exists on Windows" skills/work/SKILL.md skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "missing Windows pip rule"; exit 1; }
grep -q "Do not use \`latest\`" skills/dependency-security/SKILL.md || { echo "dependency-security missing latest ban"; exit 1; }
grep -q "stable patched explicit version" skills/dependency-security/SKILL.md || { echo "dependency-security missing stable patched explicit version rule"; exit 1; }
grep -q "current vulnerability status was not verified" skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "dependency-security missing not verified rule"; exit 1; }
grep -q "Do not say \`secure\`, \`safe\`" skills/dependency-security/SKILL.md || { echo "dependency-security missing no unverified secure/safe claim rule"; exit 1; }
grep -q "Never run package manager install/update/remove commands without explicit user approval" skills/dependency-security/SKILL.md docs/dependency-security-policy.md || { echo "dependency-security missing package manager approval rule"; exit 1; }
grep -q "React / Next.js dependency contract" skills/react-nextjs-security/SKILL.md || { echo "react-nextjs-security missing dependency contract"; exit 1; }
grep -q "Choose \`next\`, \`react\` and \`react-dom\` as a compatible" skills/dependency-security/SKILL.md skills/react-nextjs-security/SKILL.md docs/dependency-security-policy.md || { echo "missing Next/React compatibility rule"; exit 1; }
grep -q "known RSC, SSR, middleware/proxy, server action" skills/dependency-security/SKILL.md skills/react-nextjs-security/SKILL.md docs/dependency-security-policy.md || { echo "missing React/Next advisory coverage rule"; exit 1; }
grep -q "Record selected version decisions in \`<resolved memoryPath>/02-decisions/\`" skills/dependency-security/SKILL.md skills/react-nextjs-security/SKILL.md || { echo "missing dependency decision memory rule"; exit 1; }
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
(tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/hayeos-init-verify-XXXXXX") && project_name=final-start-test && mkdir -p "$tmpdir/$project_name" && cd "$tmpdir/$project_name" && python3 "$ROOT_DIR/bin/haye" init >/dev/null && python3 "$ROOT_DIR/bin/haye" health >/dev/null && vault="${project_name}_obs" && test -f .hayeos.json && test -d "$vault" && test -d "$vault/01-prompts" && test -d "$vault/04-tasks" && test -d "$vault/05-sessions" && test -d "$vault/09-context-packs" && test ! -d memory && test ! -d 01-prompts && test ! -d 04-tasks && test ! -d 05-sessions && test ! -d 09-context-packs && test ! -f current.md && test ! -f next.md && test -f "$vault/HAYE.md" && test -f "$vault/index.md" && test -f "$vault/current.md" && test -f "$vault/next.md" && test -f "$vault/changelog.md" && test -f "$vault/health.md" && ROOT_DIR_FOR_HAYE_VERIFY="$ROOT_DIR" python3 - <<'PY'
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
vault=Path(f'{project_name}_obs')
generated=(vault/'HAYE.md').read_text(encoding='utf-8')
template=Path(os.environ.get('ROOT_DIR_FOR_HAYE_VERIFY','')).joinpath('skills/init-memory/templates/HAYE.md').read_text(encoding='utf-8')
forbidden_user_name='Ha'+'run'
assert forbidden_user_name not in generated
assert 'HayeOS user-facing' in generated or 'varsayılan olarak Türkçe' in generated
for phrase in ['Plugin root vs project vault','Auto Checkpoint Rule','Quality Preservation Rule']:
    assert phrase in generated
    assert phrase in template
for phrase in [
    'HayeOS user-facing komutlarda varsayılan olarak Türkçe konuşur.',
    'Plugin root vs project vault',
    'Auto Checkpoint Rule',
    'Quality Preservation Rule',
]:
    assert phrase in generated
    assert phrase in template
PY
)
check_plugin_root_clean
(cd examples/sample-project && ../../bin/haye deps-audit || true)
(cd examples/sample-project && ../../bin/haye react-nextjs-audit || true)
check_plugin_root_clean
echo "verification OK"
