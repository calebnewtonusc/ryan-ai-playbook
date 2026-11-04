# 4. The loop: how to work with AI without building blind

This is the exact loop our team used at the hackathon. It's copied from the `docs/how-we-build.md` file in the Anchored repo, which every teammate followed that day, whether they used Claude Code or Codex.

The biggest mistake beginners make is asking for the whole thing at once ("build me a church app") and then not knowing what came back. This loop fixes that.

## The loop, every time

1. **Plan before code.** Start each piece with: "Read [the spec file]. In 5 bullets, tell me your plan for [the one thing]. Don't write code yet." Read the plan, push back on anything off, then say go.
2. **One small slice.** Ask for one thing you can see in under 15 minutes: one screen, one message flow, one button. Never "build the dashboard."
3. **Make it show you.** End every ask with "then run it and show me it working." A screenshot, the page at phone width, or the output. If it says done without showing you, it isn't done.
4. **Commit when it works.** "Commit this with a message that says what changed." Now you can always go back.
5. **Stuck for 10 minutes means change something.** Paste the exact error. If that doesn't fix it, ask a person and work on a different slice meanwhile.

## Guided mode (great when you're new)

Paste this at the start of a session:

```text
Work in guided mode. Before each step, give me two or three options as a
multiple choice, with your pick and one line on why. Wait for my answer,
then build it and show me it running.
```

You'll learn way faster this way because you make every decision and see why.

## Write the spec first

Before Anchored had a single line of code, the first commit (1:17pm) was a one-page `SPEC.md`: who it's for, what it does, what it never does. Every prompt after that started with "Read SPEC.md". That's why five people could build on one app in an afternoon without stepping on each other.

For your projects, make a `SPEC.md` with:

- Who it's for (one real person, by name if you can)
- The one thing they do with it
- What it must never do
- What "done" looks like

## Rules file

Put a `CLAUDE.md` in every project. Claude Code reads it automatically every time you start. Use [templates/CLAUDE.md](../templates/CLAUDE.md) as your starting point.

Next: [How the presentation got made](05-the-pitch-site.md)
