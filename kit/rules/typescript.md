# TypeScript rules

TypeScript catches a whole class of bugs before you run the code, but only if
you let it.

## The bar

Run `npx tsc --noEmit` before calling anything done, and expect zero errors.

`strict: true` stays on in `tsconfig.json`.

## Outside data is unknown until checked

Anything from an API response, a form, `JSON.parse` or a request body is typed
`unknown` and checked before use. Zod is the usual tool:

```ts
import { z } from "zod";

const signUpSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  ministry: z.enum(["kids", "worship", "hospitality"]),
});

const parsed = signUpSchema.safeParse(body);
if (!parsed.success) {
  return Response.json({ error: parsed.error.flatten() }, { status: 400 });
}

// Derive the type from the schema instead of writing it twice.
type SignUp = z.infer<typeof signUpSchema>;
```

Every API route validates its body like this.

## Supabase

Use the generated types so queries are checked:

```ts
const { data, error } = await supabase
  .from("events")
  .select("*")
  .eq("id", id)
  .single();
if (error) throw new Error(error.message);
```

Regenerate types after any schema change:
`npx supabase gen types typescript --project-id <id> > src/types/supabase.ts`

## Next.js App Router

- Components are Server Components by default. Add `"use client"` only when
  you need state, effects, event handlers or browser APIs.
- Every page exports `metadata` with a title and description.

## Avoid

- `as any`. Use `unknown` and check it.
- `!` on a value that can really be null. Check first.
- `require()`. Use `import`.
- `// @ts-ignore` without a comment explaining the real problem.
