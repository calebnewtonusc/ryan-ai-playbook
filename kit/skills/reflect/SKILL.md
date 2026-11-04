---
name: reflect
description: "Review a finished, stalled or failed work session and propose evidence-backed edits to the instructions that steered it (CLAUDE.md, rules, skills). Use for reflect, retro, what went wrong, or improving a skill from how a session went."
---

# Reflect

Review one session, report what helped and what hurt, and propose edits to the
reusable instructions that shaped it. "Nothing should change" is a valid
outcome.

This reviews the work process. To review code, use `reviewing-changes`. To save
one correction you just gave, use `learn-from-corrections`.

## Boundary

Reading evidence and showing findings needs no approval. Editing shared
instructions (`CLAUDE.md`, a rule, a skill) waits until the person approves the
exact edit shown. "Reflect" and "I agree" are not approval of a specific edit.
If the person already said "save this lesson", that is the approval: apply it
and say so.

## Steps

1. **Rebuild what happened from evidence.** The original ask, the corrections,
   command output, what was accepted. Separate "claimed done" from "verified"
   (an exit code, real output, the person saying it works). If part of the
   session is missing, say so. A requirement that changed midway is not a
   mistake against the original ask.

2. **Review the path, not just the result.** Look for repeated searching,
   checks that answered nothing, work nobody needed, and waiting. For each,
   say what was known at the time and the smaller action that would have
   worked. A long investigation is not waste just because it was long.

3. **Read the instructions that steered the work.** The `CLAUDE.md`, rules and
   skills actually used. For each failure, decide which it was: the guidance
   was missing, wrong, hard to find, or clear but ignored. If it existed and
   was ignored, saying it louder will not help. Fix where it loads or which
   step enforces it, or add a check that fails.

4. **Check earlier fixes.** Look at the file's git history (`git log -p <file>`).
   If an earlier edit targeted this same failure and it happened again, that
   edit did not work. Change how it is delivered, or remove it.

5. **Show early findings, then ask the person for their view.** Keep it short,
   with examples. Their answer is evidence:

   - a preference is theirs to decide
   - a reported problem gets taken seriously and diagnosed
   - a proposed fix gets pushback if the evidence shows it would break
     something, with an alternative that serves their goal

6. **Pick what deserves a lasting edit.** It needs evidence, a situation that
   will recognizably come up again, and something not already written down.
   Drop one-off settings, outages and untested guesses.

7. **Put it in the smallest home.** A behavior fix goes in the doc that
   steered it. A procedure goes in the existing skill. A project fact goes in
   project docs. A mechanical failure becomes a test next to the code.
   Temporary state gets no lasting edit. Files that load every session must
   earn their space; prefer a place that only loads when relevant.

8. **Propose each edit:** the file and section, the exact text, the evidence,
   what it replaces, the change you expect to see, and how to check it (a
   case where it should apply, and one where it should not). Removing or
   narrowing a rule is a valid proposal too.

9. **Apply only approved edits, then verify.** Re-read the file first in case
   it changed, apply, then `grep` for the new text to confirm it landed. A
   file that reads well is not proof behavior improved. A later session that
   actually follows it is.

## Never

- Edit shared instructions before approval (unless the person already asked
  for the lesson to be saved).
- Count tool calls as waste, or invent time savings you did not measure.
- Save a lesson that nothing will ever read.
- Paste raw transcripts or private details into reusable instructions.
- Call a problem fixed because a rule was written.

## For someone learning

Before running this, write down the one moment in the session you think went
worst, and why. Compare it with what the review finds. You approve or reject
each proposed edit yourself, and for each one you keep, say in one sentence
what you expect to go differently next time.

## Credits

Adapted from cstack by Charles Zheng (https://github.com/goodnight000/cstack),
MIT License, see [LICENSE](LICENSE).
