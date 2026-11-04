#!/bin/bash
# PreToolUse hook for Bash. Refuses a polling loop (while or until, with a
# sleep inside) that has no way to stop on its own.
#
# Why it exists: AIs wait for a deploy or a server with a loop like
#   until curl -s localhost:3000; do sleep 5; done
# If the check can never pass (a typo, the wrong port, the server crashed),
# that loop runs forever in the background, burning time and API calls long
# after anyone remembers it. A cap costs one line:
#   for i in $(seq 1 60); do curl -s localhost:3000 && break; sleep 5; done
#
# Escape hatch for a loop that really must run forever: put
# WAIT_LOOP_OK='reason' in the command.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$CMD" ] || exit 0
case "$CMD" in *WAIT_LOOP_OK=*) exit 0 ;; esac

# Heredoc bodies are text handed to another program, not loops the shell runs.
if command -v perl >/dev/null 2>&1; then
  CMD="$(printf '%s\n' "$CMD" | perl -0pe 's/<<-?\s*([\x27"]?)(\w+)\1[^\n]*\n.*?\n\s*\2[ \t]*(?=\n|$)//gs')"
fi

printf '%s' "$CMD" | grep -qE '\b(until|while)\b' || exit 0
printf '%s' "$CMD" | grep -qE '\bsleep\b' || exit 0
# Real loop syntax, not the words inside a commit message.
printf '%s' "$CMD" | tr '\n' ';' | grep -qE '\b(until|while)\b[^;]*;[[:space:];]*do\b' || exit 0

# A loop over input lines ends when the input does.
printf '%s' "$CMD" | grep -qE '\bwhile +(IFS=[^ ]* +)?read\b' && exit 0

# Bounded: a counter, an arithmetic limit, a timeout wrapper, or $SECONDS.
if printf '%s' "$CMD" | grep -qE '\bfor [A-Za-z_][A-Za-z0-9_]* in \$\(seq|\(\( *[A-Za-z_]+ *(<|<=|>|>=|\+\+|\+=)|-(lt|le|gt|ge) +[0-9]|\b(g?timeout) +[0-9]|\$SECONDS'; then
  exit 0
fi

echo "Blocked by no-endless-wait.sh: this polling loop has no cap. If its check can never pass, it runs forever." >&2
echo "Bound it, for example: for i in \$(seq 1 60); do <check> && break; sleep 5; done" >&2
echo "If it truly must run forever, add WAIT_LOOP_OK='<reason>' to the command." >&2
exit 2
