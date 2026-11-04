#!/bin/bash
# PreToolUse hook for Write, Edit and MultiEdit. Two jobs:
#
#   1. Blocks writing something that looks like a real secret (an API key,
#      a private key, a live payment key) into a normal source file.
#      Secrets belong in .env, which git ignores, and the code reads them
#      with process.env.NAME.
#   2. When Claude writes a real .env file, reminds it to check that
#      .gitignore covers it before anything gets committed.
#
# Why it exists: the most common beginner security mistake is pasting a key
# straight into code "just to test", then pushing the repo. Bots scan GitHub
# for keys and can run up a bill on your account within the hour.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -n "$FILE" ] || exit 0
NAME="$(basename "$FILE")"

# Everything the tool is about to write, across Write, Edit and MultiEdit.
CONTENT="$(printf '%s' "$INPUT" | jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits // [] | .[].new_string)] | map(select(. != null)) | join("\n")' 2>/dev/null)"

case "$NAME" in
  .env.example | .env.sample | .env.template)
    # These get committed on purpose, so they must hold placeholders only.
    ;;
  .env | .env.* | *.env)
    # A real .env file is where secrets are supposed to go. Allow, with a reminder.
    jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: "Writing a real .env file. Before any commit, confirm .gitignore lists .env so this file never reaches GitHub."}}'
    exit 0
    ;;
esac

# Patterns that are almost never anything but a real credential.
PATTERNS='(sk-[A-Za-z0-9_-]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|sk_live_[A-Za-z0-9]{16,}|rk_live_[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'

if printf '%s' "$CONTENT" | grep -Eq "$PATTERNS"; then
  echo "Blocked by protect-secrets.sh: $NAME looks like it is getting a real API key or private key." >&2
  echo "Put the value in .env (make sure .gitignore lists it), read it in code with process.env.NAME," >&2
  echo "and document the variable name with a fake value in .env.example." >&2
  exit 2
fi

exit 0
