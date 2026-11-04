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

# Only format files inside the project Claude is working in. A file outside it
# (say, a repo you just cloned to look at) never gets a formatter run on it.
ROOT="${CLAUDE_PROJECT_DIR:-$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] || exit 0
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || exit 0
FILE_ABS="$(cd "$(dirname "$FILE")" && pwd -P)/$(basename "$FILE")"
case "$FILE_ABS" in "$ROOT"/*) ;; *) exit 0 ;; esac

# The project's own prettier, searched from the file up to the project root and
# no further. It must be the real prettier package (its bin points into
# node_modules/prettier/), so a planted executable named prettier is ignored.
# Otherwise fall back to a prettier you installed yourself on your PATH.
find_local_prettier() {
  local dir target
  dir="$(dirname "$FILE_ABS")"
  while :; do
    if [ -x "$dir/node_modules/.bin/prettier" ]; then
      target="$(cd "$dir/node_modules/.bin" && pwd -P)/$(readlink "$dir/node_modules/.bin/prettier" 2>/dev/null)"
      case "$target" in */node_modules/prettier/*) echo "$dir/node_modules/.bin/prettier"; return 0 ;; esac
    fi
    [ "$dir" = "$ROOT" ] && break
    dir="$(dirname "$dir")"
  done
  command -v prettier 2>/dev/null
}

case "$FILE" in
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.json | *.css | *.scss | *.html | *.md | *.yml | *.yaml)
    PRETTIER="$(find_local_prettier)"
    [ -n "$PRETTIER" ] && "$PRETTIER" --write --log-level warn "$FILE_ABS" >/dev/null 2>&1
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
