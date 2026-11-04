# 5. How the Anchored presentation got made

You asked how the presentation got so polished so fast. The short answer is that it wasn't slides. It was a web page, built inside the same app as Anchored, at [anchored.up.railway.app/pitch](https://anchored.up.railway.app/pitch). You scroll it instead of clicking through it, and the scenes animate as you go.

## The real timeline (from the git history)

Every one of these is a commit in the Anchored repo on Oct 24, the day of the hackathon:

| Time   | What got added                                                                                                 |
| ------ | -------------------------------------------------------------------------------------------------------------- |
| 3:20pm | One-scroll pitch site at `/pitch`, with the live dashboard and video slots                                     |
| 3:30pm | Scroll scenes: the week lights up, Maria's chat builds, Osas's lock screen rewrites itself                     |
| 3:35pm | Scenes for Maria alone and the pastor's 200 names, the promises cut to four lines, type that fits every screen |
| 3:39pm | Motion made intentional: no slide-up fades, headlines rewrite with a wipe                                      |
| 3:42pm | The chat scene plays the real WhatsApp test word for word                                                      |
| 3:44pm | Chat lines shortened so they read on a projector                                                               |
| 3:50pm | The phone styled to look like real WhatsApp                                                                    |
| 4:05pm | Scene labels readable from the back row                                                                        |
| 4:13pm | Last fix: verse references checked against their text                                                          |

So about an hour, in roughly fifteen small asks. Not one giant prompt.

## Why a web page beats slides

- **It shows the real product.** The dashboard on the pitch page was the live app, not a screenshot. Judges trust what they can see working.
- **It's one link.** Anyone can open it on their phone afterward.
- **Claude Code is great at it.** A page is just code, so the same tool that builds the app builds the pitch.

## How to make one yourself

### 1. Write the story before any code

Before asking for the page, write the beats in plain English. Ours followed the hackathon's three parts and started with a person:

```text
0:00 Who it's for: Maria, baptized this morning, dinner with her dad tonight
0:30 Show it working, live
2:00 What could go wrong and what we did about it
2:30 What God did in our team today
```

The full script is in the Anchored repo at `docs/demo.md`. Start with a person and a moment, never with the features.

### 2. Ask for the skeleton

```text
Read SPEC.md and docs/demo.md. Make a one-scroll pitch page at /pitch.
Each beat of the demo script is one full-screen scene. Big type that reads
from the back of a room. No slide-up fade animations. Plan first, then build
the first scene only and show me it at 1440px and 390px wide.
```

### 3. One scene at a time

```text
Scene 2: as the person scrolls, a phone shows Maria's WhatsApp chat building
one message at a time. Use the exact messages from [file]. Make the phone
look like a real WhatsApp chat. Show me.
```

### 4. Then tighten, out loud

Most of the commits above are fixes after reading it like an audience would. Prompts that did that work:

- "Read this like you're in the back row of a room with a projector. What can't you read? Fix it."
- "Cut every promise to one line. Four lines max."
- "Every animation should mean something. Remove any that are just decoration."
- "Check every Bible verse reference against its actual text."

### 5. Have a backup

We recorded a backup video in case the live demo broke. The prompt for it is in `docs/demo.md` in the Anchored repo. The rule we held to: if something breaks, use the video and say it's the video. Never fake a live step and call it live.

## A note on my exact prompts

I don't keep a log of every word I typed, so I'm not going to pretend these are verbatim. The commit messages above are real and show what each ask was about. The prompts in this guide are written to get the same result.

Next: [How Anchored got built in one day](06-building-anchored.md)
