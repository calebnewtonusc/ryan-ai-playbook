# 3. Your first project, start to live link

Goal: a real page on the internet, built by you and Claude, with a link you can text someone.

Pick something real so you actually care how it turns out. A few that would fit Every Nation City Church:

- A sign-up page for the next Welcome Tea and Coffee
- A one-page "new here?" guide for CSUN students who just visited
- A volunteer schedule page for Sunday

## Step 1. Make the folder and start Claude

```bash
mkdir -p ~/code/welcome-page && cd ~/code/welcome-page
claude
```

## Step 2. Plan, don't build yet

Paste:

```text
I want a one-page website for [what it is] for [who it's for].
They should be able to [the one thing they do on it] on their phone.
Before writing any code, give me a 5 bullet plan and ask me anything you need to know.
Use Next.js and Tailwind so I can deploy it to Vercel.
```

Read the plan. Push back on anything that sounds off. Answer its questions. Then say **go**.

## Step 3. Build one slice

```text
Do step 1 of the plan. Then run it and show me it working at phone width (390px).
```

It'll start a local server and give you a link like `http://localhost:3000`. Open it. Look at it on your phone size (in Chrome: right-click, Inspect, then the phone icon).

## Step 4. Fix what you see

Say exactly what's wrong, like you'd tell a designer:

```text
The headline is too small on a phone and the button is hard to find.
Make the button the first thing your eye goes to. Show me again.
```

Repeat until you'd be proud to text it to someone.

## Step 5. Save it to GitHub

```text
Create a GitHub repo called welcome-page, commit everything, and push it.
```

## Step 6. Put it on the internet

Go to [vercel.com/new](https://vercel.com/new), pick your `welcome-page` repo, press **Deploy**. About a minute later you get a link like `welcome-page.vercel.app`.

From now on, every time Claude pushes to GitHub, Vercel updates the live site by itself.

## You're done when

- The link works on your phone
- You've texted it to one person
- You could explain what each of the six steps did

Next: [The loop](04-the-loop.md)
