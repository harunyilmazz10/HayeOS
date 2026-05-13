#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0
for prompt in "$SCRIPT_DIR/prompts"/*.txt; do
    skill=$(basename "$prompt" .txt)
    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt"; then
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
    fi
    echo ""
done
echo "=== Skill Triggering Results ==="
echo "PASS: $PASS"
echo "FAIL: $FAIL"
[ $FAIL -eq 0 ]
