#!/bin/bash
# UserPromptSubmit hook. When your message asks Claude to build, fix or change
# something, it adds a short instruction: before building, name what result
# would prove the approach wrong, and for anything non-trivial, ask you for a
# one-line prediction of what will happen first. At the end, compare.
#
# Why it exists: this is the habit that keeps you the engineer instead of
# the person who presses enter. When you predict before the AI runs, a wrong
# prediction is a free lesson, and a right one means you actually understand
# the system. When the AI names its own "this would prove me wrong" check, it
# stops building on a guess.
#
# It adds context only and never blocks. Questions and small talk are skipped.
# Turn it off for a session by starting your message with "no predict:".

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)"
[ -n "$PROMPT" ] || exit 0
case "$PROMPT" in "no predict:"* | "No predict:"*) exit 0 ;; esac
# Short asks ("fix the typo") skip it: a prediction is worth it on real changes.
[ "$(printf '%s' "$PROMPT" | wc -w)" -ge 12 ] || exit 0
printf '%s' "$PROMPT" | grep -qiE '\b(build|make|add|create|fix|implement|change|refactor|write|set up|setup|migrate|deploy|redesign|rewrite)\b' || exit 0

cat <<'MSG'
Before you build: state in one sentence what result would show this approach is wrong, and check that first.
If the change is more than a few lines and the person has not said what they expect, ask them for a one-line prediction (what will change, what might break) before you start. Do not ask for tiny edits.
When you finish, put their prediction next to what actually happened, so they can see where their mental model was right or off.
MSG
exit 0
