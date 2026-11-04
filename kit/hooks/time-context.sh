#!/bin/bash
# UserPromptSubmit hook. Tells Claude the current date and time with every
# message you send.
#
# Why it exists: Claude is told the date once, when a session starts. A
# session left open overnight still thinks it is yesterday, so "due in 3
# days", "this week" and dates written into files come out wrong. One line
# per message fixes it. Never blocks.

cat >/dev/null
echo "Current local time: $(date '+%A %B %-d %Y, %-I:%M %p %Z')."
exit 0
