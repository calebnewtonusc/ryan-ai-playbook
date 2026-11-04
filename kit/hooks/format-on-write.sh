#!/bin/bash
# PostToolUse hook for Write and Edit. Formats the file Claude just wrote.
#
# Why it exists: AI-written code drifts in style from file to file (quotes,
# semicolons, indentation), which makes every diff noisy and every review
# harder. Running the project's own formatter after each write keeps the
# style consistent without anyone thinking about it.
#
# It only uses a formatter the project already installed (node_modules/.bin)
# or one on your PATH. It never downloads anything, and it never fails the
# write: if no formatter is found, it quietly does nothing.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)"
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

# Walk up from the file to find the project's own prettier, if it has one.
find_local_prettier() {
  local dir
  dir="$(cd "$(dirname "$FILE")" && pwd)"
  while [ "$dir" != "/" ]; do
    if [ -x "$dir/node_modules/.bin/prettier" ]; then
      echo "$dir/node_modules/.bin/prettier"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  command -v prettier 2>/dev/null
}

case "$FILE" in
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.json | *.css | *.scss | *.html | *.md | *.yml | *.yaml)
    PRETTIER="$(find_local_prettier)"
    [ -n "$PRETTIER" ] && "$PRETTIER" --write --log-level warn "$FILE" >/dev/null 2>&1
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format --quiet "$FILE" >/dev/null 2>&1
    elif command -v black >/dev/null 2>&1; then
      black --quiet "$FILE" >/dev/null 2>&1
    fi
    ;;
esac

# A formatter problem should never block work, so always succeed.
exit 0
