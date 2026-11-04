#!/bin/bash
# Stop hook. Checks every file link in the reply, like [notes](docs/plan.md)
# or [app.ts:42](src/app.ts:42), and sends the reply back if a linked file
# does not exist.
#
# Why it exists: an AI that changed folders mid-session writes links relative
# to the wrong place, or links a file it meant to create and never did. You
# click, get "file not found", and stop trusting the rest of the reply.
#
# Web links (http, https, mailto) and #anchors are not checked. Relative paths
# are checked against the session folder. Once per reply, never on retry.

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
from urllib.parse import unquote

cwd = data.get("cwd") or os.getcwd()
text = re.sub(r"```.*?```", "", msg, flags=re.S)
missing = []
for target in re.findall(r"\]\((\S+?)\)(?=\s|$|[.,;:!?])", text):
    if re.match(r"^(https?:|mailto:|#|data:)", target, re.I):
        continue
    path = unquote(target.split("#", 1)[0])
    path = re.sub(r"(:\d+){1,2}(-\d+)?$", "", path)
    if not path:
        continue
    full = os.path.expanduser(path)
    if not os.path.isabs(full):
        full = os.path.join(cwd, full)
    if not os.path.exists(full):
        missing.append(target)
if not missing:
    raise SystemExit(0)
print(json.dumps({
    "decision": "block",
    "reason": (
        "These file links in your reply point at nothing: " + ", ".join(missing[:8]) +
        ". Fix each path (relative to the session folder, or absolute), or create the file "
        "if you meant to and did not."
    ),
}))
PY
