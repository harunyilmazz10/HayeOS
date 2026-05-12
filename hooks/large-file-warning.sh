#!/usr/bin/env bash
# PreToolUse Read hook. Non-blocking: adds model context for very large files
# or raw vault files, and stays silent when there is nothing useful to add.
set -euo pipefail

input="$(cat)"
path="$(printf '%s' "$input" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path","") or d.get("tool_input",{}).get("path",""))' 2>/dev/null || true)"

warning=""
if [ -n "$path" ]; then
  if [ -f "$path" ]; then
    size="$(stat -c %s "$path" 2>/dev/null || stat -f %z "$path" 2>/dev/null || echo 0)"
    if [ "${size:-0}" -gt 200000 ]; then
      warning="Haye warning: this file is very large. Prefer targeted reads, grep-style search, head/tail style inspection, or a context-pack summary instead of loading the whole file."
    fi
  fi
  case "$path" in
    */08-raw/*)
      warning="Haye warning: this file is under 08-raw/. Prefer summarizing it through /haye:close or the ingest-session skill instead of loading the whole raw file."
      ;;
  esac
fi

if [ -n "$warning" ]; then
  WARNING="$warning" python3 - <<'PY'
import json
import os

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "additionalContext": os.environ["WARNING"],
    }
}, ensure_ascii=False))
PY
fi

exit 0
