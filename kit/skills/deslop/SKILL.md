---
name: deslop
description: "Clean AI-written code before review: delete narration comments, swap hand-rolled helpers for the standard library, cut code nothing uses, and check every claim against the real diff. Use before a PR, when code feels AI-generated, or after a multi-file change."
---

# Deslop

Slop in code is a trust problem, not a style problem. A reviewer who spots one
AI tell stops reading the code and starts hunting for more. So every pass
below checks whether a line is needed, not just whether it looks fine.

Work from the actual diff (`git diff`, or `git diff main...HEAD` for a branch),
never from memory of what was written.

## Pass 0: build small, justify every line

Slop is cheapest to remove before it exists.

- **Build piece by piece.** Get the smallest change that does one thing
  correct first, then add the next piece. A big diff written in one go always
  collects slop. Small pieces also make small pull requests, which reviewers
  trust more.
- **Ask why each line exists.** Why a new function instead of an existing
  one? Why a new file? If the honest answer is "the AI wrote it that way",
  delete it or fold it in.
- **Do not overbuild.** The plain 5-line version beats the abstract 25-line
  version until a second caller exists. No "future flexibility" parameters,
  no wrapper types around one value.
- **Do not rebuild the wheel.** Before writing a helper, search the project
  for one and check `package.json` for a library that already does it.
- **Match the neighbors.** Read the files next to yours first and copy their
  naming, error handling and test style.

## Pass 1: comments

The biggest tell. One rule: **a comment must say something the code cannot
show.** Everything else goes.

Delete:

- Narration: `// loop over the entries`, `// call the helper`, `// return the result`
- Restating the code, or restating the function's own header
- Talk aimed at the reviewer: `// this is safe because we checked above`
- References to the pull request, the chat, or "recently changed"
- Section banners (`// ---- helpers ----`) in short files

Keep:

- Rules from outside the code: "this API rejects the request if `id` is missing"
- Why the obvious approach was not used, and what broke when it was tried
- Platform surprises: "this silently does nothing on Windows"
- Safety rules: "never cache this object, it contains the user's token"

Rough check, not a rule: in ordinary app code, more than about one comment line
per 15 added lines deserves a second look. Judge each comment by the lists
above, never by count alone.

## Pass 2: hand-written code the platform already provides

The second biggest tell: rewriting ID generation, hashing, date math, deep
copies, URL parsing.

1. Read `package.json` (or `requirements.txt`) to see what is already installed.
   Prefer what is there, or the language's built-ins, over anything new.
2. If you need a new package, pick the boring, widely used one.
3. Before swapping your version for a library, run both on the same inputs
   and compare the output. A swap that changes IDs or hashes breaks existing
   data silently.
4. Code that is already just built-ins glued together (`crypto.createHash`) is
   not hand-rolled. Leave it.

## Pass 3: does everything belong

- **The same condition written in several places:** pull it into one named
  variable (`hasNoChanges`, not `check1`).
- **The same literal value in several files:** one shared constant.
- **A private copy of a helper that already exists in the project:** delete
  yours, import theirs.
- **Dead code:** for every new function, type and export, find who uses it.
  If nothing uses it, delete it in this change instead of saving it for later.
- **The same fact stated twice** (header comment plus inline comment): keep one.

## Pass 4: tests

- A test pins the right behavior, not the bug. If an assertion expects a wrong
  value because "that is what the code returns", fix both.
- Use the same test helpers the rest of the suite uses.
- Name tests after the situation ("rejects an empty email"), not the code.

## Pass 5: verify

- Run the project's own formatter, linter and tests (`npm run lint`,
  `npm test`), not a global version that may differ.
- Read the final diff once more. Read every remaining comment out loud against
  Pass 1.
- Count comment lines against added lines:
  `git diff | grep -cE '^\+\s*(//|#|\*)'` and `git diff | grep -c '^+'`.
- Commit messages explain why, in a sentence, like a person wrote them. No
  bullet-list changelog for a three-line change.

## Reporting

When asked "is this clean?", answer from the live diff with evidence: what was
deleted, what was kept on purpose and why, and the comment count. Never "yes"
from memory.

When a reviewer calls something slop, agree with the pattern first, then fix
it everywhere it appears, including files they did not point at.

## For someone learning

Before running the passes, read your own diff and mark the three lines you
think are most likely slop. Then run the passes and compare. Then explain, in
one sentence each, why every comment you kept earns its place. If you cannot
say why, delete it.

## Credits

Adapted from the deslop skill by Carlton Aikins
(https://github.com/31Carlton7/skills), MIT License, see [LICENSE](LICENSE).
Rewritten in plainer words for beginners; the passes and their rules are his.
