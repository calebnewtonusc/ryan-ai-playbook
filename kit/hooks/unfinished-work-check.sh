#!/bin/bash
# Stop hook. Sends a reply back when it ends by listing work it left undone
# in its own lane ("haven't run the tests yet", "still need to wire up the
# form", "TODO: deploy") without saying why it stopped.
#
# Why it exists: an AI that stops halfway and describes the rest as next
# steps hands you the unfinished part, and it reads like a summary, so it is
# easy to miss. Either the work gets finished, or the reply says BLOCKED: and
# names the one thing only you can do (a password, a decision, a click).
#
# It skips replies that contain "BLOCKED:" or end with a real question to you.
# It answers {"decision":"block"} once per reply, never on the retry.

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
if not msg or "BLOCKED:" in msg:
    raise SystemExit(0)
if msg.rstrip().endswith("?"):
    raise SystemExit(0)

LEFT = re.compile(
    r"(\b(haven'?t|have not|didn'?t|did not) (yet )?(run|test(ed)?|deploy(ed)?|finish(ed)?|wire[d]? up|hook(ed)? up|implement(ed)?)\b"
    r"|\bstill (need|needs|have|has) to\b|\bleft to do\b|\bnot (done|finished|wired up|hooked up) yet\b"
    r"|^\s*(TODO|Remaining)\s*:|\bnext,? I'?ll\b)",
    re.I | re.M,
)
hit = LEFT.search(msg)
if not hit:
    raise SystemExit(0)
start = max(0, hit.start() - 60)
excerpt = " ".join(msg[start:hit.end() + 80].split())
print(json.dumps({
    "decision": "block",
    "reason": (
        f"Your reply names work you left undone: \"...{excerpt}...\". Finish it now if it is "
        "in your lane. If it truly needs the person (a password, a decision, a physical "
        "step), write BLOCKED: and that one thing, and say what you already finished."
    ),
}))
PY
