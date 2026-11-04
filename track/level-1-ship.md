# Level 1: ship a small thing

Guide steps [2](../guide/02-setup.md), [3](../guide/03-first-project.md) and [4](../guide/04-the-loop.md) are this level. Do them first. This page adds what turns "I followed the steps" into "I can do this."

## Write the spec yourself

Let the AI ask you questions, but write SPEC.md in your own words. The spec is where all the thinking lives: who it's for, the one thing it does, what it never does, what done looks like. If the AI writes your spec, the AI owns your project.

A good spec fits on one screen. Here's the shape:

```markdown
# Welcome Tea sign-up

For: a CSUN student who visited Every Nation City Church for the first time on Sunday.
Does: lets them sign up for Welcome Tea and Coffee from their phone in under 30 seconds.
Never: asks for more than name and phone, shares their info outside the follow-up team.
Done: a live link, tested on my phone, and one real sign-up in the sheet.
```

## Ship ugly first, then make it good

Get it live with the plainest version that works, then improve it. A live ugly page teaches you more than a beautiful page on your laptop, because you find out what breaks when it's real (phones, slow wifi, someone typing their name in all caps).

## Learn the five git words

Claude will run git for you, but you need to know what's happening:

- **commit**: save a snapshot with a note about what changed
- **push**: upload your snapshots to GitHub
- **pull**: download what changed on GitHub
- **branch**: a separate copy to try something without breaking the main one
- **diff**: exactly what changed, line by line

Ask: "Show me the diff of what you just changed, and explain each part." Do it every time for a week.

## Know where it runs

For everything you ship, be able to answer: where is the code (GitHub), where does it run (Vercel or Railway), where is the data (a database, a sheet), and where are the secrets (Vercel or Railway settings, never the code).

## Checkpoint

A live link, built from a SPEC.md you wrote, that a real person used. Then explain to someone (me works) every step from your laptop to their phone.
