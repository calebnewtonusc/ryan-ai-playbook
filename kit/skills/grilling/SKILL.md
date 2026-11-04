---
name: grilling
description: "Grill the user about a plan, design or idea, one round at a time, until nothing is silently assumed. ONLY when asked: grill me, stress-test my plan, poke holes, what am I missing."
---

# Grilling

Interview the user relentlessly until you reach a shared understanding. Map
this as a **design tree**: every decision branches into the decisions that
hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose
prerequisites are already settled: the questions you can ask _now_ without
guessing at answers you have not heard yet. Ask the whole frontier in one
round: number each question and give your recommended answer. Then wait for
the user's answers before the next round.

Format a round like this:

```
Q1, <question title>: <question body, options if there are any>
My pick: <your recommended answer>

Q2, <question title>: <question body>
My pick: <your recommended answer>
```

Word each question so "yes" accepts your pick.

Each round of answers reshapes the tree: settled decisions push the frontier
outward and unblock questions that depended on them. Recompute the frontier
and ask the next round. A question whose answer depends on another question
still open in this round belongs to a _later_ round.

Finding _facts_ is your job, never the user's. When a question needs a fact
from the project (files, docs, the database schema, git history), look it up
yourself. Never ask something you could find. The _decisions_ are the user's:
put each one to them and wait.

The session is done when the frontier is empty: every branch visited, nothing
left silently assumed. Do not act on it until the user confirms you have
reached a shared understanding. Then write the settled decisions into a short
plan file (for example `docs/plans/<topic>.md`) before building.

## Why this is in a beginner kit

Grilling is the fastest way to find out what you have not decided yet. Every
question you cannot answer is a place the AI would otherwise have guessed for
you, and those guesses are where projects drift into something you did not
want.

## Credit

From the `grilling` skill in [mattpocock/skills](https://github.com/mattpocock/skills)
(MIT, see LICENSE). Changed here: the round format drops emoji markers, the
skill runs only when asked, and the closing step writes a plain plan file.
Adapted from Caleb Newton's Chewbacca kit.
