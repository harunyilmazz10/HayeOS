#!/usr/bin/env bash
# Test explicit HayeOS skill requests.
# Usage: ./run-test.sh <skill-name> <prompt-file>

set -e
SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-3}"

if [ -z "$SKILL_NAME" ] || [ -z "$PROMPT_FILE" ]; then
    echo "Usage: $0 <skill-name> <prompt-file> [max-turns]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/hayeos-tests/${TIMESTAMP}/explicit-skill-requests/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"
cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"
PROMPT=$(cat "$PROMPT_FILE")
LOG_FILE="$OUTPUT_DIR/claude-output.json"

echo "=== HayeOS Explicit Skill Request Test ==="
echo "Skill: $SKILL_NAME"
echo "Plugin dir: $PLUGIN_DIR"

cd "$OUTPUT_DIR"
timeout 300 claude -p "$PROMPT" \
    --plugin-dir "$PLUGIN_DIR" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --output-format stream-json \
    > "$LOG_FILE" 2>&1 || true

SKILL_PATTERN='"skill":"([^"]*:)?'"${SKILL_NAME}"'"'
if grep -q '"name":"Skill"' "$LOG_FILE" && grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
    echo "PASS: Skill '$SKILL_NAME' was triggered"
    exit 0
else
    echo "FAIL: Skill '$SKILL_NAME' was NOT triggered"
    echo "Skills triggered:"
    grep -o '"skill":"[^"]*"' "$LOG_FILE" | sort -u || echo "  (none)"
    exit 1
fi
