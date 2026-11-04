#!/bin/bash
# PostToolUse hook for Write and Edit. When Claude writes a prose file (.md,
# .mdx, .txt), it reads the whole file and points out AI writing tells with
# line numbers: em dashes, the words people associate with machine writing,
# "it's not X, it's Y" reveals, and recap endings like "In conclusion".
#
# Why it exists: stop-slop-check.sh only reads Claude's chat replies, but the
# writing that matters is usually a file: the README, the announcement, the
# about page. Those go out under your name.
#
# It never changes the file. It sends Claude the list so it fixes the lines
# before handing the file over. Code and config files are skipped, and so are
# LICENSE and CHANGELOG files.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0
case "$FILE" in
  *.md | *.mdx | *.txt) ;;
  *) exit 0 ;;
esac
case "$(basename "$FILE" | tr 'a-z' 'A-Z')" in
  LICENSE* | CHANGELOG* | NOTICE*) exit 0 ;;
esac
case "$FILE" in */node_modules/* | */.git/*) exit 0 ;; esac

# Only the text this write added, so an old line elsewhere in the file does not
# fire again on every later edit. Line numbers are within the written text.
NEW_TEXT="$(printf '%s' "$INPUT" | jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits // [] | .[].new_string)] | map(select(. != null)) | join("\n")' 2>/dev/null)"
[ -n "$NEW_TEXT" ] || exit 0
SCAN="$(mktemp)"
trap 'rm -f "$SCAN"' EXIT
printf '%s\n' "$NEW_TEXT" >"$SCAN"

EM_DASH="$(printf '\xe2\x80\x94')"
WORDS='delve|delves|delving|tapestry|testament to|game[- ]changer|cutting[- ]edge|seamless|seamlessly|leverage|leveraging|utilize|robust|streamline|empower|supercharge|unleash|elevate your|in today.s fast[- ]paced|it.s worth noting'
REVEAL="(it'?s|this is|that'?s) not (just |only |about )?[^.,;]{1,40}, (it'?s|but)|isn'?t (just |only )?about [^.,;]{1,40}, it'?s|^(in conclusion|ultimately|overall),"

FOUND="$( {
  grep -n "$EM_DASH" "$SCAN" | cut -d: -f1 | sed 's/$/: em dash/'
  grep -noiE "\\b($WORDS)\\b" "$SCAN" | sed -E 's/^([0-9]+):(.*)$/\1: "\2"/'
  grep -noiE "$REVEAL" "$SCAN" | cut -d: -f1 | sed 's/$/: not-X-but-Y or recap phrasing/'
} | sort -n -t: -k1 | head -n 15 | paste -sd';' -)"
[ -n "$FOUND" ] || exit 0

REASON="prose-file-check.sh found AI writing tells in $FILE (line: problem): $FOUND. Rewrite those lines in plain words with the same meaning. A line that quotes a word on purpose (a style guide listing banned words) can stay: say so. Do not touch lines the person wrote themselves without asking." \
  jq -n '{decision: "block", reason: env.REASON}'
exit 0
