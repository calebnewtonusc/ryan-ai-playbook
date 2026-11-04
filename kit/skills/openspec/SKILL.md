---
name: openspec
description: "Write a plan as an OpenSpec change (proposal, requirements with WHEN/THEN scenarios, design, tasks) before any code, then build from the tasks and archive it. Use for spec it, plan this feature before building, or several agents building one feature."
---

# OpenSpec

Spec first, then code. The spec is plain Markdown in your repo, so the plan
gets read and argued with before anything is built, and every agent working on
the feature reads the same plan.

## Setup, once per repo

```sh
npm install -g @fission-ai/openspec@latest
openspec init
```

`init` creates an `openspec/` folder (specs and changes) and adds `/opsx:*`
commands for Claude Code. Your existing files stay. Run `git diff` after init
to see exactly what it added.

## The loop

1. **Explore** (`/opsx:explore`) when the approach is not settled yet. If you
   want to be pushed on the idea first, use the `grilling` skill, then feed
   what you settled into the proposal.
2. **Propose** (`/opsx:propose <change-name>`) writes
   `openspec/changes/<name>/` with:
   - `proposal.md`: why and what
   - `specs/`: requirements, each with WHEN/THEN scenarios
   - `design.md`: the approach
   - `tasks.md`: the checklist
3. **You read every file before any code is written.** For each requirement,
   say out loud whether you agree, and fix the ones you do not. This is the
   step where your judgment matters most. A wrong spec gets built exactly as
   written.
4. **Validate:** `openspec validate <name>` must pass. `openspec show <name>`
   prints the whole change.
5. **Apply** (`/opsx:apply`): build task by task and tick `tasks.md`. Each
   task should name the test or check that proves it is done, so several
   agents can each take a task without stepping on each other.
6. **Archive** (`openspec archive <name>`) once it is merged. The change's
   specs fold into `openspec/specs/`, which becomes the living record of what
   the system does.

## When not to

A one-line fix or a typo does not need a spec. If the plan fits in one
sentence and touches one file, just build it.

## Example scenario

```markdown
### Requirement: Sign-up rejects duplicate emails

#### Scenario: email already registered

- WHEN a visitor submits the sign-up form with an email that has an account
- THEN the form shows "That email already has an account. Log in instead?"
- AND no second account is created
```

A good scenario is specific enough that you could write the test from it.

## Credits

Uses OpenSpec by Fission AI (https://github.com/Fission-AI/OpenSpec), MIT
License, see [LICENSE](LICENSE).
