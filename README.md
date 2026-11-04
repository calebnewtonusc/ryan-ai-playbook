# Ryan's AI playbook

Hey Ryan, it's Caleb! You asked me three things after the FaithTech hackathon: how I made the Anchored presentation, how we built Anchored so fast, and how Vercel, Railway, Claude and Cursor fit together. I figured a repo beats a screen recording, because you can come back to it, copy the prompts straight out of it, and point your own AI at it so it can coach you through it.

You don't need to know how to code to start. Everything here assumes you're starting from zero. Go in order, and don't skip the setup page, it's the one that saves you the most pain later.

Text me if you get stuck on anything. I mean it.

There are two parts. The [guide](guide/) gets you building, start to live link. The [AI-native engineer track](track/) is how you get good: six levels, each with a checkpoint you do without help, built on one belief I have. Being resourceful, efficient, iterative and creative with AI can be learned. By default people use AI to make slop and slowly hand over their own thinking. This repo is built to do the opposite, so you get sharper every month you use it.

The [kit](kit/) is a starter version of my own Claude Code setup (rules, hooks, skills and subagents), adapted from the kit I use every day. You'll install it piece by piece at level 4 of the track.

## Start here

| Step | Read this                                                                    | Time       | You'll have                                       |
| ---- | ---------------------------------------------------------------------------- | ---------- | ------------------------------------------------- |
| 1    | [The tools, and what to learn first](guide/01-tools.md)                      | 10 min     | A map of every tool and why it exists             |
| 2    | [Set up your computer](guide/02-setup.md)                                    | 45 min     | Claude Code running on your machine               |
| 3    | [Your first project, start to live link](guide/03-first-project.md)          | 1 to 2 hrs | A real site on the internet with your name on it  |
| 4    | [The loop: how to work with AI without building blind](guide/04-the-loop.md) | 15 min     | The habit that makes everything else work         |
| 5    | [How the Anchored presentation got made](guide/05-the-pitch-site.md)         | 15 min     | Answer to your question 1                         |
| 6    | [How Anchored got built in one day](guide/06-building-anchored.md)           | 20 min     | Answer to your question 2                         |
| 7    | [Taste: making it look good, not generated](guide/07-taste.md)               | 15 min     | The checklist I run before I show anyone anything |
| 8    | [Using AI for church operations](guide/08-church-ops.md)                     | 15 min     | Ideas sized for a Director of Operations          |

Then go up the levels in [track/](track/README.md):

| Level | You can |
| --- | --- |
| 0 | [Think with AI without losing your own thinking](track/00-stay-the-engineer.md) |
| 1 | [Ship a small thing](track/level-1-ship.md) |
| 2 | [Read what the AI wrote and catch it being wrong](track/level-2-read-and-verify.md) |
| 3 | [Give the AI the context it needs](track/level-3-context.md) |
| 4 | [Build your own setup: rules, skills, hooks, subagents](track/level-4-your-setup.md) |
| 5 | [Run several agents at once and still know what's true](track/level-5-parallel.md) |

Then keep these open while you work:

- [prompts/](prompts/): copy-paste prompts for planning, building, fixing, reviewing and writing
- [templates/CLAUDE.md](templates/CLAUDE.md): drop this in every new project so Claude knows your rules
- [skills/coach-me](skills/coach-me/SKILL.md): a skill that turns Claude into a coach for this playbook
- [kit/](kit/): my setup, adapted for you

## Let Claude teach you this repo

Once Claude Code is installed (step 2), you can do this:

```bash
git clone https://github.com/calebnewtonusc/ryan-ai-playbook.git
cd ryan-ai-playbook
claude
```

Then type: `Read CLAUDE.md and coach me through this playbook, starting where I am.`

It'll read the whole thing, ask what you've done so far, and walk you through the next step.

## The short version

If you only remember three things:

1. **Plan before code.** Ask the AI for a 5 bullet plan and read it before it writes anything.
2. **One small slice at a time.** Something you can see working in under 15 minutes.
3. **Make it show you.** It isn't done until you've seen it running with your own eyes.

All glory to God! ✝️❤️
