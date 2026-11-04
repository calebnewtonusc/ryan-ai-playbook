---
name: create-cli
description: "Design a command-line tool's surface before building it: commands, flags, help text, output, errors, exit codes, config and dry-run. Use when making a CLI, adding a subcommand or flag, or when a script needs to be usable by other people or other programs."
---

# Create a CLI

Design what the command looks like from the outside (names, flags, output,
errors) before writing the code behind it. A good CLI is easy for a person to
discover and easy for a script to call.

The full reference is the Command Line Interface Guidelines at
https://clig.dev/. Read it once. This skill is the short version you apply
every time.

## 1. Pin down the basics

Answer these, then fill in reasonable defaults for anything left open:

- The command's name and its purpose in one sentence
- Who calls it: people, scripts, or both
- Where input comes from: arguments, stdin, files, URLs. Secrets never go in
  flags, because flags show up in shell history and process lists. Use an
  environment variable or a file.
- What it outputs: human text, `--json` for programs, exit codes
- Can it ask questions interactively? It needs `--no-input` for scripts, and a
  confirmation before anything destructive.
- Where settings live: flags, environment variables, a config file, and which
  wins

**Before the AI drafts anything, write the three commands you expect to type
most often, exactly as you would type them.** Those are the real spec. If the
design makes them awkward, the design is wrong.

## 2. Produce a short spec

Write this out before building:

1. **Name and one-liner**
2. **Usage:** `mycmd [global flags] <subcommand> [args]`
3. **Subcommands:** what each does, and whether running it twice is safe
4. **Flags table:** name, type, default, required or not, example
5. **Output rules:** what goes to stdout and what goes to stderr, `--json`,
   `--quiet` and `--verbose` defined exactly
6. **Exit codes:** `0` success, `1` failure, `2` bad usage. Add more only when
   a caller would actually act on them.
7. **Config and environment:** the variables, the config file path, and the
   order they win in (flags, then env, then project config, then user config)
8. **Safety:** `--dry-run`, confirmations, `--force`
9. **Examples:** five to ten real invocations, including one that pipes data
   in or out

## 3. Defaults to follow unless there is a reason not to

- `-h` and `--help` always show help and ignore everything else.
- `--version` prints the version to stdout.
- The actual result goes to stdout. Progress, warnings and errors go to
  stderr, so `mycmd | other-tool` gets clean data.
- Offer `--json` for programs reading the output.
- Only prompt when a person is at the keyboard (stdin is a terminal).
  `--no-input` turns prompts off.
- Destructive commands ask for confirmation. Without a terminal, they require
  `--force`.
- Respect `NO_COLOR` and offer `--no-color`.
- Ctrl-C exits quickly and cleans up what it can.
- Error messages say what went wrong and what to do next:
  "Config file not found at ./mycmd.json. Run `mycmd init` to create one."

## 4. Check the design

- Run `mycmd --help` in your head. Can a new user find the common task in
  under ten seconds?
- Try the three commands you wrote in step 1 against the spec.
- Pipe it: does `mycmd list --json | jq length` work with nothing extra on
  stdout?
- Feed it a wrong flag and a missing file. Is the error clear, and is the exit
  code non-zero?

## Notes

- Recommend a parsing library (commander for Node, click or typer for Python)
  only when asked. The design does not depend on the language.
- If the request is "design the flags", stop at the spec. Do not drift into
  writing the implementation.
