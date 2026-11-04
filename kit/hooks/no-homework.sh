#!/bin/bash
# Stop hook. Sends a reply back when it ends by handing you a command to run
# that the AI could have run itself ("Run this to see it: npm run build").
#
# Why it exists: Claude has a terminal. A command at the end of a reply is
# usually a sign it stopped one step early and passed the boring part to you.
# It does not fire when you asked to learn the command ("how do I", "show me
# the command", "teach me"), since then the command is the answer, and it
# skips replies with "BLOCKED:" (a password or sign-in only you can do).
#
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
prompt, _ = load_turn(data.get("transcript_path"))
if not msg or "BLOCKED:" in msg:
    raise SystemExit(0)
if re.search(r"\b(how (do|can|would) (i|you|we)|how to|teach me|show me (the|how)|what command|explain)\b", prompt or "", re.I):
    raise SystemExit(0)

tail = msg[-900:]
has_block = re.search(r"```(bash|sh|zsh|shell|console)?\s*\n", tail, re.I)
asks = re.search(
    r"\b(run (this|these|the following|it)|you('ll| will) need to (run|install)|paste (this|it) into|"
    r"in (your|the) terminal|then run|to (see|test|try) it,? run)\b",
    tail, re.I,
)
if not (has_block and asks):
    raise SystemExit(0)
print(json.dumps({
    "decision": "block",
    "reason": (
        "Your reply ends by asking the person to run a command. Run it yourself and report "
        "what happened. If it needs something only they have (a password, a sign-in, a "
        "physical step), write BLOCKED: and that one step."
    ),
}))
PY
