#!/usr/bin/env bash
# HayeOS v3.0.0 verify.sh
# Anti-regression checks for the Superpowers-based architecture.
# Run from plugin root.

set -uo pipefail

errors=0

fail() {
    echo "FAIL: $1" >&2
    errors=$((errors + 1))
}

ok() {
    echo "ok: $1"
}

# ----- structural checks -----

check_plugin_json_exists() {
    if [ ! -f .claude-plugin/plugin.json ]; then
        fail ".claude-plugin/plugin.json missing"
        return
    fi
    ok ".claude-plugin/plugin.json exists"
}

check_version_3() {
    local v
    v=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
    if [ "$v" != "3.0.1" ]; then
        fail "plugin.json version is $v, expected 3.0.1"
        return
    fi
    ok "plugin.json version: 3.0.1"
}

check_required_skills_present() {
    local required=(
        using-hayeos
        start
        work
        init-memory
        checkpoint
        close
        update
        brainstorming
        writing-plans
        executing-plans
        subagent-driven-development
        dispatching-parallel-agents
        test-driven-development
        verification-before-completion
        systematic-debugging
        requesting-code-review
        receiving-code-review
        using-git-worktrees
        finishing-a-development-branch
        writing-skills
    )
    for s in "${required[@]}"; do
        if [ ! -f "skills/$s/SKILL.md" ]; then
            fail "missing required skill: skills/$s/SKILL.md"
        fi
    done
    ok "all 20 required skills present"
}

check_removed_skills_absent() {
    local removed=(
        feature team-mode bugfix fix refactor migration review test-plan
        handoff session-close ingest-session memory-lint memory-start
        context-pack secure ship
        nextjs-doctor prisma-doctor docker-doctor coolify-doctor cloudflare-doctor
        database-doctor auth-audit secrets-audit exposed-port-audit
        react-nextjs-security dependency-audit dependency-security version-policy
        api-integration ai-agent-system saas-billing trading-terminal video-factory
        mobile-app content-automation n8n-pipeline security project-map
        token-audit deploy
    )
    for s in "${removed[@]}"; do
        if [ -d "skills/$s" ]; then
            fail "v2.x skill should be removed: skills/$s"
        fi
    done
    ok "all v2.x removed skills are absent"
}

check_no_agents_directory() {
    if [ -d agents ]; then
        fail "agents/ directory should not exist (v2.1.0+ removed it)"
        return
    fi
    ok "agents/ directory absent (correct)"
}

# ----- skill content checks -----

check_using_hayeos_has_iron_law() {
    if ! grep -q "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" skills/using-hayeos/SKILL.md; then
        fail "using-hayeos missing Iron Law line: NO COMPLETION CLAIMS..."
    fi
    if ! grep -q "NO IMPLEMENTATION CODE BEFORE BRAINSTORMING" skills/using-hayeos/SKILL.md; then
        fail "using-hayeos missing Iron Law line: NO IMPLEMENTATION CODE BEFORE BRAINSTORMING..."
    fi
    if ! grep -q "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" skills/using-hayeos/SKILL.md; then
        fail "using-hayeos missing Iron Law line: NO PRODUCTION CODE WITHOUT A FAILING TEST..."
    fi
    if ! grep -q 'NO PROJECT SOURCE CODE INSIDE THE MEMORY VAULT' skills/using-hayeos/SKILL.md; then
        fail "using-hayeos missing Iron Law line: NO PROJECT SOURCE CODE INSIDE THE MEMORY VAULT"
    fi
    if ! grep -q 'NO "DEVAM EDELIM" LOOPS' skills/using-hayeos/SKILL.md; then
        fail "using-hayeos missing Iron Law line: NO DEVAM EDELIM LOOPS..."
    fi
    ok "using-hayeos contains all 5 Iron Law lines"
}

check_work_routes_to_brainstorming() {
    if ! grep -q "Skill(haye:brainstorming)" skills/work/SKILL.md; then
        fail "work skill must route to Skill(haye:brainstorming)"
    fi
    if grep -q "Task Classification" skills/work/SKILL.md; then
        # Old v2.x marker - should be gone
        if ! grep -q "That was v2.x" skills/work/SKILL.md; then
            fail "work skill still has v2.x Task Classification block"
        fi
    fi
    ok "work skill routes to brainstorming (no v2.x mode classification)"
}

check_superpowers_skills_have_haye_layer() {
    local sp_skills=(brainstorming writing-plans executing-plans subagent-driven-development
                     dispatching-parallel-agents test-driven-development
                     verification-before-completion systematic-debugging
                     requesting-code-review receiving-code-review using-git-worktrees
                     finishing-a-development-branch writing-skills)
    for s in "${sp_skills[@]}"; do
        if ! grep -q "HayeOS Layer" "skills/$s/SKILL.md"; then
            fail "skills/$s missing 'HayeOS Layer' adapter section"
        fi
    done
    ok "all 13 Superpowers-derived skills have HayeOS Layer"
}

check_no_superpowers_namespace_leftovers() {
    local leak
    leak=$(grep -rn 'superpowers:' skills/ 2>/dev/null | head -3)
    if [ -n "$leak" ]; then
        fail "found 'superpowers:' namespace leftovers (should be haye:): $leak"
        return
    fi
    ok "no superpowers: namespace leftovers"
}

check_subagent_prompts_present() {
    local prompts=(implementer-prompt.md spec-reviewer-prompt.md code-quality-reviewer-prompt.md)
    for p in "${prompts[@]}"; do
        if [ ! -f "skills/subagent-driven-development/$p" ]; then
            fail "subagent-driven-development missing prompt template: $p"
        fi
    done
    ok "all 3 subagent prompt templates present"
}

# ----- bin / hooks / config checks -----

check_haye_cli_has_04_plans() {
    if ! grep -q "04-plans" bin/haye; then
        fail "bin/haye DIRS should include 04-plans for writing-plans output"
        return
    fi
    ok "bin/haye includes 04-plans directory"
}

check_hooks_present() {
    for h in run-hook.cmd session-start session-start.py \
             dangerous-command-guard large-file-warning \
             session-close-reminder hooks.json; do
        if [ ! -f "hooks/$h" ]; then
            fail "hooks/$h missing"
        fi
    done
    ok "all hook files present"
}

check_hooks_json_uses_run_hook_wrapper() {
    if ! grep -q "run-hook.cmd" hooks/hooks.json; then
        fail "hooks/hooks.json must use run-hook.cmd polyglot wrapper for cross-platform compatibility"
        return
    fi
    if grep -q "session-start.sh\|session-start.cmd" hooks/hooks.json; then
        fail "hooks/hooks.json should reference 'session-start' (extensionless), not .sh/.cmd"
        return
    fi
    ok "hooks.json uses run-hook.cmd polyglot wrapper"
}

check_run_hook_cmd_is_polyglot() {
    if ! grep -q "CMDBLOCK" hooks/run-hook.cmd; then
        fail "hooks/run-hook.cmd missing polyglot CMDBLOCK marker - won't work cross-platform"
        return
    fi
    if ! grep -q "@echo off" hooks/run-hook.cmd; then
        fail "hooks/run-hook.cmd missing Windows batch portion"
        return
    fi
    ok "run-hook.cmd is a valid polyglot script"
}

check_session_start_is_executable() {
    if [ ! -x "hooks/session-start" ]; then
        fail "hooks/session-start must be executable (chmod +x)"
        return
    fi
    ok "hooks/session-start is executable"
}

# ----- HARD-GATE hook checks (v3.0.0) -----

check_brainstorming_gate_hook_present() {
    if [ ! -f hooks/brainstorming-gate ]; then
        fail "hooks/brainstorming-gate missing - HARD-GATE not enforced"
        return
    fi
    if [ ! -x hooks/brainstorming-gate ]; then
        fail "hooks/brainstorming-gate must be executable (chmod +x)"
        return
    fi
    ok "brainstorming-gate hook present and executable"
}

check_init_guard_in_dangerous_command_guard() {
    if ! grep -q 'HAYE_INIT_APPROVED' hooks/dangerous-command-guard; then
        fail "dangerous-command-guard missing HAYE_INIT_APPROVED check - init bypass possible"
        return
    fi
    if ! grep -q 'haye init' hooks/dangerous-command-guard; then
        fail "dangerous-command-guard missing 'haye init' pattern"
        return
    fi
    ok "dangerous-command-guard enforces init HARD-GATE"
}

check_hooks_json_includes_brainstorming_gate() {
    if ! grep -q 'brainstorming-gate' hooks/hooks.json; then
        fail "hooks.json missing brainstorming-gate registration for Write|Edit|MultiEdit"
        return
    fi
    if ! grep -q 'Write|Edit|MultiEdit' hooks/hooks.json; then
        fail "hooks.json missing Write|Edit|MultiEdit matcher for brainstorming-gate"
        return
    fi
    ok "hooks.json registers brainstorming-gate for Write|Edit|MultiEdit"
}

check_init_memory_uses_approval_env_var() {
    if ! grep -q 'HAYE_INIT_APPROVED=1' skills/init-memory/SKILL.md; then
        fail "init-memory SKILL.md doesn't mention HAYE_INIT_APPROVED=1 env var - init will be blocked"
        return
    fi
    ok "init-memory uses HAYE_INIT_APPROVED=1 env var"
}

# ----- smart quote regression -----

check_no_smart_quotes() {
    local bad
    bad=$(python3 - <<'PY'
from pathlib import Path
bad=[]
for p in Path('.').rglob('*'):
    if p.is_file() and p.suffix in ['.md','.sh','.json','.py','.cmd','.txt']:
        try:
            t = p.read_text(encoding='utf-8', errors='ignore')
            if any(c in t for c in ['\u2018','\u2019','\u201c','\u201d']):
                bad.append(str(p))
        except: pass
for b in bad: print(b)
PY
)
    if [ -n "$bad" ]; then
        fail "smart quotes found in: $bad"
        return
    fi
    ok "no smart quote regressions"
}

# ----- run all checks -----

check_plugin_json_exists
check_version_3
check_required_skills_present
check_removed_skills_absent
check_no_agents_directory
check_using_hayeos_has_iron_law
check_work_routes_to_brainstorming
check_superpowers_skills_have_haye_layer
check_no_superpowers_namespace_leftovers
check_subagent_prompts_present
check_haye_cli_has_04_plans
check_hooks_present
check_hooks_json_uses_run_hook_wrapper
check_run_hook_cmd_is_polyglot
check_session_start_is_executable
check_brainstorming_gate_hook_present
check_init_guard_in_dangerous_command_guard
check_hooks_json_includes_brainstorming_gate
check_init_memory_uses_approval_env_var
check_no_smart_quotes

echo ""
if [ "$errors" -eq 0 ]; then
    echo "verification OK"
    exit 0
else
    echo "verification FAILED with $errors error(s)"
    exit 1
fi
