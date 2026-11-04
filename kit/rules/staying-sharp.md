# Staying sharp

The default way people use AI makes them worse. They paste the task, accept
the first answer, ship it unread, and a month later they cannot explain their
own app. The output is generic (slop) and the person has stopped thinking
(lost agency). This rule pushes the other direction. Speed is fine. Giving up
your judgment is not.

## The AI does the typing. You do the deciding.

- **Say your plan before the AI says its plan.** Two sentences: what you want
  and how you think it should work. Then compare. Where the AI's plan differs,
  ask why. That gap is where you learn.
- **Predict before you run.** Before running a command or a test, say what you
  expect to happen. Being wrong is the cheapest lesson available.
- **Read every diff before you accept it.** Not every character, but every
  file. If you cannot say in one sentence what a change does, ask until you
  can, or do not merge it.
- **Explain it back.** After a feature lands, explain how it works in your own
  words, out loud or in a note. If you cannot, the AI understood it and you
  did not.

## When Claude is teaching, it should teach

When the user is learning (new concept, first time with a tool, "why does this
work"), Claude:

- Explains the idea in plain words before writing code that uses it.
- Asks the user to make the next small decision when the choice is a good
  learning moment (which table, what to name it, where the check goes), and
  gives its own pick after.
- Points to the one line that matters in a diff instead of narrating all of it.
- Never hides a failure to keep the session smooth. A broken thing explained
  teaches more than a working thing that is a mystery.

When the user just needs it done (a deadline, a chore they already understand),
Claude does it fast and says so. The user decides which mode, and can say
"teach me" or "just do it" at any point.

## Iterate in small loops

Build the smallest version that works, run it, look at it, then add the next
piece. Ten small loops beat one giant prompt, because each loop is a chance to
notice the AI misunderstood you before it builds a whole app on the mistake.

## Get creative with the tool

The best users treat AI as a collaborator with range, not a vending machine:

- Ask for three different approaches and pick, instead of taking the first.
- Ask it to attack your plan ("what would break this?") before building.
- Ask what a professional in the field would do differently.
- Use it to learn the craft (how good sign-up forms work, how real churches
  handle check-in) before using it to produce anything.

## The test

At the end of a session, could you rebuild the core of what you made without
the AI, slowly? If not, ask it to walk you through the part you could not.
