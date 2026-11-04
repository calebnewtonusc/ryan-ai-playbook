---
name: stack-rules
description: "Standards for Next.js, React, Supabase and Vercel work: components, API routes, database schema and RLS, state, accessibility, performance, tests and deploys. Use when writing, reviewing or auditing code in that stack, or before shipping it."
---

# Stack rules

Standards for the stack most beginner web apps use: Next.js (App Router),
React, Tailwind, shadcn/ui, Supabase and Vercel. Read the section for the area
you are touching, not the whole file.

These are the expected output, not one option among several. If a rule truly
does not fit the project, say so and why, instead of quietly ignoring it.

**Before asking the AI to build in an area, read that section and pick the one
rule you think your feature is most likely to break.** Check that rule
yourself when the code comes back.

## Components

- Use shadcn/ui for buttons, inputs, dialogs, selects and dropdowns
  (`npx shadcn@latest add button`). Do not hand-build these primitives.
- Tailwind classes only. No inline `style={{...}}`.
- Icons from `lucide-react`.
- Every component that loads data has three extra states: **loading** (a
  skeleton the same shape as the content), **empty** (a message and the next
  action, never a blank area), and **error** (what went wrong and a retry).
  Never render `null` on error.
- Keep logic out of JSX. Move it into a handler or a hook.
- A component over about 200 lines usually wants splitting.

## API routes

- Routes live at `app/api/<resource>/route.ts`.
- Validate every request body with Zod before using it:

```ts
const schema = z.object({ name: z.string().min(1), email: z.string().email() });
const parsed = schema.safeParse(await req.json());
if (!parsed.success) {
  return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
}
```

- Same response shape everywhere: `{ data }` on success, `{ error }` on
  failure.
- Status codes: 200 ok, 201 created, 400 bad input, 401 not logged in, 403 not
  allowed, 404 not found, 409 duplicate, 500 server error.
- Check who is calling on every route that touches user data:
  `const { data: { user } } = await supabase.auth.getUser()`, and return 401
  if there is no user.
- Never send stack traces to the browser. Log them on the server.
- Never log request bodies that contain passwords or tokens.

## Database (Supabase)

- **Turn on Row Level Security for every table**, with explicit policies. A
  table without RLS can be read by anyone holding your public key, which is
  every visitor to your site.

```sql
alter table posts enable row level security;
create policy "read own posts" on posts for select using (auth.uid() = user_id);
create policy "insert own posts" on posts for insert with check (auth.uid() = user_id);
```

- Names: tables plural `snake_case` (`blog_posts`), columns `snake_case`,
  foreign keys `<thing>_id`.
- Every table: `id uuid default gen_random_uuid() primary key` and
  `created_at timestamptz default now()`.
- Change the schema with migrations (`supabase migration new <name>`, then
  `supabase db push`), not by clicking in the dashboard, so the change lives
  in git.
- Generate types after schema changes:
  `npx supabase gen types typescript --project-id <id> > src/types/supabase.ts`
- Queries: always check `error`, select named columns instead of `*`, and add
  `.limit()` or pagination.
- Add an index on columns you filter or sort by.
- The service role key never reaches the browser. It bypasses every RLS
  policy.

## State

Use the lowest level that works:

1. Data from the database or an API: React Query or SWR (or a Server
   Component, with no client state at all)
2. Filters, tabs, pages: the URL (`useSearchParams`), so a link reproduces
   the view
3. One component's own state: `useState`
4. Shared UI state (a sidebar, a toast): Zustand or Context
5. Forms: React Hook Form with a Zod schema

Never copy server data into a global store. Never store a value you can
compute from other state.

## Accessibility

- Use real elements: `<button>` for actions, `<a>` for navigation, `<label>`
  for every input. A placeholder is not a label.
- Text contrast at least 4.5:1 (3:1 for large text). Check with your
  browser's dev tools.
- Never remove the focus outline without a visible replacement. Tab through
  the page once with the keyboard only.
- Images get `alt` text. Decorative ones get `alt=""`.
- Never rely on color alone to show meaning (an error also gets text or an
  icon).
- Respect reduced motion: `motion-safe:` and `motion-reduce:` in Tailwind.

## Performance

- `next/image` for images, with `width` and `height` set. `priority` on the
  main image above the fold.
- `next/font` for fonts.
- Server Components by default. Add `"use client"` only for hooks, event
  handlers or browser APIs, and keep it as deep in the tree as possible.
- Do not fetch in `useEffect` what a Server Component could fetch.
- Targets: largest paint under 2.5s, layout shift under 0.1, response to a tap
  under 200ms. Run Lighthouse in Chrome dev tools to check.

## Tests

- Every bug fix gets a test that would have caught the bug.
- Test the error case that actually broke, not only the happy path.
- Unit tests make no real network calls. Mock them.
- End-to-end tests with Playwright (`npx playwright test`) for the main user
  flow before a release.

## Deploying to Vercel

- Connect the GitHub repo in Vercel and deploy by pushing. Every branch gets a
  preview URL, and `main` goes to production.
- Environment variables go in the Vercel dashboard. Anything starting with
  `NEXT_PUBLIC_` is visible to every visitor, so never put a secret there.
- Before production: `npm run build` and `npm run lint` pass, no `.env` staged,
  no `localhost` URLs, no debug logging.
- After: open the live URL, run the main flow once, and read the function logs.

## Pre-ship audit

Grade the project on each, and list findings with file and line:

1. **Security:** no secrets in code, RLS on every table, every user-data route
   checks the caller, no unsanitized `dangerouslySetInnerHTML`
2. **Types:** no `any`, outside data checked with Zod
3. **Errors:** every async call handles failure, users see friendly messages
4. **Performance:** no fetching in loops, images optimized
5. **Code quality:** no dead code, no leftover `console.log`
6. **Design:** hover and focus states on everything clickable, loading, empty
   and error states present, works at 375px phone width
