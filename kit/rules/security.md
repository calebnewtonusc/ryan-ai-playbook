# Security rules

Church tools hold names, phone numbers, kids' info, giving records and
addresses. Treat every one of those like it belongs to someone who trusted you
with it, because it does.

## Secrets

- Secrets (API keys, database passwords, tokens) live in `.env` only, and
  `.gitignore` lists `.env`. Code reads them with `process.env.NAME`.
- Document every variable in `.env.example` with a fake value, so the next
  person knows what to set.
- Never paste a real key into code "just to test." That is exactly how keys
  get pushed. (The `protect-secrets.sh` hook blocks this.)
- Never log a secret, a password, or personal data, not even while debugging.

## Database

- Never build SQL by gluing user input into a string. Use the library's
  parameters (`.eq("id", id)` in Supabase, `$1` placeholders in plain SQL).
  Gluing strings is how SQL injection happens.
- Several writes that must all succeed or all fail go in a transaction.

## Who can see what

- Never trust an ID the browser sends without checking the logged-in user is
  allowed to touch that record. Example: `/api/members/42` must check that
  the caller can see member 42, not just that they are logged in.
- Every page that shows personal data requires login. Every query that
  returns rows filters to what that user may see.

## Input

- Treat data from a form, an API or a file as unknown until you have checked
  its shape (Zod is the usual tool in TypeScript).
- Never put raw user text into HTML with `dangerouslySetInnerHTML`.
- Never run `eval()` on anything a user typed.

## Before merging anything that touches login, payments or personal data

- [ ] No secrets in code or logs
- [ ] IDs checked against the logged-in user
- [ ] Queries use parameters
- [ ] Error messages shown to users do not reveal internals (stack traces,
      table names, file paths)
