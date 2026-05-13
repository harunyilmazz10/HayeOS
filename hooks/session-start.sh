#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 "${SCRIPT_DIR}/session-start.py" 2>/dev/null || python "${SCRIPT_DIR}/session-start.py"
