# 6. How Anchored got built in one day

Anchored is a WhatsApp companion for someone in their first 30 days after baptism, with a dashboard for the person discipling them. Our team built it at the FaithTech SoCal x Baptize The World hackathon on Oct 24. The repo has 93 commits now, and most of the working app landed between 1:17pm and 4:13pm that day, from three people pushing to the same codebase.

## The pieces

| Piece               | What it does                                                                       | Tool                                                         |
| ------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| The app             | Web pages and the API, all in one project                                          | [Next.js](https://nextjs.org) 15, TypeScript                 |
| The brain           | Writes replies when a person texts something the script didn't plan for            | Claude, through the [Anthropic API](https://docs.claude.com) |
| The engine          | Decides which message goes out when: morning step, night check-in, the 3-day nudge | Plain TypeScript in `lib/engine.ts`                          |
| The words           | Every message and verse, with its source                                           | A JSON file, `content/moments.json`                          |
| The memory          | Who's signed up, what they answered                                                | Postgres database                                            |
| The WhatsApp bridge | Listens to a WhatsApp number and passes Anchored messages to the app               | A small Node script plus a WhatsApp command-line tool        |
| The dashboard       | What the discipler sees: who needs a check-in, no private details                  | Next.js pages, built by Anthony                              |
| Hosting             | Runs the app and database 24/7                                                     | Railway                                                      |

The thing to notice: **the AI is only one piece.** Most of what makes Anchored feel right is the script (the exact words, written by people) and the rules (nothing shared without a yes, hard moments go to a real person). Claude fills the gaps.

## How it went that fast

### 1. A spec first, before any code

The very first commit was `SPEC.md`: one page saying who it's for, what it does, what it never does. Every teammate's agent read it before doing anything.

### 2. Lanes

`TEAM.md` gave each person their own files. Anthony owned the dashboard and the bridge. Ogo owned the conversation script and the timing. I owned the engine and the AI. Each person's AI was told "only edit your files." Three people could push to `main` all afternoon without breaking each other's work.

### 3. One rules file for every AI

`AGENTS.md` (and `CLAUDE.md`, which just points at it) held the rules every AI followed. A few of them:

- Every Bible verse shown to a user carries its reference and comes from our content file. Never a verse from memory.
- Test data only. Fake names, fake phone numbers.
- Never commit a secret. Keys live in Railway's settings.

You'll want a file like this in every project. See [templates/CLAUDE.md](../templates/CLAUDE.md).

### 4. Script first, then code

Ogo isn't a coder. Ogo wrote the conversation as a script in plain English: exactly what Maria gets on day 1, before dinner with her dad, at 2am after she messes up. Then she told Claude "Make the WhatsApp agent send exactly what this doc says. Only edit these folders. Run it and show me the conversation." That's a great model for you as a non-coder: you own the words and the decisions, and the AI owns the code.

### 5. Security fixes right away

Five minutes after the first working backend, there's a commit that adds a shared secret to every API route and keeps phone numbers off the dashboard. Ask for this early: "Review this for anything a stranger on the internet could abuse, and anything that leaks personal info."

### 6. Ask real experts, then change the defaults

We had questions for the FaithTech folks and their pastor. When Travis from FaithTech answered, one commit applied all of it at once: nudge at 3 days, go quiet at 14, connection over reading. Ask the people who know, then let the AI apply what they said everywhere.

### 7. Deploy from minute one

The app was on Railway early, so every push was live. If you wait until the end to deploy, the end is when you find out it doesn't build.

## How to build something like it

Start smaller than Anchored, with something like this:

1. A form people fill out by text, one question at a time (Anchored has one of these now, in `lib/intake.ts`)
2. Saved to a database on Railway
3. A page for staff that shows the answers

Prompt to start it:

```text
I want to build [what] for [who] at my church. Write a one-page SPEC.md first:
who it's for, the one thing it does, what it must never do (especially with
people's personal info), and what done looks like. Ask me questions until the
spec is right. Don't write code yet.
```

Next: [Taste](07-taste.md)
