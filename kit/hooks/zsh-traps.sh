#!/bin/bash
# PreToolUse hook for Bash. On a Mac, Claude's terminal commands run in zsh
# (the macOS default shell), but AIs write bash. Three bash habits break in
# zsh in ways that fail silently or confusingly. This refuses them and says
# the fix. It does nothing when your shell is not zsh.
#
#   1. `for path in ...` or `path=...`: in zsh, $path IS your PATH. Every
#      command after it says "command not found".
#   2. `status=...`: $status is read-only in zsh, so the script dies there.
#   3. `for f in $files`: zsh does not split an unquoted variable on spaces,
#      so the loop runs once with the whole list as one item.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

SHELL_NAME="${ZSH_TRAPS_SHELL:-${SHELL##*/}}"
[ "$SHELL_NAME" = "zsh" ] || exit 0
INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$CMD" ] || exit 0

# Commands handed to bash or sh explicitly run in that shell, so bash rules apply.
case "$CMD" in bash\ * | sh\ * | */bash\ *) exit 0 ;; esac
# Drop quoted strings so words inside messages and python -c code do not count.
BARE="$(printf '%s' "$CMD" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"

if printf '%s' "$BARE" | grep -qE '(^|[;&|][[:space:]]*|(local|export|do|then)[[:space:]]+)(for +path +in\b|path=)'; then
  echo "Blocked by zsh-traps.sh: in zsh, \$path is tied to \$PATH, so this breaks every command after it." >&2
  echo "Use another name, like file or p." >&2
  exit 2
fi
if printf '%s' "$BARE" | grep -qE '(^|[;&|][[:space:]]*|(local|export|do|then)[[:space:]]+)status='; then
  echo "Blocked by zsh-traps.sh: \$status is read-only in zsh. Use another name, like rc or code." >&2
  exit 2
fi
if printf '%s' "$BARE" | grep -qE '(^|[;&|][[:space:]]*)for +[A-Za-z_][A-Za-z0-9_]* +in +\$[A-Za-z_{][A-Za-z0-9_}]* *(;|$|do\b)'; then
  echo "Blocked by zsh-traps.sh: zsh does not split \$var on spaces, so this loop runs once with the whole list." >&2
  echo "Use: printf '%s\n' \$var | while read -r item; do ...; done   or run it with bash -c '...'." >&2
  exit 2
fi
exit 0
