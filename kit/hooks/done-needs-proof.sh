#!/bin/bash
# Stop hook. Sends a reply back when it says the work is done, fixed or
# working, but nothing was run after the last file edit in this turn.
#
# Why it exists: the most common false "done" from an AI is a claim checked
# against the code it just wrote instead of against the running thing. The
# code reads right, the reply says "fixed", and the bug is still there the
# first time you open the page. One command after the last edit (the test,
# the script, the build, a curl to the endpoint) is the difference between
# "I believe it works" and "I saw it work".
#
# What counts as proof here is deliberately loose: any terminal command after
# the last edit. The hook cannot judge whether the check was a good one. You
# can, so read what was run before you believe the "done".
#
# It answers {"decision":"block","reason":...} once per reply. On the retry
# (stop_hook_active is true) it always lets the reply through, so it cannot loop.

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
_, tools = load_turn(data.get("transcript_path"))
if not msg or not tools:
    raise SystemExit(0)

CLAIM = re.compile(
    r"\b(it'?s (done|fixed|working)|(is|are|now) (done|fixed|working)|works now|"
    r"all (tests|checks) pass|tests pass|verified|fixed it|shipped|ready to (ship|merge|deploy))\b",
    re.I,
)
if not CLAIM.search(msg) or re.search(r"\bnot (yet )?(verified|tested|run)\b", msg, re.I):
    raise SystemExit(0)

EDITS = {"Write", "Edit", "MultiEdit", "NotebookEdit"}
last_edit = max((i for i, (name, _) in enumerate(tools) if name in EDITS), default=-1)
if last_edit < 0:
    raise SystemExit(0)
ran_after = any(name == "Bash" for name, _ in tools[last_edit + 1:])
if ran_after:
    raise SystemExit(0)

print(json.dumps({
    "decision": "block",
    "reason": (
        "Your reply says the work is done, but nothing was run after the last file edit. "
        "Run the thing (the test, the script, the build, or a request to the endpoint) and "
        "report what you actually saw. If it cannot be run here, say plainly that it is "
        "not verified and what the person should check."
    ),
}))
PY
