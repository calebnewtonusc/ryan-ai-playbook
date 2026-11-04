#!/bin/bash
# Stop hook. Runs when Claude finishes a reply and checks the reply for the
# most recognizable AI writing tells: em dashes and a short list of words
# almost nobody uses when writing by hand.
#
# Why it exists: if you let them through, they end up in your emails, your
# church announcements and your site copy, and readers notice. A rule in
# CLAUDE.md asks nicely. This hook checks every reply, which is what makes the
# rule stick.
#
# When it finds something it answers {"decision":"block","reason":...}, which
# sends Claude back to rewrite the reply. It only does that once per reply
# (stop_hook_active is true on the retry), so it can never loop forever.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

# Second pass after a rewrite: let it through no matter what.
[ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

MSG="$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // empty')"

# Older Claude Code versions do not send last_assistant_message. Fall back to
# the transcript file and read the assistant text near its end.
if [ -z "$MSG" ]; then
  TP="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')"
  if [ -n "$TP" ] && [ -f "$TP" ]; then
    MSG="$(tail -n 40 "$TP" | jq -rR 'fromjson? | select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null | tail -c 20000)"
  fi
fi
[ -n "$MSG" ] || exit 0

# The em dash character, written as bytes so this file itself contains none.
EM_DASH="$(printf '\xe2\x80\x94')"

PROBLEMS=""
case "$MSG" in
  *"$EM_DASH"*) PROBLEMS="em dashes (use a comma, colon or period instead)" ;;
esac

# Edit this list to taste. Keep it short: every word here is one people
# associate with machine writing, so a false alarm is rare.
WORDS='delve|delves|delving|tapestry|testament to|game[- ]changer|cutting[- ]edge|seamless|seamlessly|leverage|leveraging|supercharge|unleash|elevate your|in today.s fast[- ]paced'
FOUND="$(printf '%s' "$MSG" | grep -oiE "\\b($WORDS)\\b" | tr 'A-Z' 'a-z' | sort -u | paste -sd, -)"
if [ -n "$FOUND" ]; then
  [ -n "$PROBLEMS" ] && PROBLEMS="$PROBLEMS; "
  PROBLEMS="${PROBLEMS}AI-sounding words: $FOUND"
fi

[ -n "$PROBLEMS" ] || exit 0

REASON="Your last reply has $PROBLEMS. Rewrite it in plain words with the same content." \
  jq -n '{decision: "block", reason: env.REASON}'
exit 0
