#!/bin/bash
# PreToolUse hook for Bash. Refuses commands that destroy work you cannot get back.
#
# Why it exists: an AI agent that is "cleaning up" will happily run
# `rm -rf` on the wrong folder or `git reset --hard` over an afternoon of
# uncommitted edits. Both have happened to real people, more than once.
# The settings file can deny a few exact strings, but a pattern check
# catches the variations.
#
# How it answers Claude Code: exit 0 lets the command run. Exit 2 blocks it,
# and whatever this script prints to stderr is shown to Claude as the reason.
#
# If you really mean it, run the command yourself in your own terminal.
# That is the point: the dangerous step should need your hands.

INPUT="$(cat)"

# Pull the command out of the JSON payload. jq is preferred; without it we
# scan the raw payload, which is cruder but still catches the patterns below.
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  CMD="$INPUT"
fi
[ -n "$CMD" ] || exit 0

block() {
  echo "Blocked by block-destructive.sh: $1" >&2
  echo "If this is really what you want, ask the user to run it in their own terminal." >&2
  exit 2
}

# rm with a recursive flag aimed at root, home, the parent folder, or everything.
# Each piece between ; & | ( ) and backticks is checked on its own, after quotes
# are stripped and wrapper words (sudo, env, command, xargs, bash -c ...) skipped.
# This is a best-effort tripwire for an honest agent's mistakes, not a security
# boundary: a determined command can always be written to slip past a pattern.
check_rm() {
  local piece="$1" word recursive=0 danger=0
  piece="$(printf '%s' "$piece" | tr -d "\"'{}")"
  set -f  # do not let the shell expand a literal * while we read the words
  # shellcheck disable=SC2086
  set -- $piece
  set +f
  while [ $# -gt 0 ]; do
    case "$1" in
      sudo | env | command | exec | nohup | time | xargs | builtin | -c | -*c) shift ;;
      bash | sh | zsh | dash) shift ;;
      *=*) shift ;;
      *) break ;;
    esac
  done
  [ "${1##*/}" = "rm" ] || return 1
  shift
  for word in "$@"; do
    case "$word" in
      --recursive) recursive=1 ;;
      --*) ;;
      -*[rR]*) recursive=1 ;;
    esac
    case "$word" in
      / | /\* | '~' | '~/' | '~/*' | '$HOME' | '$HOME/' | '$HOME/*' | .. | ../ | ../* | . | ./ | './*' | '*') danger=1 ;;
    esac
  done
  [ "$recursive" = 1 ] && [ "$danger" = 1 ]
}
while IFS= read -r piece; do
  check_rm "$piece" && block "recursive rm aimed at /, ~, \$HOME, .., . or *. That deletes far more than one project."
done <<EOF
$(printf '%s\n' "$CMD" | tr ';&|()`' '\n\n\n\n\n\n')
EOF

# find ... -delete starting from root or home wipes the same things rm -rf would.
printf '%s' "$CMD" | tr -d "\"'{}" | grep -Eq 'find[[:space:]]+(/|~|\$HOME)([[:space:]/]|$).*-delete' &&
  block "find -delete starting at / or your home folder. Point it at one project folder and preview with -print first."

# Git commands that throw away uncommitted work or rewrite shared history.
printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+reset[[:space:]](.*[[:space:]])?--hard' &&
  block "git reset --hard discards every uncommitted change. Commit or stash first, or use git restore on one file."
printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+clean[[:space:]](.*[[:space:]])?-[a-zA-Z]*f' &&
  block "git clean -f deletes untracked files for good. Run git clean -n to preview what it would remove."
printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+checkout[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$)' &&
  block "git checkout . throws away every unsaved edit in the folder."
printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+push([[:space:]].*)?[[:space:]](--force|-f)([[:space:]]|$)' &&
  block "force push overwrites the remote branch. Use --force-with-lease if you must, and never on main."
printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+branch[[:space:]](.*[[:space:]])?-D([[:space:]]|$)' &&
  block "git branch -D deletes a branch even if its work was never merged. Use -d, which refuses in that case."

# Database and disk commands with no undo.
printf '%s' "$CMD" | grep -Eiq '(drop[[:space:]]+(table|database|schema)|truncate[[:space:]]+table)' &&
  block "DROP or TRUNCATE deletes data permanently. Write a migration and back up first."
printf '%s' "$CMD" | grep -Eq '(^|[;&|[:space:]])(mkfs(\.[a-z0-9]+)?|dd[[:space:]]+if=)' &&
  block "disk-level write command (mkfs or dd)."
printf '%s' "$CMD" | grep -Eq 'chmod[[:space:]]+-R[[:space:]]+777' &&
  block "chmod -R 777 makes everything writable by everyone. Pick the exact permission you need."

# Piping a script from the internet straight into a shell runs code nobody read.
printf '%s' "$CMD" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh([[:space:]]|$)' &&
  block "curl | sh runs a script nobody has read. Download it, read it, then run it."

exit 0
