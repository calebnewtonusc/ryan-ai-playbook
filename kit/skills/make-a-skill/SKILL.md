---
name: make-a-skill
description: "Create a new Claude Code skill from a task you keep repeating, or fix one that is ignored or does the wrong thing. Use for make this a skill, I keep asking for this, turn this process into something reusable, or a skill that does not trigger."
---

# Make a skill

A skill is a folder with a `SKILL.md` file that Claude loads when a request
matches its description. It is how you teach Claude a process once instead of
explaining it every session. Skills live in `~/.claude/skills/<name>/` (every
project) or `.claude/skills/<name>/` inside one project.

## Why skills get ignored

Most skills fail the same way: someone wrote the file before they had done the
task. The file then holds a guess, and Claude follows the guess. The other
common failures:

- **The description does not match what people type**, so the skill never
  loads.
- **It does five things.** A skill that covers a whole workflow gets followed
  loosely. One task per skill. The test: would you ever run this step on its
  own? If not, it is a step, not a skill.
- **It is too long.** Past about 150 lines, rules start getting skipped. Long
  examples and reference facts go in a `references/` file the skill points to.
- **The purpose is buried.** Open with one sentence saying what the skill is
  for, above all the detail.
- **Rules are written as tone.** "Be accurate" cannot be checked. "Never invent
  a number. Write `[NEED: source]` instead" can.

## When a task deserves a skill

You have done it at least twice, it has steps that are easy to forget, and
doing it well depends on something Claude would not guess. A one-time task
does not need a skill. Name what goes wrong today without the skill. If you
cannot, stop: you would be building for a problem you do not have.

## Steps, in this order

1. **Do the task by hand with Claude**, as a plain prompt, until the output is
   right and you know why it is right. Note every correction you had to make.
   Those corrections are the skill's real content.
2. **Write the playbook in plain prose**, five parts: the rules, the steps,
   what good output looks like, one worked example, and the never-dos. Include
   what a wrong answer looks like. A bad example teaches more than another
   good one.
3. **Write the description.** It decides when the skill loads, so it carries
   two things in under 300 characters: what it does, and the phrases a person
   would actually type. "Draft the weekly announcement email from the events
   calendar. Use for weekly email, Sunday announcements, this week's bulletin."
4. **Only now write `SKILL.md`**, from the playbook: numbered steps, each one
   an action, not a paragraph of background.
5. **Write the test cases before you test.** In `evals/evals.json` next to the
   skill, list three requests that should trigger it, one that should not, and
   for each, what the output must contain:

```json
[
  {
    "prompt": "draft this week's bulletin",
    "should_trigger": true,
    "expect": ["lists every event from the calendar", "no invented dates"]
  },
  { "prompt": "fix the typo in the footer", "should_trigger": false }
]
```

6. **Run them.** Start a fresh Claude session for each prompt. Check the skill
   loaded when it should, stayed quiet when it should not, and that the output
   meets every `expect` line.
7. **Fix what failed and run them again.** Did not load: the description is
   missing the words people use. Loaded but did poorly: a step is vague, or the
   skill is doing too much.

## Template

```markdown
---
name: weekly-announcements
description: "Draft the weekly announcement email from the events calendar. Use for weekly email, Sunday announcements, this week's bulletin."
---

# Weekly announcements

Turns this week's calendar into the announcement email, in the house format.

1. Read this week's events from <where they live>.
2. ...

## Rules

- Never invent a date or a time. Missing ones go in as [NEED: date].

## A wrong answer looks like

- ...
```

## Before installing someone else's skill

Read it first. A skill runs with your permissions, your files and your
accounts. Check what it tells Claude to run, and check its license.

## For someone learning

Do step 1 yourself, without asking Claude to write the skill. Then, before
running step 6, predict which of your test prompts will fail and why. The gap
between your prediction and the result is what you learn about how Claude
reads instructions.

## Going further

Anthropic publishes a fuller `skill-creator` skill with automated evaluations
at https://github.com/anthropics/skills, once you want to measure a skill
instead of eyeballing it.

Adapted from Caleb Newton's Chewbacca kit.
