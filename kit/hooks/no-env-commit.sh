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
# cd with no folder or with -, nested shells, eval, xargs, find -exec, env -C
# and ( or { groups move git somewhere this parser cannot follow. Refuse those
# when the command also runs git add/commit. This is a tripwire for honest
# mistakes, not a sandbox: a shell is too rich for a pattern list to cover
# every form, so a determined bypass is out of scope.
if printf '%s' "$CMD" | grep -qE '\bgit\b.*\b(add|commit)\b' &&
  # Escaped quotes break the quote stripping below, so refuse them outright.
  { printf '%s' "$CMD" | grep -qE "\\\\[\"']" && printf '%s' "$CMD" | grep -qE '\b(ba|z|da|k)?sh\b|\beval\b|\bxargs\b|[({]'; } ||
  printf '%s\n' "$CMD" | sed -E "s/\"[^\"]*\"/Q/g; s/'[^']*'/Q/g" | tr ';&|' '\n\n\n' | grep -qE '^[[:space:]]*(cd|pushd)[[:space:]]*(-[^[:space:]]*[[:space:]]*)?$|^[[:space:]]*(cd|pushd)[[:space:]]+-|\b(ba|z|da|k)?sh[[:space:]]+-[A-Za-z]*c|\beval\b|\bxargs\b|-exec(dir)?\b|\benv\b[^|;&]*(-C|--chdir)|(^|[[:space:]])[({]'; then
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
safe_git() {
  GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true GIT_TERMINAL_PROMPT=0 \
    git -c core.fsmonitor= -c core.hooksPath=/dev/null -c core.untrackedCache=false -c core.attributesFile=/dev/null \
    -c core.editor=true -c sequence.editor=true "$@" </dev/null
}

check_list() {  # check_list <label> <newline-separated paths>
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '%s' "$f" | grep -qE "$SAFE" && continue
    printf '%s' "$f" | grep -qE "$SECRET" && block "$f ($1)"
  done <<<"$2"
}

# Files `git add` would stage. set -f stops a * in the command from expanding here.
set -f
ADD_LINES="$(printf '%s\n' "$CMD" | tr ';&|' '\n\n\n' | sed -nE 's/^[[:space:]]*git([[:space:]]+-[Cc][[:space:]]+[^[:space:]]+)*[[:space:]]+add[[:space:]]+//p')"
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in
    *'$'* | *'`'*)
      # A variable or command we cannot expand: refuse rather than guess what it adds.
      echo "Blocked by no-env-commit.sh: git add $line uses a shell expansion this hook cannot resolve." >&2
      echo "Name the files literally (git add src/app.ts README.md) so they can be checked." >&2
      exit 2 ;;
  esac
  FLAGS=() PATHS=()
  for word in $line; do
    word="${word%\"}"; word="${word#\"}"; word="${word%\'}"; word="${word#\'}"
    case "$word" in
      -n | --dry-run | -v | --verbose | --) continue ;;
      # Flags that change what gets staged go into the dry run as they are.
      -f | --force | -A | --all | -u | --update | --no-all | --ignore-removal | --no-ignore-removal | -N | --intent-to-add)
        FLAGS+=("$word"); continue ;;
      -*)
        # Interactive, patch, edit and from-file adds can't be checked with a dry run.
        echo "Blocked by no-env-commit.sh: git add $word can't be checked for secrets files." >&2
        echo "Stage files by name instead (git add src/app.ts README.md)." >&2
        exit 2 ;;
    esac
    PATHS+=("$word")
    printf '%s' "$word" | grep -qE "$SAFE" && continue
    printf '%s' "$word" | grep -qE "$SECRET" && block "$word"
  done
  # Folders, globs, :(magic) pathspecs and -f can stage a file the command never
  # names, so ask git itself, with the same flags, what this add would stage.
  CHECKED=0 TRIED=0
  while IFS= read -r d; do
    safe_git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
    TRIED=1
    # A clean or process filter runs a program while git add hashes files,
    # dry run included. Read every filter git will load for this repo, includes
    # followed, and refuse outright if any comes from the repo itself (local or
    # worktree config, or a file it includes): a fresh clone's config isn't
    # yours, your global and system config are (security review, 2026-11-04).
    if ! SCOPES="$(safe_git -C "$d" config --show-scope --includes --get-regexp '^filter\..*\.(clean|process)$' 2>/dev/null; [ $? -le 1 ])"; then
      echo "Blocked by no-env-commit.sh: couldn't read this repo's git config to check for filter programs, so git add $line wasn't checked." >&2
      exit 2
    fi
    if printf '%s\n' "$SCOPES" | grep -qvE '^(global|system)[[:space:]]|^$'; then
      echo "Blocked by no-env-commit.sh: this repo's own git config defines a filter program, which git add would run. Look at it with: git config --show-origin --get-regexp '^filter'" >&2
      exit 2
    fi
    if OUT="$(safe_git -C "$d" add --dry-run ${FLAGS[@]+"${FLAGS[@]}"} -- ${PATHS[@]+"${PATHS[@]}"} 2>/dev/null)"; then
      CHECKED=1
      check_list "would be added by git add $line" "$(printf '%s\n' "$OUT" | sed -nE "s/^add '(.*)'\$/\1/p")"
    fi
  done <<<"$DIRS"
  # git could not say what this add stages in any repo: refuse rather than wave it through.
  if [ "$TRIED" = 1 ] && [ "$CHECKED" = 0 ]; then
    echo "Blocked by no-env-commit.sh: git add --dry-run failed for git add $line, so the files could not be checked." >&2
    echo "Check the paths exist, then stage them by name." >&2
    exit 2
  fi
done <<<"$ADD_LINES"
set +f

# Files already staged, when committing.
if printf '%s' "$CMD" | grep -qE '\bgit\b.*\bcommit\b'; then
  while IFS= read -r d; do
    [ -d "$d" ] || continue
    check_list "staged in $d" "$(safe_git -C "$d" diff --cached --name-only 2>/dev/null)"
  done <<<"$DIRS"
fi
exit 0
