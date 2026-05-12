#!/usr/bin/env bash
# Stop hook. Best-effort and non-blocking: remind only when the current
# directory looks like a HayeOS project. This is not mandatory for tiny chats.
if [ -f ".hayeos.json" ]; then
  echo "Haye reminder: If this was a meaningful work session, consider closing with /haye:close so Haye memory remains aligned." >&2
fi
exit 0
