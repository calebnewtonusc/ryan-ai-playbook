---
name: interface
description: "Build a screen or page by deciding what it is for before styling it, then checking the real rendered page at phone, laptop and desktop width. Use to build, lay out or redesign UI: dashboards, forms, settings, landing pages, or anything that looks generic."
---

# Interface

Most AI-built pages look the same because nobody decided what the page was
for. The model fills the gap with the average page: a big headline, three
cards with icons, a gradient. This skill makes the decisions first, then
checks the page the way a visitor will actually see it.

## The order, every time

1. Name the mode
2. Name the template
3. Show the content as itself
4. Apply the system
5. Build every state
6. Check the real rendered page

## 1. Name the mode

Decide what success looks like for the person on this screen. Choose it from
the screen, not the product: a developer tool's landing page is still
Persuade.

| Mode           | The visitor           | Examples                                 |
| -------------- | --------------------- | ---------------------------------------- |
| **Persuade**   | decides and acts      | landing page, pricing, sign-up           |
| **Operate**    | gets a task done fast | app screens, dashboards, settings, admin |
| **Read**       | understands something | docs, articles, help, changelog          |
| **Experience** | is inside the work    | portfolio, gallery, case study           |

**You decide the mode, and write one sentence on who the visitor is and what
they are doing when they arrive** ("a parent on their phone between errands,
checking if signup is still open"). The AI builds from your sentence. This is
the decision that most changes the result, so it stays with you.

## 2. Name the template

Almost every request is one of these. Name it before writing markup:

- **Dashboard:** a few key numbers, a main chart or list, filters
- **Table:** rows to scan, sort and act on
- **Form:** fields, validation, one clear submit
- **Detail view:** one record and its actions
- **Settings:** grouped options with clear saved state
- **Wizard:** one step at a time with progress
- **Feed:** a stream of items, newest first
- **Landing page:** one promise, proof, one action
- **Practice session:** one item at a time, full screen, with a result after
  each (for anything someone studies or drills)

If you are about to invent a new kind of component, check whether it is one
of these with a different name.

## 3. Show the content as itself

The strongest move on any page is showing the real thing instead of a
description of it.

- A messaging product shows the actual message a person receives.
- A tool shows a live preview of its output, not an icon and a sentence.
- A team page shows faces, not a count of members.
- Something to practice shows the instrument or the problem, not a table
  about it.

Before adding any section, write one line: what this section proves that no
other section proves. Two sections with the same line means one goes.

## 4. Apply the system

From Refactoring UI, in this order:

1. **Design in grayscale first.** Get the hierarchy working with size, weight
   and position. Add color last, and give the accent color one meaning (for
   example, "you can click this").
2. **Use a fixed scale.** Pick spacing from a set (4, 8, 12, 16, 24, 32, 48,
   64px) and font sizes from a set. Tailwind's defaults already are one.
3. **Hierarchy by size, weight and color**, not by adding boxes and borders.
4. **Start with too much white space, then remove.** Cramped is the default
   failure.
5. **Details last:** shadows, icons, motion.

**Pick one theme and keep it.** Define colors and fonts once (CSS variables or
the Tailwind config) and use them everywhere. A new accent color per page
makes a pile of demos instead of a product.

### Refuse these unless the brief asks for them

They are what a page looks like when nobody decided anything:

- A small uppercase label ("eyebrow") above every heading
- Rows of same-size cards with an icon, a heading and a line of text as the
  whole page structure. Cards inside cards.
- Gradient text, and glass or blur used as decoration
- A thick colored border on one side of cards or alerts
- Section numbers (01 / 02 / 03) when order means nothing
- Emoji standing in for icons
- Dark mode chosen because "it looks techy" instead of for where it is used

## 5. Build every state

Every screen that loads data has four states, and the prompt only ever
describes one:

- **Loading:** a skeleton shaped like the content, not a lone spinner
- **Empty:** what this area is for and the action that fills it
- **Error:** what went wrong in plain words and a way to retry
- **Full:** with realistic data, including a long name and a very long list

Also: hover and keyboard focus states on everything clickable, and a disabled
state that explains why.

## 6. Check the real rendered page

A screenshot of the code in your head is not a check. Open the actual page.

**Before taking screenshots, predict the one thing most likely to look wrong
at phone width.** Then look and see if you were right.

Check at three widths:

- **375px:** a phone
- **about 940px:** a laptop browser window that is not full screen. Many
  layouts only switch to two columns at 1024px, so this width shows a stacked
  layout with a big empty side. Split columns at `md:` (768px) unless the
  content really needs more room.
- **1440px:** a desktop

Screenshot it headless with Playwright (`npm i -D playwright` and
`npx playwright install chromium` once):

```js
// shots.mjs: node shots.mjs http://localhost:3000
import { chromium } from "playwright";

const url = process.argv[2];
const browser = await chromium.launch(); // headless by default
const errors = [];
for (const width of [375, 940, 1440]) {
  const page = await browser.newPage({ viewport: { width, height: 900 } });
  page.on(
    "console",
    (m) => m.type() === "error" && errors.push(`${width}: ${m.text()}`),
  );
  page.on("pageerror", (e) => errors.push(`${width}: ${e.message}`));
  await page.goto(url, { waitUntil: "networkidle" });
  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth > window.innerWidth,
  );
  if (overflow) errors.push(`${width}: page scrolls sideways`);
  await page.screenshot({ path: `shot-${width}.png`, fullPage: true });
  await page.close();
}
await browser.close();
console.log(
  errors.length ? errors.join("\n") : "no console errors, no sideways scroll",
);
process.exit(errors.length ? 1 : 0);
```

Then open every screenshot and actually look at it. For each one check:

- Nothing scrolls sideways, nothing overlaps, no text is cut off.
- Headings do not wrap into awkward single words at 375px.
- Tap targets are at least 44px tall on the phone.
- Text contrast is readable (4.5:1 for body text; Chrome dev tools shows it).
- Body text lines are not wider than about 75 characters.
- Every state from step 5 has been seen at least once, not just the full one.
- Tab through the page with the keyboard. Focus is always visible.

Screenshot every state (empty, error, each open menu or dialog, success) at
375 and 1440 before anyone else sees the page. If something looks wrong, fix
it or list it. Never call a page done from a desktop screenshot alone.

## For someone learning

You keep three decisions: the mode and the visitor sentence in step 1, the
"what this section proves" line for each section in step 3, and the
prediction in step 6. The AI can write every line of CSS. It cannot know who
the page is for unless you tell it, and you only learn to see layouts by
predicting what will break and then checking.

## Credits

The mode table and parts of the refuse list are adapted from pbakaus/impeccable
(Apache License 2.0). The design order in step 4 follows the book Refactoring UI.
