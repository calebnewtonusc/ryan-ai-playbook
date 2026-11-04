# Level 4: build your own setup

At this point you've noticed you keep typing the same instructions and catching the same mistakes. Level 4 is turning those into a setup that does it for you. My setup is called Chewbacca. It grew one mistake at a time until it had 18 rule files, over a hundred hooks and hundreds of skills. Yours should start with five things and grow the same way: one real lesson at a time.

The [kit/](../kit/) folder has starter versions of each piece below, adapted from mine. Install one piece at a time and only when you feel the need for it.

## The pieces

**Global CLAUDE.md** (`~/.claude/CLAUDE.md`): rules for every project on your computer. How you like to work, what you never want, how to talk to you. A project's own CLAUDE.md adds to it.

**Rules** (`~/.claude/rules/*.md`): longer standards, one topic per file. Git, security, writing, how to review. The trick that makes rules stick: each one says what went wrong that made it a rule. "Never commit a .env file" gets ignored. "Never commit a .env file, because one time it leaked a key and someone ran up a bill" gets followed.

**Skills** (`~/.claude/skills/<name>/SKILL.md`): a playbook for one kind of task, which Claude loads only when the task comes up. A skill for debugging, one for writing, one for shipping. Write one whenever you explain the same process to Claude twice.

**Subagents** (`~/.claude/agents/*.md`): specialists Claude can hand work to, each with its own fresh context. A code reviewer that never saw how the code got written catches things the builder can't. A debugger that follows a fixed order. An explorer that reads a big codebase and comes back with just the answer.

**Hooks** (in `~/.claude/settings.json`): scripts that run automatically at set moments, like before a command runs or when Claude finishes a reply. This is the big one, because rules are requests and hooks are enforcement. A rule says "don't run rm -rf." A hook stops it from running. Mine block things like deleting files without looking, committing secrets and replying with AI-slop phrases.

**MCP servers**: plug-ins that let Claude talk to other apps directly, like GitHub, Google Drive, a database or a browser. Add one when you're tired of copying data between Claude and an app.

## How a lesson becomes part of your setup

Every correction goes one of three places:

1. A judgment call ("how to write church copy") goes in a **rule or skill**
2. A mechanical mistake ("it keeps forgetting to run the build before pushing") becomes a **hook or a test**
3. The right move becomes the **default**, so doing it right is the easiest path

If a correction doesn't land in one of those, you'll be correcting it again next week.

## Write a skill

```text
Help me write a skill for [task I do often]. Interview me about how I do it now,
what goes wrong, and what good looks like. Then write the SKILL.md with a
description that says exactly when it should load.
```

Add an `evals/evals.json` with three or four test prompts and what a good answer must include, so you can check the skill still works after you edit it. See [skills/coach-me](../skills/coach-me/) in this repo for one.

## Write a hook

Start with one that blocks a mistake you actually made. Then test it both ways: confirm it blocks the bad thing AND lets the normal thing through. A hook you haven't seen fire is a hook you don't have. The kit's README shows how to test each one.

## Checkpoint

One hook in your settings that blocks a mistake you really made, and you've watched it block that mistake once and allow a normal command once.
