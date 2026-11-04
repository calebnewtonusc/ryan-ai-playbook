#!/bin/bash
# PreToolUse hook for Bash. Refuses staging or committing a secrets file:
# .env files (not .env.example), private keys (.pem, .key, id_rsa), and
# credential JSON files.
#
# Why it exists: protect-secrets.sh keeps keys out of source code, and this
# keeps the file that holds them out of git. Once a .env is pushed, deleting
# it later does not help: it stays in the history, and bots scan public repos
# for keys within minutes.
#
# It checks the files named in `git add`, and for `git commit` it reads what
# is already staged in the folder the command runs in.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$CMD" ] || exit 0
case "$CMD" in *git*) ;; *) exit 0 ;; esac

SECRET='(^|/)(\.env(\.[A-Za-z0-9_-]+)?|[^/]*\.pem|[^/]*\.key|id_rsa|id_ed25519|credentials\.json|service-account[^/]*\.json)$'
SAFE='(^|/)\.env\.(example|sample|template)$'

block() {
  echo "Blocked by no-env-commit.sh: $1 looks like a secrets file. Keep it out of git." >&2
  echo "Add it to .gitignore, and commit a .env.example with placeholder values instead." >&2
  exit 2
}

# Files named after `git add`. set -f stops a * in the command from expanding here.
set -f
ADD_ARGS="$(printf '%s\n' "$CMD" | tr ';&|' '\n\n\n' | sed -nE 's/^[[:space:]]*git([[:space:]]+-[Cc][[:space:]]+[^[:space:]]+)*[[:space:]]+add[[:space:]]+//p')"
if [ -n "$ADD_ARGS" ]; then
  for word in $ADD_ARGS; do
    word="${word%\"}"; word="${word#\"}"; word="${word%\'}"; word="${word#\'}"
    printf '%s' "$word" | grep -qE "$SAFE" && continue
    printf '%s' "$word" | grep -qE "$SECRET" && block "$word"
  done
fi

# Files already staged, when committing.
if printf '%s' "$CMD" | grep -qE '\bgit\b.*\bcommit\b'; then
  DIR="${CWD:-$PWD}"
  STAGED="$(git -C "$DIR" diff --cached --name-only 2>/dev/null)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '%s' "$f" | grep -qE "$SAFE" && continue
    printf '%s' "$f" | grep -qE "$SECRET" && block "$f (staged)"
  done <<<"$STAGED"
fi
exit 0
