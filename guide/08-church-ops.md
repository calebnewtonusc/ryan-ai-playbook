# 8. Using AI for church operations

You're Director of Operations at Every Nation City Church and a campus intern at CSUN. Operations is where AI saves the most hours, because so much of it is the same task every week. I don't know your exact tools yet, so these are written as "if you use X." Tell me what you actually use and I'll help you pick the first one.

## Start with what repeats

Write down everything you do every week. The best first project is the one that's annoying, repetitive, and low risk if it goes wrong.

Prompt (in Claude in the browser, no code needed):

```text
I'm Director of Operations at a church of [size] in LA. Here's everything I do
in a normal week: [list]. Which three could AI or a small tool take off my plate,
ranked by hours saved and how risky it would be if it made a mistake?
For each, tell me the simplest version I could build or set up myself.
```

## Ideas that fit a church

**No code at all (Claude in the browser):**

- Turn sermon notes into a small group discussion guide
- Draft the weekly announcement email from a bullet list
- Rewrite the "new here" page so a first-time visitor gets it in 20 seconds
- Turn a messy spreadsheet of volunteers into a clean Sunday schedule

**Small builds with Claude Code:**

- A sign-up page for an event, deployed on Vercel (guide step 3)
- A page that reads your volunteer spreadsheet and shows each person their next serving date
- A text-based check-in for new visitors, like Anchored's intake: one question per text, answers saved for the follow-up team

**If you use Planning Center** (a lot of churches do): it has an API, which means Claude Code can read your people and event data and build reports on it. Start read-only.

**If the church site is on Squarespace** (yours looks like it is): Claude can't edit Squarespace directly, but it can write the copy and the layout plan, and you paste it in.

## Rules for anything touching people's info

These come straight from how we built Anchored:

- Nothing gets shared without the person's yes
- Hard pastoral moments go to a real person, never the AI
- Test with fake names until you're sure it works
- Keep passwords and API keys out of your code and out of chats
- Ask your lead pastor before anything new talks to congregants

## The campus side

For CSUN, think about the first 30 days after a student visits. That's the exact gap Anchored was built for, just for baptism instead of a first visit. If you ever want to try Anchored or something like it at Every Nation, I'd love to talk about it.
