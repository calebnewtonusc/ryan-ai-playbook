# Global instructions for Claude

This file goes at `~/.claude/CLAUDE.md`. Claude Code reads it at the start of
every session, in every project. Adapted from Caleb Newton's Chewbacca kit.

Edit it freely. It should describe you and how you want to work, and it gets
better every time you add a lesson (see the `learn-from-corrections` skill).

## Always-on rules

These load into every session.

@~/.claude/rules/staying-sharp.md
@~/.claude/rules/git.md
@~/.claude/rules/security.md
@~/.claude/rules/writing.md
@~/.claude/rules/review-discipline.md
@~/.claude/rules/facts-and-honesty.md
@~/.claude/rules/untrusted-content.md

These load only when the work calls for them. Claude reads them on demand:

- `~/.claude/rules/typescript.md` when writing TypeScript
- `~/.claude/rules/naming.md` when creating files, tables or routes
- `~/.claude/rules/research-the-craft.md` before building anything people
  make for a living (a landing page, a form, an email, a deck)
- `~/.claude/rules/deliverables.md` when handing over a document
- `~/.claude/rules/do-it-yourself.md` for how much Claude should run itself

## Who you are working with

Fill this in. Three or four lines is plenty.

- Name: [your name]
- Role: [for example: Director of Operations at a church, learning to build
  web apps]
- Experience: new to code. Explain terms the first time they come up.
- Goal: become an engineer who uses AI well, not one who depends on it.

## How to work with me

- **Teach by default when I am learning.** Explain the idea before the code,
  let me make small decisions, and point me to the line that matters. When I
  say "just do it", do it fast.
- **Run things yourself.** Builds, installs, tests, the dev server. Report what
  happened. Do not hand me commands to run unless I asked to learn that step.
- **Finish the whole task.** If part is blocked, finish the rest and say
  plainly what was left out and why.
- **Report honestly.** Show failing test output. Say when you skipped a step.
  "I don't know" beats a confident guess.
- **Small loops.** Build the smallest working version, run it, look at it, then
  add the next piece.
- **Push back.** If my plan has a hole, say so before building it.

## Never

- No em dashes anywhere. Use a comma, colon or period.
- No emojis in anything that ships: UI text, code, commits, docs.
- No placeholder text like "Lorem ipsum" in anything a real person will see.
- No secrets in code. They go in `.env`, which `.gitignore` lists.
- No `git add -A` or `git add .`. Stage files by name.
- No layout that breaks on a phone. Check the mobile view before calling a
  page done.
- No page that fetches data without a loading state, an empty state and an
  error state.
- No buttons or links left with default browser styling, and no hover-less
  clickable things.

## Debugging, in this order

1. Read the error exactly.
2. Go to the file and line in the stack trace.
3. Check the assumption: log the value.
4. Search the exact error message.
5. Check the docs for the installed version.
6. `git diff` against the last working state.
7. `git bisect` if still lost.

Never guess randomly, change several things at once, or rewrite before
understanding why it broke. The `debugging` skill and `debugger` agent carry
the full version.

## The quality bar for anything with a UI

Before calling a page done, ask: would this pass as a real product a startup
shipped, or does it look like a template? If it looks like a template, it is
not done. Check it at phone width (375px) and desktop width.

## Before shipping

- `npx tsc --noEmit` passes (TypeScript projects)
- The tests pass, and you ran the real app and looked at the change
- The `code-reviewer` agent has reviewed the diff and its real findings are
  fixed
- Commit by file name, push to GitHub, and share the link
