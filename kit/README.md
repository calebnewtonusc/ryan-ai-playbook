# Starter kit for Claude Code

A ready-to-install setup for Claude Code: standing instructions, rules,
helper agents, safety hooks and skills. Adapted from Caleb Newton's Chewbacca
kit, cut down and rewritten for someone new to code who wants to become an
AI-native engineer.

The idea behind every piece: by default, people using AI produce generic work
(slop) and slowly stop thinking for themselves. This kit pushes the other way.
The AI moves fast, and you stay the one who understands, decides and checks.

## What is in here

```
kit/
  CLAUDE.md                  your standing instructions, read every session
  rules/                     the standards Claude follows
  agents/                    specialist helpers Claude can hand work to
  hooks/                     scripts that run automatically and can block mistakes
    settings.example.json    the settings that switch the hooks on
    test-hooks.sh            proves each hook blocks and allows the right things
  skills/                    step-by-step playbooks Claude loads when relevant
```

## Install

Claude Code keeps your personal setup in a hidden folder called `~/.claude`
(`~` means your home folder). Installing this kit means copying files there.
Open the Terminal app, go to the folder this repo is in, and run these one at
a time.

```bash
brew install jq
```

Installs `jq`, a small tool the hooks use to read the messages Claude Code
sends them. (Needs Homebrew from https://brew.sh. Skip if you already have it.)

```bash
mkdir -p ~/.claude/rules ~/.claude/agents ~/.claude/hooks ~/.claude/skills
```

Creates the folders Claude Code looks in, if they do not exist yet.

```bash
[ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup
```

Backs up your current `CLAUDE.md`, if you have one, so nothing is lost.

```bash
cp kit/CLAUDE.md ~/.claude/CLAUDE.md
```

Installs the standing instructions. Open it afterward and fill in the "Who you
are working with" section.

```bash
cp kit/rules/*.md ~/.claude/rules/ && cp kit/agents/*.md ~/.claude/agents/
```

Copies the rules and the agents.

```bash
cp -R kit/skills/* ~/.claude/skills/
```

Copies every skill folder.

```bash
cp kit/hooks/*.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/*.sh
```

Copies the hook scripts and marks them as programs that are allowed to run.

### Switch the hooks on

Hooks only run once your settings file lists them. Your settings live in
`~/.claude/settings.json`.

- **If you do not have that file yet:**

  ```bash
  cp kit/hooks/settings.example.json ~/.claude/settings.json
  ```

  Uses the example as your settings file.

- **If you already have one:** do not overwrite it. Open both files and copy
  the `"hooks"` block (and the `"deny"` lines, if you want them) from
  `settings.example.json` into yours. Or ask Claude: "Merge the hooks and deny
  rules from kit/hooks/settings.example.json into my ~/.claude/settings.json
  without removing anything that is already there."

Then restart Claude Code. Type `/hooks` inside Claude Code to see the hooks it
loaded.

### Check the hooks work

```bash
bash kit/hooks/test-hooks.sh
```

Sends each hook fake requests (like "rm -rf ~") and checks it blocks or allows
them correctly. Every line should say PASS.

To test one hook by hand:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git reset --hard"}}' | ~/.claude/hooks/block-destructive.sh; echo "exit code: $?"
```

Pretends Claude asked to run `git reset --hard`. You should see the block
message and `exit code: 2`. Exit code 2 means blocked, 0 means allowed.

## The pieces, and what problem each one solves

### CLAUDE.md

**Problem:** every new session, Claude starts knowing nothing about you, so you
repeat yourself and it guesses at your preferences.
**Fix:** this file is read at the start of every session. It says who you are,
that you are learning, how you want Claude to work (teach by default, run
things itself, report honestly) and what it must never do. It also loads the
always-on rules.

### Rules

Standards Claude follows. Each one exists because of a mistake that is common
for beginners and AI agents alike.

| Rule                    | Problem it solves                                                                                                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `staying-sharp.md`      | You ship code you cannot explain and slowly stop thinking. This sets the habits that keep you in charge: say your plan first, predict before running, read every diff, explain it back. |
| `git.md`                | Committing a password file, or wiping an afternoon of work with one command.                                                                                                            |
| `security.md`           | Leaked API keys, SQL injection, and member data visible to the wrong people. Church data is personal: kids, phones, addresses, giving.                                                  |
| `review-discipline.md`  | Fixing one copy of a bug while three more remain, and lessons that never get written down.                                                                                              |
| `writing.md`            | Text that sounds like a robot wrote it, in your emails, site and announcements.                                                                                                         |
| `facts-and-honesty.md`  | Claude saying "done" when it is not, or inventing a plausible number.                                                                                                                   |
| `untrusted-content.md`  | A web page or document containing hidden instructions aimed at the AI.                                                                                                                  |
| `research-the-craft.md` | Polished-looking work that misses what makes a good one (a sign-up form with 12 fields).                                                                                                |
| `do-it-yourself.md`     | Claude ending every reply with a command for you to run.                                                                                                                                |
| `naming.md`             | Inconsistent names that make code hard to read.                                                                                                                                         |
| `deliverables.md`       | Documents saved where nobody finds them, or shaped wrong for how they get used.                                                                                                         |
| `typescript.md`         | Bugs TypeScript could have caught, switched off with `any`.                                                                                                                             |

### Agents

An agent is a separate Claude with a fresh context and one job. Claude hands
work to them, or you can ask for one by name ("use the code-reviewer agent").

| Agent            | Problem it solves                                                                                                                                                                               |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `code-reviewer`  | The AI that wrote the code is the worst one to review it. This one catches bugs and security holes before you ship, ranked by severity, with a one-line "why it matters" for each so you learn. |
| `debugger`       | Guess-and-check debugging that changes five things at once. It follows a fixed seven-step protocol and tells you which step found the bug.                                                      |
| `explorer`       | Getting lost in an unfamiliar codebase. It answers "where does X live" with file and line, without editing anything.                                                                            |
| `context-keeper` | Project notes that go stale, so Claude trusts wrong information. It checks notes against the code and fixes what drifted.                                                                       |

### Hooks

A hook is a script Claude Code runs automatically at a set moment, like right
before a command. A hook can block an action, which makes it a real guardrail
instead of a polite request.

| Hook                   | When it runs                  | Problem it solves                                                                                                                                                        |
| ---------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `block-destructive.sh` | Before every terminal command | Stops the AI from running `rm -rf` on your home folder, `git reset --hard` over unsaved work, force pushes, `DROP TABLE`, or `curl ... \| sh`. Those stay in your hands. |
| `no-git-add-all.sh`    | Before every terminal command | Stops `git add .` and `git add -A`, the usual way passwords and giant files end up on GitHub.                                                                            |
| `protect-secrets.sh`   | Before every file write       | Blocks an API key or private key from being written into code, and reminds Claude to check `.gitignore` when it writes a `.env` file.                                    |
| `format-on-write.sh`   | After every file write        | Formats the file with a Prettier you installed yourself (`npm install -g prettier`), or Ruff/Black for Python. It never runs a formatter or config that came inside a repo, unless you list that project folder in `~/.claude/trusted-format-dirs`. Never blocks.                               |
| `stop-slop-check.sh`   | When Claude finishes a reply  | Sends the reply back for a rewrite if it has em dashes or words like "delve" and "seamless". Runs once per reply, so it cannot loop.                                     |

### Skills

A skill is a playbook in a `SKILL.md` file. Claude loads it automatically when
your request matches its description, or you can name it ("use the grilling
skill").

| Skill                    | Problem it solves                                                                                                                                                 |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `explain-it-back`        | Accepting code you do not understand. Claude has you explain what was built and fills only the gaps.                                                              |
| `grilling`               | Building before deciding. Claude interviews you in rounds until nothing is silently assumed. Only runs when asked.                                                |
| `thinking-out-loud`      | A long rambly idea (often dictated) that Claude misreads and builds wrong. It echoes back what it understood, with its own guesses marked, before doing anything. |
| `ship-in-slices`         | Big features built in one shot on a wrong reading. Restate, research, cut into small pieces, prove each works, review, then open the PR.                          |
| `debugging`              | Random guessing. The seven-step order, plus how to trace where data goes missing.                                                                                 |
| `reviewing-changes`      | Shipping bugs and AI slop in code. What to check, in order, and how to report it.                                                                                 |
| `research-the-craft`     | Generic results. Learn what professionals say makes a good one before building.                                                                                   |
| `learn-from-corrections` | Repeating the same mistake every week. Turns a correction into a rule, a test or a default.                                                                       |
| `repo-health`            | A project slowly rotting: unused packages, vulnerable dependencies, missing env variables.                                                                        |
| `webapp-testing`         | "It works" without looking. Drives the real app in a browser with Playwright and captures screenshots.                                                            |
| `no-ai-slop`             | Writing that sounds generated. Edits a draft to be clearer and more human while keeping your voice.                                                               |
| `make-a-skill`           | Explaining the same process every session. Turns a repeated task into a new skill.                                                                                |

## Making it yours

- Add a line to `CLAUDE.md` every time you catch yourself correcting Claude
  twice for the same thing.
- Edit the word list in `stop-slop-check.sh` to match what bugs you.
- Each project can have its own `CLAUDE.md` in its folder with project-specific
  rules (which database, how to run it, what the users need).

## Credits

Adapted from Caleb Newton's Chewbacca kit. Four skills come from other
authors and keep their licenses in their folders: `grilling` (Matt Pocock,
MIT), `no-ai-slop` (Peter Yang, MIT), `thinking-out-loud` (Shubham Saboo,
Apache-2.0) and `webapp-testing` (Anthropic, Apache-2.0).
