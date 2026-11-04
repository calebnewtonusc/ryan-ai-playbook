# Level 2: read what the AI wrote, and catch it being wrong

This is the level that separates engineers from people pressing a button. AI writes code faster than anyone can read it, so most people stop reading. Then something breaks, they can't fix it, and they're stuck asking the AI to fix its own mistake in a loop.

You don't need to be able to write every line. You need to be able to read it, roughly the way you can read a contract without being a lawyer.

## Learn to read code

Pick any file Claude wrote and ask:

```text
Walk me through this file top to bottom like a tour guide. For each part:
what it does, why it's there, and what would break if I deleted it.
```

Then close the chat and explain the file to yourself out loud. Do this with one file a day. In a month you'll read code comfortably.

The basics worth learning properly, one at a time, with Claude as a tutor:

- Variables, functions, if/else, loops
- What HTML, CSS and JavaScript each do on a page
- What an API is (one program asking another for data)
- What a database table is (a spreadsheet the app can read and write)
- How to read an error message and a stack trace

Tutor prompt:

```text
Teach me [concept] using an example from a church sign-up app. Give me a tiny
exercise, wait for my answer, then tell me what I got wrong.
```

## Debug in order

When something breaks, follow this order and don't skip:

1. Read the whole error, every word. "undefined" and "null" are different bugs.
2. Find the file and line it points to.
3. Check what you assumed. What did you expect this value to be? Print it.
4. Look at what changed since it last worked (`git diff`). The bug is usually in the diff.
5. Only then ask the AI, and paste the exact error plus what you already checked.

The order matters because it keeps you thinking. "Fix it" with no context is how you end up in an AI loop.

## Make it prove things

Never trust "done." Trust evidence:

- "Run it and show me the output"
- "Write a test that would fail if this bug came back, run it, show me it passing"
- "Open the page at phone width and screenshot it"
- "What's one input that would break this? Try it."

## Get a second opinion

Have a different session review the work, with no context of how it was built:

```text
Review this diff like a senior engineer who didn't write it. Find bugs, security
holes and anything that leaks personal info. Rank them worst first. Don't fix yet.
```

Then you decide which findings are real. The [code-reviewer agent in kit/](../kit/agents/) does this for you once you set it up.

## Checkpoint

Find one real bug in AI-written code and explain why it's a bug, before you ask the AI to fix it.
