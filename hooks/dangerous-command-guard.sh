#!/usr/bin/env bash
input=$(cat)
case "$input" in
  *"rm -rf"*|*"DROP DATABASE"*|*"prisma migrate reset"*|*"docker compose down -v"*)
    echo "Haye guard: destructive command detected. Ask user for explicit approval." >&2
    exit 2
    ;;
esac
exit 0
