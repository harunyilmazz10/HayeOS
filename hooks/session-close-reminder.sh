#!/usr/bin/env bash
# Session Stop hook
# 1. Reminds about /haye:close if vault exists and session-close marker not present
# 2. Best-effort fake completion warning if recent build/test fails are visible

set -uo pipefail

# Best-effort and non-blocking: remind only when the current directory looks like
# a HayeOS project. This is not mandatory for a tiny interaction.

# Look for vault sibling in current working directory
vault=""
for d in *_obs; do
  if [ -d "$d" ]; then
    vault="$d"
    break
  fi
done

if [ -z "$vault" ]; then
  exit 0  # no vault, nothing to do
fi

# Best-effort: check if last session was marked closed
close_marker="$vault/05-sessions/latest-checkpoint.md"
if [ ! -f "$close_marker" ]; then
  echo "HayeOS reminder: vault exists at $vault but no recent checkpoint found." >&2
  echo "If this is end of meaningful work session, consider running /haye:close." >&2
fi

# Always exit 0 so we never block stop
exit 0
