#!/bin/bash
# PreToolUse hook for Bash. Refuses staging or committing a secrets file:
# .env files (not .env.example), private keys (.pem, .key, id_rsa), and
# credential JSON files.
#
# Why it exists: protect-secrets.sh keeps keys out of source code, and this
# keeps the file that holds them out of git. Once a .env is pushed, deleting
# it later does not help: it stays in the history, and bots scan public repos
# for keys within minutes.
#
# It checks the files named in `git add`, and for `git commit` it reads what
# is already staged in the folder the command runs in.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

INPUT="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$CMD" ] || exit 0
case "$CMD" in *git*) ;; *) exit 0 ;; esac

SECRET='(^|/)(\.env(\.[A-Za-z0-9_-]+)?|[^/]*\.pem|[^/]*\.key|id_rsa|id_ed25519|credentials\.json|service-account[^/]*\.json)$'
SAFE='(^|/)\.env\.(example|sample|template)$'

block() {
  echo "Blocked by no-env-commit.sh: $1 looks like a secrets file. Keep it out of git." >&2
  echo "Add it to .gitignore, and commit a .env.example with placeholder values instead." >&2
  exit 2
}

# Every folder the command can run git in: the session folder, plus each
# `cd X` and `git -C X` it names. A path we cannot resolve gets refused rather
# than checked in the wrong repo.
BASE="${CWD:-$PWD}"
DIRS="$BASE"
if printf '%s' "$CMD" | grep -qE -- '--git-dir|--work-tree|GIT_DIR=|GIT_WORK_TREE='; then
  echo "Blocked by no-env-commit.sh: --git-dir, --work-tree or GIT_DIR point git at a repo this hook cannot check." >&2
  echo "Run git from inside the repo (cd path/to/repo && git ...) instead." >&2
  exit 2
fi
# cd with no folder or with -, and nested shells, move git somewhere this
# parser cannot follow. Refuse those when the command also runs git add/commit.
if printf '%s' "$CMD" | grep -qE '\bgit\b.*\b(add|commit)\b' &&
  printf '%s\n' "$CMD" | tr ';&|' '\n\n\n' | grep -qE '^[[:space:]]*(cd|pushd)[[:space:]]*(-[[:space:]]*)?$|\b(ba|z)?sh[[:space:]]+-c\b|\benv[[:space:]]+-C\b|(^|[[:space:]])\('; then
  echo "Blocked by no-env-commit.sh: this command changes folder in a way the hook cannot follow (cd -, a bare cd, sh -c, env -C, or a subshell), so it cannot check what git will add or commit." >&2
  echo "Run git as its own command from inside the repo (cd path/to/repo && git ...)." >&2
  exit 2
fi
TARGETS="$(printf '%s\n' "$CMD" | tr ';&|' '\n\n\n' | sed -nE \
  -e 's/^[[:space:]]*(cd|pushd)[[:space:]]+([^[:space:]]+).*/\2/p' \
  -e 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:]]+).*/\1/p')"
while IFS= read -r t; do
  [ -n "$t" ] || continue
  t="${t%\"}"; t="${t#\"}"; t="${t%\'}"; t="${t#\'}"
  case "$t" in
    *'$'* | *'`'*)
      echo "Blocked by no-env-commit.sh: this git command runs in $t, which this hook cannot resolve, so it cannot check the files." >&2
      echo "Use a literal path (cd path/to/repo && git ...) so the files can be checked." >&2
      exit 2 ;;
    "~") t="$HOME" ;;
    "~/"*) t="$HOME/${t#\~/}" ;;
    /*) ;;
    *) t="$BASE/$t" ;;
  esac
  DIRS="$DIRS
$t"
done <<<"$TARGETS"

# The repo being checked may not be yours yet (a fresh clone). Its config can
# name programs git runs (core.fsmonitor, hooks), so turn those off here.
safe_git() { git -c core.fsmonitor= -c core.hooksPath=/dev/null -c core.untrackedCache=false "$@"; }

check_list() {  # check_list <label> <newline-separated paths>
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '%s' "$f" | grep -qE "$SAFE" && continue
    printf '%s' "$f" | grep -qE "$SECRET" && block "$f ($1)"
  done <<<"$2"
}

# Files named after `git add`. set -f stops a * in the command from expanding here.
set -f
ADD_ARGS="$(printf '%s\n' "$CMD" | tr ';&|' '\n\n\n' | sed -nE 's/^[[:space:]]*git([[:space:]]+-[Cc][[:space:]]+[^[:space:]]+)*[[:space:]]+add[[:space:]]+//p')"
if [ -n "$ADD_ARGS" ]; then
  for word in $ADD_ARGS; do
    word="${word%\"}"; word="${word#\"}"; word="${word%\'}"; word="${word#\'}"
    case "$word" in -*) continue ;; esac
    printf '%s' "$word" | grep -qE "$SAFE" && continue
    printf '%s' "$word" | grep -qE "$SECRET" && block "$word"
    # A folder or a glob can pull in a .env it does not name: ask git what it would add.
    while IFS= read -r d; do
      safe_git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
      if [ -d "$d/$word" ] || printf '%s' "$word" | grep -q '[*?[]'; then
        WOULD="$(safe_git -C "$d" add --dry-run -- "$word" 2>/dev/null | sed -nE "s/^add '(.*)'\$/\1/p")"
        check_list "would be added by git add $word" "$WOULD"
      fi
    done <<<"$DIRS"
  done
fi
set +f

# Files already staged, when committing.
if printf '%s' "$CMD" | grep -qE '\bgit\b.*\bcommit\b'; then
  while IFS= read -r d; do
    [ -d "$d" ] || continue
    check_list "staged in $d" "$(safe_git -C "$d" diff --cached --name-only 2>/dev/null)"
  done <<<"$DIRS"
fi
exit 0
