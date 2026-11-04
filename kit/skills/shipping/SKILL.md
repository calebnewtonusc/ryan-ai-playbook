---
name: shipping
description: "Get a change out safely: check for secrets, run typecheck, lint and tests, deploy from git, then check the live site. Use for ship it, is this ready, push, deploy, put it live, run the tests, or a failed build or deploy."
---

# Shipping

The expensive failures here are boring: a secret committed, a type error
nobody ran, a deploy from a folder full of half-finished edits. The steps
below catch all three before they reach users.

## 1. Check for secrets first

This goes first because it is the one mistake you cannot undo. A key pushed
to a public repo is compromised the moment it lands. Deleting the commit
afterward does not take it back.

```sh
git diff --cached --name-only | grep -E '(^|/)\.env' && echo "STOP: .env file staged"
git diff --cached | grep '^+' | grep -iE '(sk-[a-z0-9_-]{20,}|api[_-]?key|secret|password|token)\s*[=:]' \
  | grep -viE 'example|placeholder|your_|process\.env|os\.environ'
```

If a real secret shows up: stop, unstage it (`git restore --staged <file>`),
and say so plainly. If it was already pushed, the key must be rotated in the
service's dashboard. Removing it from git is not enough.

## 2. Run the gate

Look at the project before assuming anything. `package.json` means Node.
`pyproject.toml` or `requirements.txt` means Python, and a project with both
needs both sets of checks.

Run these in order, because each failure makes the next step's output noise:

1. **Typecheck:** `npm run typecheck`, or `npx tsc --noEmit`
2. **Lint:** `npm run lint`
3. **Tests:** `npm test` (or `pytest`)
4. **Build:** `npm run build`

Use the project's own scripts before a global tool. The project pins its
versions for a reason, and a different version on your machine lets failures
through that only show up on the server.

**Before you run each one, say what you expect: pass or fail, and if fail,
where.** Then run it. When your guess is wrong, that is worth one sentence of
thought about why.

**Report what actually happened.** If tests fail, show the output. If a step
was skipped because the script does not exist, say which. "All checks passed"
after a skipped test run is the most damaging sentence in this whole process,
because people believe it.

## 3. Writing tests

When asked to write tests, cover the case that was actually broken, not the
happy path that already worked. A test that passes both before and after the
fix proves nothing. Copy the style of the tests already in the project, and
name each test after the situation ("rejects an empty email").

## 4. Before you deploy

- The gate above passes with no errors
- No `.env` file staged, no secrets in code
- No hardcoded `localhost` URLs
- No leftover `console.log` debugging in important code paths
- Environment variables set in the host's dashboard (Vercel, Railway,
  Netlify), not only in your local `.env`
- If there is a UI, you looked at it at phone width (375px)

## 5. Deploy from git

Most hosts (Vercel, Railway, Netlify) deploy automatically when you push to
the main branch of a connected GitHub repo. Prefer that over deploying from
your laptop with a CLI command: what is live then always matches what is in
git, and you can roll back to any commit.

- Know which way your project deploys before doing anything. Pushing and then
  also running a deploy command can cause two deploys racing each other.
- If a push deploys nothing, check that the hosting service is actually
  connected to the repo and branch in its dashboard.

## 6. After you deploy

Open the live URL. Do the main thing a user does, once, start to finish.
Read the host's function or runtime logs for errors. "The deploy succeeded"
and "the page works" are different claims, and only the second one matters.

## 7. Pushing

- Commit messages explain why, in a sentence, like a person wrote them.
- On the main branch with a non-trivial change? Make a branch first
  (`git switch -c fix/short-name`).
- Stage files by name (`git add src/page.tsx`), not `git add .`, so a stray
  `.env` or a giant file never rides along.
- Never force-push over a branch someone else may have pulled without saying
  so out loud first.

## For someone learning

Before running the gate, write one line: "I think this is ready because..."
After the gate and the live check, read your line again. Was the reason you
gave the reason it turned out to be safe? The habit you are building is
knowing why something works, not just that a command printed green.
