#!/bin/bash
# PreToolUse hook for Bash. Refuses `git add -A`, `git add .`, `git add --all`
# and `git commit -a`.
#
# Why it exists: those commands stage everything in the folder, including a
# .env file full of passwords, a 400 MB video, or a half-finished experiment.
# Once a secret is pushed to GitHub, deleting it later does not help: it is in
# the history and bots scrape public repos for keys within minutes.
# Staging files by name is slower by five seconds and cannot do that.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

INPUT="$(cat)"
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  CMD="$INPUT"
fi
[ -n "$CMD" ] || exit 0

# Bulk forms: -A, -u, -Au and other combined short flags with A or u, --all,
# --update, ., ./, *, and the repo-root pathspecs :/ and :(top).
if printf '%s' "$CMD" | tr -d "\"'" | grep -Eq 'git[[:space:]]+add([[:space:]].*)?[[:space:]](-[a-zA-Z]*[Au][a-zA-Z]*|--all|--update|\.|\./|\*|:/|:\(top\))([[:space:]]|;|&|\||$)'; then
  echo "Blocked by no-git-add-all.sh: stage files by name, for example: git add src/app.ts README.md" >&2
  echo "Run git status first to see what changed, and leave out anything you did not mean to touch." >&2
  exit 2
fi

if printf '%s' "$CMD" | tr -d "\"'" | grep -Eq 'git[[:space:]]+commit([[:space:]].*)?[[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|;|&|\||$)'; then
  echo "Blocked by no-git-add-all.sh: git commit -a commits every modified file. Add files by name, then commit." >&2
  exit 2
fi

exit 0
