#!/usr/bin/env bash
# Reminds Claude to run /haye:close if a meaningful work session is ending
# without the memory being updated. Best-effort, never blocks.
if [ -f ".hayeos.json" ]; then
  echo "Haye reminder: if real work happened this session, run /haye:close before /clear or quitting so memory/checkpoint stays current." >&2
fi
exit 0
