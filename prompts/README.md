# Prompts

Copy, fill in the brackets, paste. Most of these come from `docs/how-we-build.md` in the Anchored repo, the file our team worked from at the hackathon.

## Start a project

```text
I want to build [what] for [who]. Write a one-page SPEC.md first: who it's for,
the one thing it does, what it must never do, and what done looks like. Ask me
questions until it's right. Don't write code yet.
```

## Plan

```text
Read SPEC.md and CLAUDE.md. What's the smallest version of [x] I can see working
in 15 minutes? Plan only, 5 bullets.
```

## Guided mode

```text
Work in guided mode. Before each step, give me two or three options as a multiple
choice, with your pick and one line on why. Wait for my answer, then build it and
show me it running.
```

## Build

```text
Do step 1 of that plan. Only edit [these files]. Then run it and show me it working.
```

## Fix

```text
Here's the exact error: [paste the whole thing]. Find the cause before changing anything.
```

## Explain (so you actually learn)

```text
Explain what you just changed like I'm smart but have never coded. Which file,
what it does, and why you did it that way instead of another way.
```

## Review

```text
Look at this like a pastor using it for the first time on a phone. What would confuse them?
```

```text
Review this for anything a stranger on the internet could abuse, and anything
that leaks someone's personal info. Fix the worst one first.
```

## Copy

```text
Rewrite this message so a brand-new believer reads it in 20 seconds. Keep the
Bible verse and its reference exactly as written.
```

## Ship

```text
Commit this with a message that says what changed, push it to GitHub, and tell me
the live link once Vercel finishes deploying.
```

## Pitch page

```text
Read SPEC.md and my demo script. Make a one-scroll pitch page where each beat is
one full-screen scene. Big type that reads from the back of a room. No decorative
animations. Build scene 1 only and show me it at desktop and phone width.
```
