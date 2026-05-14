#!/usr/bin/env python3
"""HayeOS SessionStart hook - Python implementation.

Called by hooks/session-start (bash) when python is available, or directly
by run-hook.cmd on Windows via hooks/session-start.py.

Emits the using-hayeos skill content as Claude Code's SessionStart hook
expects: hookSpecificOutput.additionalContext (nested) for Claude Code,
additional_context (snake_case, top-level) for Cursor, additionalContext
(camelCase, top-level) for Copilot CLI and others.
"""

import json
import os
import sys
from pathlib import Path


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    plugin_root = script_dir.parent
    skill_path = plugin_root / "skills" / "using-hayeos" / "SKILL.md"

    try:
        content = skill_path.read_text(encoding="utf-8")
    except Exception as exc:
        content = f"Error reading using-hayeos skill: {exc}"

    session_context = (
        "<EXTREMELY_IMPORTANT>\n"
        "You have HayeOS active in this session.\n\n"
        "**Below is the full content of your 'haye:using-hayeos' skill - "
        "your introduction to HayeOS workflow and discipline. "
        "For all other skills, use the 'Skill' tool:**\n\n"
        f"{content}\n"
        "</EXTREMELY_IMPORTANT>"
    )

    # Emit correct JSON shape for each platform
    if os.environ.get("CURSOR_PLUGIN_ROOT"):
        payload = {"additional_context": session_context}
    elif os.environ.get("CLAUDE_PLUGIN_ROOT") and not os.environ.get("COPILOT_CLI"):
        payload = {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": session_context,
            }
        }
    else:
        payload = {"additionalContext": session_context}

    print(json.dumps(payload))
    return 0


if __name__ == "__main__":
    sys.exit(main())
