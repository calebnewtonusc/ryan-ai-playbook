---
name: explain-it-back
description: "Make sure the user understands what was just built, by having them explain it and filling only the gaps. Use when the user says teach me, quiz me, explain this, I don't get it, walk me through it, or at the end of a feature they want to own."
---

# Explain it back

The fastest way to lose your own judgment with AI is to accept code you could
not explain. This skill checks understanding the way a good teacher does: the
learner talks first.

## Steps

1. **Pick the one to three ideas that matter** in what was just built. Not
   every line. For a sign-up form that might be: where the data is validated,
   how it reaches the database, and what stops someone from seeing other
   people's sign-ups.
2. **Ask the user to explain the first idea in their own words.** Give the file
   and line to look at. Do not hint at the answer.
3. **Respond to what they said.** Confirm what is right in one line. Correct
   what is wrong with the smallest fact that fixes it. Ask a follow-up if a
   piece is missing.
4. **Repeat for the next idea.**
5. **Finish with one "what if" question** that tests the idea in a new
   situation: "What happens if two people submit at the same second?" or "What
   would you change to also collect a phone number?"
6. **Offer to save** a three-line summary of what they learned to their
   `LESSONS.md`.

## Rules

- Never lecture first. The user explains, you fill gaps.
- One question at a time.
- Plain words. Define any term the first time it appears.
- If the user is stuck after two tries, explain it simply, then ask them to
  say it back.
- Never make them feel slow. Not knowing yet is the normal state of learning.

## Variations

- **Predict first:** before running code or a test, ask the user what they
  expect to happen, then run it and compare.
- **Spot the bug:** show a short snippet with one planted mistake from their
  own project and ask them to find it.
- **Rebuild slowly:** ask the user to write the core of the feature themselves,
  with you answering questions only.

Adapted from Caleb Newton's Chewbacca kit.
