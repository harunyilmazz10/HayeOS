#!/usr/bin/env bash
# SessionStart hook for HayeOS plugin
# Injects the using-hayeos skill into every Claude Code session at start.
# This is the single most important difference between HayeOS and a passive plugin.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

using_hayeos_content=$(cat "${PLUGIN_ROOT}/skills/using-hayeos/SKILL.md" 2>&1 || echo "Error reading using-hayeos skill")

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

using_hayeos_escaped=$(escape_for_json "$using_hayeos_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have HayeOS active in this session.\n\n**Below is the full content of your 'haye:using-hayeos' skill - your introduction to HayeOS workflow and discipline. For all other skills, use the 'Skill' tool:**\n\n${using_hayeos_escaped}\n</EXTREMELY_IMPORTANT>"

if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context"
else
  printf '{\n  "additionalContext": "%s"\n}\n' "$session_context"
fi

exit 0
