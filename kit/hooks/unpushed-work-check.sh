#!/bin/bash
# Stop hook. When Claude finishes a reply, it checks the project folder for
# work that is not saved to GitHub yet: uncommitted changes, or commits that
# were never pushed. If it finds some, it shows you a one-line reminder.
#
# Why it exists: a laptop dies, a folder gets deleted, an experiment
# overwrites the version that worked. Work that only lives on your machine is
# one mistake from gone. When to commit is your call, so this reminds you and
# never blocks. It is silent when everything is saved.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0
DIR="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
DIR="${DIR:-$PWD}"
git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
TOP="$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)"
# A git repo at your home folder is a dotfiles repo, where everything looks changed.
[ "$TOP" = "$HOME" ] && exit 0

CHANGED="$(git -C "$DIR" status --porcelain 2>/dev/null | grep -c .)"
if git -C "$DIR" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
  AHEAD="$(git -C "$DIR" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)"
elif git -C "$DIR" rev-parse --verify -q HEAD >/dev/null 2>&1; then
  # Never pushed: count commits that no remote branch has.
  AHEAD="$(git -C "$DIR" rev-list --count HEAD --not --remotes 2>/dev/null || echo 0)"
else
  AHEAD=0
fi
[ "$CHANGED" = 0 ] && [ "$AHEAD" = 0 ] && exit 0

PARTS=""
[ "$CHANGED" != 0 ] && PARTS="$CHANGED uncommitted change(s)"
if [ "$AHEAD" != 0 ]; then
  [ -n "$PARTS" ] && PARTS="$PARTS and "
  PARTS="${PARTS}$AHEAD commit(s) not pushed"
fi
MSG="Not saved to GitHub yet in $(basename "$TOP"): $PARTS. Commit and push when this is a version you would want back." \
  jq -n '{systemMessage: env.MSG}'
exit 0
