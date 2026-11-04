#!/bin/bash
# Stop hook. When a reply contains a draft for the person to send (a quoted
# block, lines starting with "> ") that has numbers in it, the reply must say
# where those numbers came from.
#
# Why it exists: an AI fills a draft email or post with plausible numbers
# ("about 100 people", "a 40% jump") that it estimated or half-remembered. Once
# you send it under your name, the wrong number is yours. A source next to
# each number (a link, a file, "from the signup sheet") lets you check it in
# seconds, and a [NEED: number] marker is always better than a guess.
#
# Passes when the reply mentions a source, a link, or a [NEED: marker.
# Once per reply, never on the retry.

INPUT="$(cat)"
command -v python3 >/dev/null 2>&1 || exit 0
HOOK_INPUT="$INPUT" exec python3 - <<'PY'
import json, os, re

try:
    data = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except ValueError:
    raise SystemExit(0)
if data.get("stop_hook_active"):
    raise SystemExit(0)


def load_turn(path):
    """Return (last user prompt, [(tool name, tool input)]) for this turn."""
    entries = []
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                try:
                    entries.append(json.loads(line))
                except ValueError:
                    pass
    except (OSError, TypeError):
        return "", []
    start, prompt = 0, ""
    for i, e in enumerate(entries):
        if e.get("type") != "user":
            continue
        content = (e.get("message") or {}).get("content")
        if isinstance(content, str):
            start, prompt = i, content
        elif isinstance(content, list) and not any(
            isinstance(b, dict) and b.get("type") == "tool_result" for b in content
        ):
            text = " ".join(
                b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"
            )
            if text:
                start, prompt = i, text
    tools = []
    for e in entries[start + 1:]:
        if e.get("type") != "assistant":
            continue
        for b in (e.get("message") or {}).get("content") or []:
            if isinstance(b, dict) and b.get("type") == "tool_use":
                tools.append((b.get("name", ""), b.get("input") or {}))
    # Claude Code puts system notes inside the prompt text. Only the person's words count.
    prompt = re.sub(r"<(system-reminder|command-[a-z-]+|local-command-[a-z-]+)>.*?</\1>", "", prompt, flags=re.S)
    return prompt, tools


msg = data.get("last_assistant_message") or ""
if not msg:
    raise SystemExit(0)
quoted = "\n".join(line for line in msg.splitlines() if line.lstrip().startswith(">"))
if not re.search(r"(\$\s?\d|\d+(\.\d+)?\s?%|\b\d{2,}\b)", quoted):
    raise SystemExit(0)
outside = "\n".join(line for line in msg.splitlines() if not line.lstrip().startswith(">"))
if re.search(r"\b(source|sources|sourced|according to|counted|from the)\b|https?://|\[NEED", outside, re.I):
    raise SystemExit(0)
print(json.dumps({
    "decision": "block",
    "reason": (
        "The draft in your reply has numbers but the reply never says where they came from. "
        "Add the source for each one (a link, a file, a count you ran), or swap any number "
        "you cannot source for a [NEED: ...] marker."
    ),
}))
PY
