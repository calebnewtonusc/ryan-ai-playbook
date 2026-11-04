---
name: make-a-skill
description: "Create a new Claude Code skill from a task the user keeps repeating, or improve an existing one. Use for make this a skill, I keep asking for this, turn this process into something reusable, or a skill that does not trigger."
---

# Make a skill

A skill is a folder with a `SKILL.md` file that Claude loads when a request
matches its description. It is how you teach Claude a process once instead of
explaining it every session. Skills live in `~/.claude/skills/<name>/` (every
project) or `.claude/skills/<name>/` inside one project.

## When a task deserves a skill

You have done it at least twice, it has steps that are easy to forget, and
doing it well depends on knowing something Claude would not guess. A one-time
task does not need a skill.

## Steps

1. **Do the task by hand once with Claude**, start to finish, and note every
   correction you had to make. Those corrections are the skill's content.
2. **Write the description first.** It decides when the skill loads. Say what
   it does and list the phrases a user would actually type: "Use for weekly
   bulletin, Sunday announcements, what goes in this week's email."
3. **Write the body** as numbered steps, each one a thing to do, not a
   paragraph of background. Include the rules that make the result good (see
   the `research-the-craft` skill) and what to avoid.
4. **Keep it short.** Under about 150 lines. Move long examples into a
   `references/` file next to `SKILL.md` and link it.
5. **Test it.** Start a fresh Claude session and type three different requests
   that should trigger it, and one that should not. Check it loads when it
   should, stays quiet when it should not, and that the output follows the
   steps.
6. **Fix what failed and test again.** If it did not load, the description is
   missing the words people use. If it loaded but did poorly, a step is vague.

## Template

```markdown
---
name: weekly-announcements
description: "Draft the weekly church announcement email from the events calendar. Use for weekly email, Sunday announcements, this week's bulletin."
---

# Weekly announcements

1. Read this week's events from <where they live>.
2. ...

## Rules

- ...

## Avoid

- ...
```

## Going further

Anthropic publishes a fuller `skill-creator` skill with automated evaluations
at https://github.com/anthropics/skills, once you want to measure a skill
instead of eyeballing it.

Adapted from Caleb Newton's Chewbacca kit.
