# Review and fix discipline

## Fix the pattern, not just the instance

When a bug is found, search the whole project for the same mistake before
calling it fixed. If one form forgot to check the user's login, the other
forms probably did too.

## Read before judging

Never comment on code you have not opened. Check line numbers against the
real file.

## Code safety

- No `as any` in TypeScript without a comment saying why it is safe.
- No `!` (non-null assertion) on a value that can really be missing.
- Independent async calls run together with `Promise.all`, not one by one in
  a loop.
- Never ignore an error silently. `catch (e) {}` with nothing inside is a bug.
- Expected problems (bad input, not found) and unexpected ones (database down)
  get different handling. Lumping them together hides real outages.

## Every bug fix gets a test

Write the test that would have caught the bug. Test the case that actually
broke, not only the happy path.

## Where a lesson goes

A correction is worth more than the one line it fixed, but only if it is
written down somewhere the next session will read:

- **A judgment call** (how to name things, when a pattern is wrong) goes in a
  rule file or the project's `CLAUDE.md`.
- **A repeatable mechanical mistake** (this exact input breaks, this value
  drifts) becomes a test next to the code. A paragraph does not fail CI.
- **The right move** becomes the default: a script, a template or a hook that
  makes the good path the easy one.

"I'll remember next time" is not a storage medium.

## Anchor a rule to what happened

Any rule, limit, timeout or magic number that could plausibly be different
gets a comment saying what happened that made it this value.

```js
// Bad: a reason nobody can check, so the next person changes it.
const MAX_UPLOAD_MB = 10; // big files are slow

// Good: the evidence. Now a reader knows what breaks if they raise it.
// A 40 MB sermon video timed out the upload route on the free hosting plan
// (30 second limit). 10 MB uploads finished in about 6 seconds.
const MAX_UPLOAD_MB = 10;
```

If you never measured it, say so: `// guessed, never measured`. That is honest
and tells the next reader how much the number is worth.

## Preview before you write

Anything that imports, syncs or bulk-edits data runs in two steps. First a
preview that changes nothing and shows what would happen. Then an apply that
does only what the preview showed. A bulk change should also have a way back.
