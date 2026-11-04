#!/bin/bash
# Stop hook. Sends a reply back when it claims it read everything ("read all
# the files", "went through every page", "the whole file") while this turn
# only read part of something: a Read with a line limit, or head, tail,
# sed -n or cut in the terminal.
#
# Why it exists: AIs skim long files to save context, then summarize as if
# they read them. The part they skipped is usually the part you needed (the
# last section, the edge case at line 900). The fix is either to read the rest
# or to say exactly which parts were not read.
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
_, tools = load_turn(data.get("transcript_path"))
if not msg or not tools:
    raise SystemExit(0)
CLAIM = re.compile(
    r"\b(read (all|every|each|everything|the (whole|entire|full))|went through (all|every|each|everything)|"
    r"every (line|page|file)|cover(ed)? everything)\b",
    re.I,
)
if not CLAIM.search(msg):
    raise SystemExit(0)
partial = []
for name, inp in tools:
    if name == "Read" and (inp.get("limit") or inp.get("offset")):
        partial.append(f"Read {inp.get('file_path', '?')} (offset {inp.get('offset', 0)}, limit {inp.get('limit', 'none')})")
    elif name == "Bash":
        cmd = inp.get("command", "")
        # head or tail after a pipe trims command output, not a document, so it does not count.
        if re.search(r"(^|[;&]\s*)(head|tail)\s+(-n\s*)?-?\d+\s+\S|(^|[|;&\s])sed -n\s+'?\d|(^|[|;&\s])cut -c", cmd):
            partial.append("Bash: " + " ".join(cmd.split())[:100])
if not partial:
    raise SystemExit(0)
print(json.dumps({
    "decision": "block",
    "reason": (
        "Your reply says everything was read, but this turn only read part of: " +
        "; ".join(partial[:6]) +
        ". Read the rest, or say exactly which parts you did not read."
    ),
}))
PY
