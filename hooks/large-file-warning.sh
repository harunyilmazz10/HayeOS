#!/usr/bin/env bash
# Warns Claude when about to read very large files (likely raw logs / 08-raw/*).
# Input on stdin is the tool-use JSON from Claude Code.
input=$(cat)
path=$(echo "$input" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path","") or d.get("tool_input",{}).get("path",""))' 2>/dev/null)
if [ -n "$path" ] && [ -f "$path" ]; then
  size=$(stat -c %s "$path" 2>/dev/null || stat -f %z "$path" 2>/dev/null || echo 0)
  if [ "$size" -gt 200000 ]; then
    echo "Haye warning: $path is $size bytes. Prefer head/tail/grep or a context-pack summary over loading the whole file." >&2
  fi
  case "$path" in
    */08-raw/*)
      echo "Haye warning: $path is under 08-raw/. Summarize via /haye:close or ingest-session skill instead of reading raw." >&2
      ;;
  esac
fi
exit 0
