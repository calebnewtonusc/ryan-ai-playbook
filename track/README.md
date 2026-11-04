# The AI-native engineer track

The guide in [guide/](../guide/) gets you building. This track is how you get good.

I believe being resourceful, efficient, iterative and creative with AI can be learned, and that belief is why this repo exists. By default, people use AI to make slop, and slowly hand over their thinking until they can't do the work without it. I'm trying to build toward the opposite. An AI-native engineer uses AI to think harder, see further and ship more, and gets sharper every month instead of duller.

So every level here has two halves: what to make the AI do, and what you keep doing yourself.

## The levels

| Level | You can                                                | Read                                                     | Checkpoint (do it without help)                                                                |
| ----- | ------------------------------------------------------ | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 0     | Think with AI without losing your own thinking         | [00-stay-the-engineer.md](00-stay-the-engineer.md)       | Write a plan yourself, then compare it with Claude's and say which parts of each were better   |
| 1     | Ship a small thing with Claude Code                    | [level-1-ship.md](level-1-ship.md)                       | A live link built from a SPEC.md you wrote                                                     |
| 2     | Read what the AI wrote and catch it being wrong        | [level-2-read-and-verify.md](level-2-read-and-verify.md) | Find and explain one real bug in AI-written code before the AI does                            |
| 3     | Give the AI context so it gets it right the first time | [level-3-context.md](level-3-context.md)                 | A project where a fresh Claude session builds the next feature correctly from your files alone |
| 4     | Build your own setup: rules, skills, hooks, subagents  | [level-4-your-setup.md](level-4-your-setup.md)           | One hook that blocks a mistake you actually made, tested                                       |
| 5     | Run several agents at once and still know what's true  | [level-5-parallel.md](level-5-parallel.md)               | Two features built in parallel by two agents, both reviewed and merged by you                  |

Don't rush the levels. Level 2 is the one most people skip, and it's the one that decides whether you're an engineer or a person pressing a button.

The [kit/](../kit/) folder is a starter version of my own setup. You'll install pieces of it at level 4.

## How to know it's working

Every month, ask yourself honestly:

- Can I explain how my last project works without opening it?
- Did I catch the AI being wrong at least once this week?
- Is there a mistake I used to make that my setup now blocks?
- Did I build something I couldn't have built last month?

If the answers are yes, you're getting sharper. If you can't explain your own project, slow down and go back to level 2.
