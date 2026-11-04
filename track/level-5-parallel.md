# Level 5: run several agents at once

On a normal night I have several Claude sessions going at once, each on its own task. That's where the speed comes from, and also where it gets dangerous, because now you're a manager of agents and you can't watch all of them. Everything from levels 0 to 4 is what makes this safe.

## One task, one worktree

Two agents editing the same folder will overwrite each other. A git worktree is a second copy of your repo on its own branch, so each agent gets its own:

```bash
git worktree add -b feat/signup ../myapp-signup
cd ../myapp-signup && claude
```

When the branch is merged, remove it: `git worktree remove ../myapp-signup`. Claude Code can also do this for you when you ask for an isolated worktree.

## Split work so it doesn't collide

Before starting parallel agents, split the work by files, the same way Anchored split work by teammate in TEAM.md. Two agents should never need to touch the same file. If they would, run them one after the other instead.

Good to run in parallel: a new page plus an unrelated bug fix, research plus building, writing copy plus building the form it goes in.

Bad to run in parallel: two features that both change the same database table.

## Subagents for big reads

When a question needs reading lots of files ("where does the app send texts?"), have Claude send a subagent. It reads everything in its own context and brings back just the answer, so your main session stays clean and focused.

## Stay the one who knows what's true

This is where people lose the plot. Ten agents each say "done" and none of it is checked. So:

- Every agent ends by showing evidence: tests passing, a screenshot, a live link
- You read every diff before it merges to main. Skim if you must, but read it
- A separate reviewer agent checks each branch before you merge
- Keep a running list of what each agent is doing and what's left (Claude Code's task list, or a simple TODO.md)
- When an agent reports something, check it before you repeat it to anyone

## Know your limits

More agents isn't always faster. Each one needs your attention to review. Start with two. Add a third when reviewing two feels easy.

## Checkpoint

Two features built at the same time by two agents in two worktrees, each reviewed by a third agent, both merged by you after you read the diffs. Then explain both features without opening the code.
