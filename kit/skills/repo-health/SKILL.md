---
name: repo-health
description: "Find what has rotted in a project: dead code, unused packages, outdated or vulnerable dependencies, env variable drift, what is safe to delete. Use for clean this up, audit this repo, check my dependencies, or before handing a project to someone."
---

# Repo health

Four kinds of rot, each with a check you can run. Run the checks, then judge
what the output means. None of these tools is right often enough to act on
blindly.

## Dead code

```sh
npx depcheck                                   # packages installed but never imported
npx ts-unused-exports tsconfig.json            # exports nothing imports
grep -rn 'TODO\|FIXME\|HACK' --include='*.ts' --include='*.tsx' . | grep -v node_modules
grep -rn 'console\.log' --include='*.ts' --include='*.tsx' . | grep -v node_modules
```

**Confirm before deleting.** An export nothing imports may still be loaded by a
framework by its file name (Next.js pages and routes work this way). Search the
name across the whole project, config and docs included, before removing it.

## Dependencies

```sh
npm audit --audit-level=moderate     # known security problems
npm outdated                         # packages with newer versions
```

Treat a vulnerability report as a claim to check. A problem in a build-only
tool is not the same risk as one in code that handles requests. Upgrading
everything at once to clear the report can break more than it fixes. Upgrade
one package at a time and run the app after each.

## Environment variables

Compare `.env.example` with what the code reads (`grep -rn 'process.env' src`).
Look for variables the code uses that the example never mentions (every new
setup breaks on them), and documented variables nothing reads any more.
**Never print a value**, only names.

## Structure

Files over a few hundred lines doing several unrelated jobs, the same text or
number copied into several files (make it one constant), and private copies of
a helper that already exists in the project.

## Reporting

Group findings by what they cost, not by which tool found them. Something that
breaks a new person's first setup outranks a stale TODO. Say which findings you
confirmed by reading the code and which are raw tool output that still needs a
look.

Adapted from Caleb Newton's Chewbacca kit.
