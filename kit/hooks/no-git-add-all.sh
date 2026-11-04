#!/bin/bash
# PreToolUse hook for Bash. Refuses git commands that stage or commit the
# whole folder at once: `git add -A`, `git add .`, `git add -u`, `git commit -a`
# and their many spellings.
#
# Why it exists: those commands stage everything in the folder, including a
# .env file full of passwords, a 400 MB video, or a half-finished experiment.
# Once a secret is pushed to GitHub, deleting it later does not help: it is in
# the history and bots scrape public repos for keys within minutes.
# Staging files by name is slower by five seconds and cannot do that.
#
# How it reads the command: it splits it into words the way a shell would
# (Python's shlex), skips git's global options like -C and -c, finds the add or
# commit, and checks each argument. This catches an honest agent's bulk staging.
# It is a tripwire, not a security wall: a command built to sneak past a check
# like this always can, so keep reviewing what gets committed.
#
# Exit 0 allows. Exit 2 blocks and shows the stderr text to Claude.

INPUT="$(cat)"
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  CMD="$INPUT"
fi
[ -n "$CMD" ] || exit 0
case "$CMD" in *git*) ;; *) exit 0 ;; esac
block_add() {
  echo "Blocked by no-git-add-all.sh: stage files by name, for example: git add src/app.ts README.md" >&2
  echo "Run git status first to see what changed, and leave out anything you did not mean to touch." >&2
  exit 2
}
block_commit() {
  echo "Blocked by no-git-add-all.sh: this commit takes every changed file in the repo. Add files by name, then git commit -m." >&2
  exit 2
}

# First pass, a plain pattern check that needs nothing installed. It runs every
# time, so if Python is missing or fails, the common bulk forms still get blocked.
FLAT="$(printf '%s' "$CMD" | tr -d "\"'")"
printf '%s' "$FLAT" | grep -Eq 'git[[:space:]]+([^;&|]*[[:space:]])?add([[:space:]][^;&|]*)?[[:space:]](-[a-zA-Z]*[Au][a-zA-Z]*|--all|--update|\.|\./|\*|:/|:\(top\))([[:space:]]|;|&|\||[},]|$)' && block_add
printf '%s' "$FLAT" | grep -Eq 'git[[:space:]]+([^;&|]*[[:space:]])?commit([[:space:]][^;&|]*)?[[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|;|&|\||[},]|$)' && block_commit

# Second pass, the careful one, needs Python 3 (macOS has it with the developer tools).
command -v python3 >/dev/null 2>&1 || exit 0

VERDICT="$(printf '%s' "$CMD" | python3 -I -c '
import shlex, sys

cmd = sys.stdin.read()
try:
    lex = shlex.shlex(cmd, posix=True, punctuation_chars=";&|()\n")
    lex.whitespace = " \t\r"
    lex.whitespace_split = True
    words = list(lex)
except ValueError:
    words = cmd.replace("\n", " ; ").split()

# Split into simple commands at ; && || | ( ).
pieces, cur = [], []
for w in words:
    if w and set(w) <= set(";&|()\n"):
        pieces.append(cur); cur = []
    else:
        cur.append(w)
pieces.append(cur)

GLOBAL_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path", "--config-env"}
WHOLE_TREE = {".", "./", "*", "./*", ":/", ":(top)", ":/*", ":(top)*"}

def is_whole_tree(path):
    return path in WHOLE_TREE or path.rstrip("/") in {".", "*", "./*", ":", ":/.", ":(top)", ":(top)."}

def long_prefix_of(arg, *names):
    if not arg.startswith("--") or len(arg) < 4:
        return False
    a = arg.split("=", 1)[0]
    return any(n.startswith(a) for n in names)

for p in pieces:
    # skip env assignments and wrappers before git
    i = 0
    while i < len(p) and ("=" in p[i] and not p[i].startswith("-") or p[i] in {"sudo", "env", "command", "exec", "nohup", "time", "then", "do", "else", "elif", "if", "while", "until", "{", "}", "!", "xargs"}):
        i += 1
    if i >= len(p) or p[i].rsplit("/", 1)[-1] != "git":
        continue
    i += 1
    while i < len(p) and p[i].startswith("-"):
        opt = p[i].split("=", 1)[0]
        i += 2 if (opt in GLOBAL_WITH_VALUE and "=" not in p[i]) else 1
    if i >= len(p):
        continue
    sub, args = p[i], p[i + 1:]
    after_dashdash = False
    if sub == "add":
        for a in args:
            if a == "--":
                after_dashdash = True; continue
            if not after_dashdash and a.startswith("--"):
                if long_prefix_of(a, "--all", "--update", "--no-ignore-removal"):
                    print("add"); sys.exit()
            elif not after_dashdash and a.startswith("-") and len(a) > 1:
                if "A" in a[1:] or "u" in a[1:]:
                    print("add"); sys.exit()
            elif is_whole_tree(a):
                print("add"); sys.exit()
    elif sub == "commit":
        skip_next = False
        for a in args:
            if skip_next:
                skip_next = False; continue
            if a == "--":
                after_dashdash = True; continue
            if not after_dashdash and a.startswith("--"):
                if long_prefix_of(a, "--all"):
                    print("commit"); sys.exit()
                if a.split("=", 1)[0] in {"--message", "--file", "--author", "--date", "--reuse-message", "--reedit-message", "--fixup", "--squash", "--template", "--cleanup", "--trailer", "--pathspec-from-file"} and "=" not in a:
                    skip_next = True
            elif not after_dashdash and a.startswith("-") and len(a) > 1:
                flags = a[1:]
                # -m, -F, -C, -c, -t take a value; letters after them are the value
                for ch in flags:
                    if ch == "a":
                        print("commit"); sys.exit()
                    if ch in "mFCct":
                        if ch == flags[-1]:
                            skip_next = True
                        break
            elif is_whole_tree(a):
                print("commit"); sys.exit()
' 2>/dev/null)"

case "$VERDICT" in
  add) block_add ;;
  commit) block_commit ;;
esac
exit 0
