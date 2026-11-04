# 1. The tools, and what to learn first

You asked about Vercel, Railway, Claude and Cursor. Below is what each one does, plus the two I left out that you need first (a terminal and GitHub).

## The map

Think of building a web app like opening a coffee shop.

| Tool                                          | What it is                                                                   | Coffee shop version                         | Cost to start              |
| --------------------------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------- | -------------------------- |
| [Claude](https://claude.ai)                   | The AI you chat with in a browser or app                                     | The consultant you call for advice          | Free, Pro is $20/mo        |
| [Claude Code](https://claude.com/claude-code) | Claude, but it lives on your computer and can read, write and run your files | The contractor who actually builds the shop | Included with Claude Pro   |
| Terminal                                      | The text window where you type commands. Already on your Mac                 | The back door the contractor uses           | Free                       |
| [GitHub](https://github.com)                  | Where your code is saved, with every version kept forever                    | The blueprint archive                       | Free                       |
| [Vercel](https://vercel.com)                  | Puts a website on the internet with a real link                              | The storefront on the street                | Free for personal projects |
| [Railway](https://railway.com)                | Runs the parts that have to stay on: a database, a server, a bot             | The kitchen and the fridge in the back      | About $5/mo                |
| [Cursor](https://cursor.com)                  | A code editor with AI built in, where you can see and click through files    | A window into the construction site         | Free tier, Pro is $20/mo   |

## What to learn first, in order

1. **Claude in the browser.** You probably already use it. Keep using it for thinking, writing and planning.
2. **Terminal basics.** Just five commands: `cd`, `ls`, `pwd`, `open .`, and how to press up-arrow to rerun something. That's genuinely enough.
3. **Claude Code.** This is the big one. It's how Anchored got built. Learn this before anything else on this list.
4. **GitHub.** Claude Code will run the git commands for you. You just need an account and to know that "push" means "save it online."
5. **Vercel.** Your first deploy. A static site or a Next.js site, live in under five minutes.
6. **Railway.** Only once you need something that remembers things (a database) or runs all the time (a WhatsApp bot like Anchored's).
7. **Cursor.** Optional. Nice when you want to look at the files yourself. Claude Code doesn't need it.

## Vercel or Railway?

Both put your app on the internet. The difference that matters at your stage:

- **Vercel** is the easiest way to ship a website. Connect your GitHub repo and every push goes live. Pick this for landing pages, event pages, a church microsite.
- **Railway** runs anything, including databases and long-running programs. Anchored is on Railway because it has a Postgres database and a WhatsApp bridge that has to keep listening for messages.

If you're not sure, start on Vercel. You'll know you need Railway when you need a database.

## Accounts to make today

Each one takes two minutes. Use the same email for all of them.

- [claude.ai](https://claude.ai): sign up, then upgrade to Pro so you get Claude Code
- [github.com](https://github.com/signup): pick a username you'd be fine showing a pastor or an employer
- [vercel.com](https://vercel.com/signup): choose "Continue with GitHub" so they're linked
- [railway.com](https://railway.com): also "Continue with GitHub", but you can wait on this one

Next: [Set up your computer](02-setup.md)
