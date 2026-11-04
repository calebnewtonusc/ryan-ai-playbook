#!/bin/bash
# PostToolUse hook for Write and Edit. Formats the file Claude just wrote.
#
# Why it exists: AI-written code drifts in style from file to file (quotes,
# semicolons, indentation), which makes every diff noisy and every review
# harder. Running the project's own formatter after each write keeps the
# style consistent without anyone thinking about it.
#
# It only uses a formatter you installed yourself on your PATH. It never downloads anything, and it never fails the
# write: if no formatter is found, it quietly does nothing.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)"
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

# Only format files inside the project Claude is working in. A file outside it
# (say, a repo you just cloned to look at) never gets a formatter run on it.
ROOT="${CLAUDE_PROJECT_DIR:-$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] || exit 0
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || exit 0
FILE_ABS="$(cd "$(dirname "$FILE")" && pwd -P)/$(basename "$FILE")"
case "$FILE_ABS" in "$ROOT"/*) ;; *) exit 0 ;; esac

# Which prettier runs: only one YOU installed on your PATH (npm install -g
# prettier), never a file from inside the repo. A repo you cloned could ship
# its own "prettier" or a config that loads plugins, and either would run code
# you never read. Project config (.prettierrc and its plugins) is only used for
# folders you list, one per line, in ~/.claude/trusted-format-dirs. Everywhere
# else prettier runs with --no-config, so it formats with defaults and loads
# nothing from the repo.
PRETTIER="$(command -v prettier 2>/dev/null)"
CONFIG_FLAGS="--no-config --no-editorconfig"
TRUSTED_LIST="$HOME/.claude/trusted-format-dirs"
if [ -f "$TRUSTED_LIST" ] && grep -Fxq "$ROOT" "$TRUSTED_LIST"; then
  CONFIG_FLAGS=""
fi

case "$FILE" in
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.json | *.css | *.scss | *.html | *.md | *.yml | *.yaml)
    # shellcheck disable=SC2086
    [ -n "$PRETTIER" ] && "$PRETTIER" $CONFIG_FLAGS --write --log-level warn "$FILE_ABS" >/dev/null 2>&1
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format --quiet "$FILE_ABS" >/dev/null 2>&1
    elif command -v black >/dev/null 2>&1; then
      black --quiet "$FILE_ABS" >/dev/null 2>&1
    fi
    ;;
esac

# A formatter problem should never block work, so always succeed.
exit 0
