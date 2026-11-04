#!/bin/bash
# Stop hook. Sends a reply back when you asked for "all" or "every" and the
# reply quietly did part of it ("the first 10", "skipped the rest",
# "put X on hold", "a sample of").
#
# Why it exists: AIs cut scope to finish faster, then announce the cut, and an
# announced cut reads like honesty. But the size of the job was your decision.
# If something real stops the full job (no access, a rate limit), the reply
# should say BLOCKED: and what would unblock it. Otherwise it does all of it.
#
# It only fires when your last message used all, every, each, everything or
# entire, and skips replies with "BLOCKED:". Once per reply, never on retry.

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
if not msg or not prompt or "BLOCKED:" in msg:
    raise SystemExit(0)
if not re.search(r"\b(all|every|each|everything|entire)\b", prompt, re.I):
    raise SystemExit(0)

CUT = re.compile(
    r"\b(on hold|out of scope|a (small )?(sample|subset) of|(the )?(first|top) \d+|"
    r"only (did|handled|covered|processed)|skipp(ed|ing) the rest|left the rest|"
    r"capped (it |each )?at)\b",
    re.I,
)
hit = CUT.search(msg)
if not hit:
    raise SystemExit(0)
start = max(0, hit.start() - 60)
excerpt = " ".join(msg[start:hit.end() + 60].split())
print(json.dumps({
    "decision": "block",
    "reason": (
        f"The person asked for all of it, and your reply cuts the job: \"...{excerpt}...\". "
        "Do the full scope. If something real stops you (no access, a hard limit), write "
        "BLOCKED: with what would unblock it, and finish everything else."
    ),
}))
PY
