---
name: reviewing-changes
description: "Review code for real problems before it goes anywhere. Use for review this, check for bugs, is this safe to merge, review my PR, before opening a PR, after finishing a feature, or when code feels sloppy."
---

# Reviewing changes

Find real problems. Style opinions waste the one pass someone will actually
read.

The model that wrote the code should not be its only reviewer. Use the
`code-reviewer` subagent (a fresh context that did not write the code), fix
what it finds, rerun the tests, and review the result again.

## Get the code first

Never review from memory of what was written. Read the actual diff.

```sh
git diff --stat          # which files changed, before reading any of them
git diff HEAD            # everything not yet committed
git diff main...HEAD     # the whole branch compared with main
```

For a GitHub pull request: `gh pr diff <number>`.

If the diff is large, review in dependency order: database schema first, then
the code that reads it, then the pages that call that code.

## What matters, in order

**1. Does it do what it claims, and only that?** An unrelated change smuggled
into a diff is the most common source of a surprise bug.

**2. Correctness at the edges.** Empty list, one item, missing value, a number
arriving as a string, the form submitted twice. Walk one real failing input
through the code instead of reasoning in the abstract.

**3. Security, on every diff:**

- User input glued into a database query instead of passed as a parameter
- A secret written into the code
- A page or API route that never checks who is calling, or trusts an ID from
  the browser without checking ownership
- A query that can return someone else's records
- Logs that print passwords, tokens or personal data

**4. Error paths.** A swallowed error is a bug. Bad input and a database outage
need different handling.

**5. What it breaks elsewhere.** When a column, a type or a function's inputs
change, search for every other place that uses it.

**6. Tests that pin the right answer.** If a test asserts a wrong value because
that is what the code currently returns, both are wrong.

## Signs of AI-written slop in code

- Comments that narrate (`// loop through the members`). A comment should say
  something the code cannot: why, a gotcha, a constraint.
- A hand-written helper for something the language or an existing package
  already does (dates, IDs, deep copies).
- A new helper that duplicates one already in the project. Search first.
- Code for "future flexibility" nobody asked for: extra parameters, wrapper
  types, abstractions with one caller.
- Code that ignores how the neighboring files are written. Match them.

## Reporting

Lead with the most severe thing. For each finding: file and line, one sentence
on what breaks, and the input that triggers it. A finding without a failure
scenario is a guess.

Separate must-fix from nice-to-have. Say plainly when the diff is clean.

## For someone learning

Before running the reviewer, read the diff yourself and write down the one
thing you think is most likely wrong. Then compare with the review. That habit
is how you learn to read code instead of trusting it.

Adapted from Caleb Newton's Chewbacca kit.
