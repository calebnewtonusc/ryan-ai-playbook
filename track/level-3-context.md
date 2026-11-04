# Level 3: context is the whole game

When AI gives you a bad answer, it's usually not a dumb model. It's missing context. Claude starts every session knowing nothing about you, your church, your project or your rules. Whatever you put in front of it is all it has. The engineers who get great results from AI are mostly great at context.

## The files that carry context

Every serious project of mine has these, and the Anchored repo had all of them by 2pm on hackathon day:

- **SPEC.md**: what we're building, for who, what it never does
- **CLAUDE.md**: rules Claude reads automatically every session ([template](../templates/CLAUDE.md))
- **AGENTS.md**: the same rules for other AI tools like Codex and Cursor. CLAUDE.md can just say "read AGENTS.md" so you keep one copy
- **TEAM.md** (when more than one person builds): who owns which files
- **docs/decisions.md**: decisions already made and why, so nobody re-argues them

Test it: open a fresh Claude session and say "Read the repo docs and build [next feature]." If it gets it right without you explaining anything, your context is good. If it asks stuff that's already decided, write the answer into a file.

## Give it the real thing

Don't describe what you want when you can show it:

- Paste the exact error instead of "it broke"
- Give it the real spreadsheet, the real email, the real web page instead of describing them
- Point it at a site you love instead of "make it look nice"
- Give it the docs page for the tool instead of trusting its memory

## Research before building

Before making anything in a genre that has experts (a landing page, a pitch, an email, a demo video), spend ten minutes learning what the experts say separates good from bad. Then write those rules into the project before building. I learned this the hard way: I once had an agent record a product demo that showed every feature, and the first rule in every guide on demos is "show one to three features, never more."

```text
Before we build: find what people who make [landing pages] for a living say
separates a great one from a bad one. Give me 5 concrete rules, with sources.
```

## Keep sessions focused

Long chats get worse. The model starts mixing up old instructions with new ones.

- One task per session. `/clear` when you switch tasks
- When a session gets long, ask it to write a summary into a file, then start fresh and point at the file
- If it keeps making the same mistake, the fix is a sentence in CLAUDE.md, not arguing harder

## Plan mode

Claude Code has a plan mode (press Shift+Tab to cycle modes) where it reads and plans but can't edit files. Use it for anything bigger than a small fix. Read the plan like a contract before you approve it.

## Checkpoint

A project where a brand-new Claude session, given only "read the docs and build the next item in SPEC.md," builds it correctly without you explaining anything.
