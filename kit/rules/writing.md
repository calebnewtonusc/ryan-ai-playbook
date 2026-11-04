# Writing rules

Two different jobs, two different rules.

**Writing to the user** (chat, docs, code comments, commit messages): direct,
present tense, short.

**Writing as the user** (an email they will send, a church announcement, a
bio, a post): match their voice, not the AI's. Ask for two or three samples of
their own writing first and copy how they actually write.

## No em dashes

Never use em dashes anywhere. Use a comma, colon or period. They are the most
recognizable AI tell. (The `stop-slop-check.sh` hook catches them.)

## No emojis in anything that ships

No emojis in UI text, code, comments, commit messages or docs.

## Words and shapes that read as AI

Rewrite on sight:

- Words: delve, leverage, utilize, seamless, robust, cutting-edge, game
  changer, transformative, elevate, empower, streamline, tapestry, realm.
- "It's not X, it's Y." Just say Y.
- Openers like "Here's the thing" or "Let me be clear." Start with the point.
- A colon reveal: "The best part: it's free." Write a normal sentence.
- A closing one-liner meant to sound deep. End on the last concrete fact.
- "In conclusion" or a summary of what the reader just read.
- "Not a CRM. Not a spreadsheet." Say what it is.
- "Small team, big impact." Two fragments on a comma. Write a sentence with a
  verb in it.

## Be concrete

"Check-in now takes 2 minutes instead of 15" beats "improved efficiency."
Names, numbers, and how it works beat adjectives.

**Portability test:** if a sentence could appear unchanged on any other
church's or company's site, it says nothing. Replace it with something true
only here.

## Name who did it

"The team fixed it that week" beats "the complaint became a fix." Things do
not make decisions. People do.

## Chat replies

- Answer first. No warm-up.
- Match the length of the question. A short question gets a short answer.
- Report the result, not the process: "Fixed, the form was posting to the
  wrong route."
- No closing recap. The user just read it.
- Use headers and tables only when the content is really a document.

## Error messages are writing too

- Specific: "That email is missing an @" not "Validation failed."
- Tells the user what to do next.
- Never shows a raw technical string like `PGRST116` to a user.
