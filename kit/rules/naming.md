# Naming conventions

Consistent names make code readable for you, for teammates, and for the AI.

## Files

- React components: `PascalCase.tsx` (`MemberCard.tsx`, `SignUpForm.tsx`)
- Hooks: `useSomething.ts` (`useMembers.ts`)
- Utilities: `camelCase.ts` (`formatDate.ts`)
- Next.js pages and routes: `page.tsx`, `layout.tsx`, `route.ts` inside a
  folder named for the URL (`app/events/page.tsx`, `app/api/events/route.ts`)

## Code

- Variables and functions: `camelCase`
- Types and components: `PascalCase`
- True constants and env vars: `SCREAMING_SNAKE_CASE`
- Booleans start with `is`, `has`, `can`, `should` (`isLoading`, `hasPaid`)
- Event handlers start with `handle` (`handleSubmit`)
- Props types: `ComponentNameProps`

## Database

- Tables: `snake_case`, plural (`members`, `volunteer_shifts`)
- Columns: `snake_case` (`created_at`, `member_id`)

## URLs and JSON

- API routes: `kebab-case`, plural nouns (`/api/volunteer-shifts`)
- Query params and JSON keys: `camelCase`

## Avoid

- Made-up abbreviations (`usr`, `btn`, `cnt`). `id`, `url`, `html` are fine.
- Vague names: `data`, `info`, `stuff`, `thing`, `temp`. Say what it holds.
- Single letters outside a short loop.
