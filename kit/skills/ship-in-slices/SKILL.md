---
name: ship-in-slices
description: "Take a feature from request to merged pull request: understand the ask, research it, cut it into small pieces, build each, prove it works in the real app, review, then open the PR. Use for add X, build a page for Y, change how Z works."
---

# Ship in slices

Most bad AI-built features are not bad code. They are fast code built on a
wrong reading of the request. So spend the start of the task removing
ambiguity, spend the end producing proof someone can check, and keep the
middle small.

## 1. Restate the ask

Write two sentences: what changes for the person using the app, and where.
If you cannot, you do not understand the request yet.

List every explicit requirement and every "don't". You will check the finished
diff against this list at the end.

## 2. Research before code

- **Where does this live?** The files, data and tests involved, and the nearest
  existing feature that does something similar. New code should be built the
  way its neighbor was built.
- **Has this been tried?** Search the git log and project notes. A feature that
  was removed was removed for a reason.
- **What does good look like?** For anything with a craft (a sign-up form, a
  calendar, an email), look at two or three real products that do it well.

Write down what the request did not specify and the assumption you are making
for each. If a wrong assumption would change the shape of the work, ask before
building.

## 3. Cut it into slices

A slice is a piece that works on its own and could merge alone. A database
table nothing uses yet is a slice. The page that uses it is the next slice.

For each slice, write before building:

- the one-sentence pull request title,
- what will be true when it merges,
- **the proof**: "a screenshot of the form after a successful submit", "the
  test output", "the row showing up in the database".

If you cannot name the proof, the slice is too vague.

## 4. Build the smallest working version

Make it work end to end in the plainest way, run it, then improve. Match the
style of the files around it.

## 5. Prove it works

Run the real app and do what a user would do. Capture the proof you named in
step 3 and look at it yourself. A green test suite is not proof the page looks
or behaves right. If the proof fails or looks bad, say so. A reported failure
costs one message. A false "it works" costs trust in every future one.

## 6. Review, then open the PR

Run the `reviewing-changes` skill or the `code-reviewer` agent on the diff, fix
what is real, rerun the proof. Check the diff against the list from step 1.
Then open the pull request with the title, what changed, how you proved it,
and the proof attached.

## For someone learning

At step 3, write the slice list yourself before asking the AI for its version.
Slicing work is a core engineering skill, and it only develops when you try
first.

Adapted from Caleb Newton's Chewbacca kit.
