# 2. Set up your computer

This is written for a Mac. If you're on Windows, tell Claude Code (or Claude in the browser) "I'm on Windows, translate these steps" and it'll do it.

Do these in order. Each step says what it does and what might look scary.

## Open the terminal

Press `Cmd + Space`, type **Terminal**, press Enter. A window with a blinking cursor opens. That's it. You type a command, press Enter, and it runs.

## 1. Install Homebrew

Homebrew installs developer tools for you. Paste this and press Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> It'll ask for your Mac password. When you type it, **nothing shows up on screen**. That's normal, just type it and press Enter. At the end it prints "Next steps" with two or three lines to copy and run. Run those, they add Homebrew to your path.

## 2. Install Node and Git

```bash
brew install node git
```

> Node runs JavaScript on your computer. Git saves versions of your code. This takes a couple minutes and prints a lot. Ignore it unless the last line says "Error".

Check it worked:

```bash
node -v && git -v
```

> You should see two version numbers.

## 3. Install Claude Code

Follow the one-line install from [the official Claude Code page](https://claude.com/claude-code). Then:

```bash
claude
```

> The first time, it opens your browser to sign in with your Claude account. After that, you're talking to Claude inside your terminal.

Type `/help` to see what it can do, and `Ctrl + C` twice to leave.

## 4. Install the GitHub CLI and sign in

```bash
brew install gh
gh auth login
```

> Pick GitHub.com, HTTPS, and "Login with a web browser". It shows a code, opens a page, you paste the code. Now Claude Code can create repos and push for you.

## 5. Make a home for your projects

```bash
mkdir -p ~/code && cd ~/code
```

> Every project you build lives in its own folder inside `~/code`. Always `cd` into the project folder before you type `claude`, so it works on the right files.

## 6. (Optional) Cursor

Download from [cursor.com](https://cursor.com). Open your project folder with File > Open. You can run Claude Code inside Cursor's built-in terminal too, so you see the files change as Claude edits them.

## Sanity check

Run this inside `~/code`:

```bash
claude "Make a folder called hello, put an index.html in it that says Hello from Ryan, and open it in my browser."
```

If a page opens in your browser, you're set up. You just built something with AI.

Next: [Your first project](03-first-project.md)
