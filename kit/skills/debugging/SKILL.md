---
name: debugging
description: "Find the root cause of a bug instead of guessing. Use for something broken, an error or stack trace, it used to work, why is this failing, tracing where data goes wrong, crash, regression, debug this."
---

# Debugging

The protocol exists because the usual failure is the same everywhere: change
several things at once, then never know which one helped.

## The order, and do not skip

**1. Read the error exactly.** Every word. `undefined` and `null` are different
bugs. "Cannot read properties of undefined (reading 'email')" names the
property, and that is usually the whole answer.

**2. Go to the file and line in the stack trace** before doing anything else.
If there is no stack trace, get one first. A bug report without one is a rumor.

**3. Check the assumption.** Print the variable. Is it the shape you believed?
Most bugs are a value with a different type, different case, or missing
entirely, and they are invisible when you only read the code, because the code
looks right.

**4. Search the exact message.** Framework name, exact string, year. Someone has
hit it.

**5. Check for a breaking change.** Read the docs for the version actually
installed (`npm ls <package>`), not the version you remember.

**6. `git diff` against the last working version.** The bug lives in the diff.
This step alone solves most "it used to work" problems, and it is the one most
often skipped.

**7. `git bisect`** if still lost. It finds the exact commit that broke it.

Never change several things at once, and never delete and rewrite before
understanding why it broke. A rewrite that works for reasons nobody understands
is the same bug on a longer fuse.

## Tracing where data goes wrong

To follow data end to end (a form submit that never shows up in the database):
name the starting point, then read each function in the chain in full.

Mark three kinds of places as you go, because that is where data gets lost:

- **Where it changes shape:** parsed, validated, renamed, converted to JSON
- **Where it could disappear:** a caught-and-ignored error, an early return, a
  default value that silently replaces a missing one
- **Where it crosses a boundary:** browser to server, server to database, one
  service to another

Report the chain file by file, with what the data looks like at each step.

## When it is fixed

1. Write the test that would have caught it.
2. Search for the same mistake elsewhere in the project.
3. Say in one line which step found it. Over time that tells you which step to
   reach for first.

## For someone learning

Before looking at the answer, take 60 seconds and guess the cause yourself,
then compare. Debugging is the skill that separates people who can build from
people who can only prompt, and it only grows when you guess first.

Adapted from Caleb Newton's Chewbacca kit.
