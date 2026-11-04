# Level 0: stay the engineer

AI makes it really easy to stop thinking. You ask, it answers, you accept, and over a few months the muscle that used to figure things out gets weak. Researchers have started measuring this. In MIT Media Lab's 2025 study [Your Brain on ChatGPT](https://arxiv.org/abs/2506.08872), people who wrote essays with ChatGPT had a harder time quoting what they'd just written and felt less ownership of it than people who wrote on their own. The fix isn't using AI less. It's using it in a way that keeps you in the driver's seat.

These are the habits I hold myself to.

## 1. Predict before you prompt

Before you ask Claude something, spend 30 seconds guessing the answer. Write it down if it's important. Then compare. When you were right, your judgment just got confirmed. When you were wrong, you just learned something real, and you'll remember it because you were invested in your guess.

## 2. You decide, it executes

The AI is great at options and terrible at knowing what you actually want. So ask for choices, and make the call yourself:

```text
Give me three different ways to do this, with the tradeoff of each. Don't pick yet.
```

Then pick, and say why in one sentence. That sentence is the engineering.

## 3. Explain it back

After the AI builds something, explain it back in your own words before moving on:

```text
Here's how I think this works: [your explanation]. What did I get wrong?
```

If you can't explain it, you don't own it yet. Ask until you can.

## 4. Never accept the first draft

The first draft is the average of everything the model has seen. That's what slop is. Taste is everything after the first draft: "cut this," "this part is generic," "say it the way a first-time visitor would hear it." Plan to iterate three to five times on anything that matters.

## 5. Do reps without it

Once a week, do one small thing with no AI: fix a bug by reading the error yourself, write a paragraph of copy, sketch a page layout on paper. It's like a baseball player who still takes batting practice off a tee. The machine is great in the game. The reps keep your swing.

## 6. Make it argue with you

AI wants to agree with you. Turn that off on purpose:

```text
Here's my plan. Tell me the three strongest reasons it's wrong, and what result
would prove it wrong. Don't be nice about it.
```

I do this before anything that matters. It's caught more of my mistakes than any test.

## 7. Truth over fluency

AI sounds confident whether it's right or not. So:

- Ask "how do you know that?" and "where did that come from?"
- Never let it invent a number, a quote, a date or a fact about a real person
- When it says "done," make it show you. Running code, a screenshot, a live link
- When something matters, check it yourself against the real source

## 8. Write down what you learn

When you or the AI makes a mistake, write the lesson where the next session will see it: in your project's CLAUDE.md, or in a rule file (level 4). A lesson that only lives in a chat is gone the moment the chat ends. My whole setup started as a list of mistakes I never wanted to make twice.

## The checkpoint

Pick a small project idea. Write a 5 bullet plan yourself, by hand, before asking anything. Then ask Claude for its plan. Write two sentences: what your plan got right that Claude's missed, and what Claude's got right that yours missed.
