# Git rules

Git is your undo button and your history. These rules keep it trustworthy.

## Stage by name, never everything

Use `git add path/to/file` for each file you mean to commit. Never
`git add -A`, `git add .`, or `git commit -a`. Those grab everything in the
folder: a `.env` full of passwords, a huge video, a half-finished experiment.
(The `no-git-add-all.sh` hook enforces this.)

Example of what goes wrong: someone runs `git add .` to commit one bug fix, and
their database password goes to a public GitHub repo with it. Bots find keys
in public repos within minutes.

## Commit only what you staged

`git commit -- path/one path/two` commits exactly those paths, even if
something else got staged earlier. Check with `git diff --cached --name-only`
when unsure.

## Branches

- `feat/short-name` for a new feature
- `fix/short-name` for a bug fix
- `chore/short-name` for cleanup and updates

Work on a branch, open a pull request, merge to `main`. Keep `main` working.

## Commit messages

- `feat: add volunteer sign-up form`
- `fix: stop duplicate emails when a form is submitted twice`
- `chore: update dependencies`

Say what changed and why, in plain words. No AI attribution lines.

## Never destroy work you cannot get back

- Never `git reset --hard`, `git checkout .`, or `git clean -f` on a folder
  with uncommitted changes. Commit or stash first.
- Never force push to `main`. On your own branch, `--force-with-lease` is the
  safe version.
- Never amend a commit you already pushed. Make a new commit.

## Conflicts

Read both sides of a merge conflict before choosing. Picking "ours" or
"theirs" without reading is how a teammate's fix disappears.
