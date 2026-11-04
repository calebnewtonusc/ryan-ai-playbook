---
name: learn-from-corrections
description: "Turn a correction or a repeated mistake into something that prevents it next time: a rule, a test, or a default. Use when the user says that's wrong, I told you before, why does it keep doing this, remember this, or after any bug that took a while to find."
---

# Learn from corrections

A correction that lives only in the chat is forgotten when the session ends.
This skill puts it somewhere the next session will read.

## Steps

1. **State the lesson in one sentence**, specific enough to check. "Use the
   `members` table, not `users`, for anyone who is not staff" beats "be careful
   with tables."
2. **Pick where it goes:**
   - **A judgment** (how to name things, what tone to use, which approach to
     prefer) goes in the project's `CLAUDE.md`, or in `~/.claude/CLAUDE.md` if
     it applies to every project.
   - **A mechanical mistake** (this input breaks, this value is wrong) becomes
     a test next to the code, because a failing test is loud and a note gets
     skimmed.
   - **A step people keep forgetting** becomes a default: a script, a
     template, a hook, a package.json command.
3. **Anchor it to what happened.** One line of evidence under the rule: "The
   sign-up page sent two welcome emails when the button was double-clicked."
   A rule with its reason survives. A bare rule gets deleted by the next
   person who finds it inconvenient.
4. **Check it landed.** Read the file back, or run the new test and watch it
   fail on the old behavior.
5. **Check for the same mistake elsewhere** and fix those too.

## When not to

A one-off typo is not a lesson. Fix it and move on. If a correction produces
no rule, no test and no default, it was a typo.

## For someone learning

Keep a short `LESSONS.md` of your own in plain words: what went wrong, what you
learned. Rereading it monthly shows how far you have come, and the patterns in
it show what to study next.

Adapted from Caleb Newton's Chewbacca kit.
