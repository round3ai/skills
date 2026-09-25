# Keeping an eye on experiments

An experiment runs for minutes to hours. When your client can schedule its own
next turn, you follow every experiment you created in this conversation, or
that a three.dev chat you carried over started, until its results are in, and
tell the user what matters without being asked.

## Can you schedule?

Yes when your client can run a check later on its own: a loop or interval
command, a scheduled wake-up, a background task that calls you back. Use the
client's own mechanism; this skill has no tool for it. No when every turn
starts with a user message, as in the three.dev chat.

## The three.dev chat

The chat can neither keep an eye on an experiment nor edit the user's code.
When either is needed, say so in one sentence and offer the way on:

- If `get_assistant_conversation` is in your tools, the chat shows a **Copy
  conversation** button under your reply. Pasted into a coding agent connected
  to the three.dev MCP server, it carries this conversation over, and that
  agent can follow the experiment and make the change.
- Otherwise, or if the user prefers, they come back here and ask how it went.

## What to do

For an experiment a carried-over chat started, take its id from the link the
chat showed, or find it by name with `list_offline_experiments`; if its
results are already in, report them now instead of scheduling a check.

Right after creating, tell the user in one sentence that you will keep an eye
on it and roughly when to expect results. Then, for each experiment you
follow whose results are not in yet:

1. Schedule a check every 20 to 30 minutes. More often spends the user's
   tokens without news; less often leaves a broken run unnoticed.
2. On each check, call `get_offline_experiment` once per experiment and look
   at the status, `error_reason`, each variant's `progress`, and
   `results_ready`.
3. Say nothing when it is progressing normally. Speak only when one of these
   happens:
   - **It failed**, or **a variant is unreliable**: read as in Step 4 of the
     skill, and say what to do about it.
   - **It matched too little**: the prompt-template tell from Step 1 of the
     skill. Offer to stop it in the app and rebuild the template.
   - **It stalled**: `progress` has not moved across three checks.
   - **Results are in**: `results_ready`, and `failure_modes_ready` too when
     the experiment tries a fix for a failure mode, since that comparison
     decides it. Read them as in Step 4 of the skill and report.
4. Stop checking an experiment once you reported its results or its failure,
   or when the user tells you to stop. Stop all checks when none is left.

If the conversation ends first, the results stay in the app; the user can ask
any agent connected to three.dev how the experiment went.

## How to say it

In the tone of the skill's ground rules:

- Healthy, when the user asks: "It's about halfway through and everything
  looks fine. I'll let you know as soon as the results are in."
- Broken: "Something's off with [the experiment](link): only 40 of the 500
  requests could be replayed, because the prompt template doesn't match most
  of your recorded traffic. If you stop it [here](link), I'll fix the template
  and start a new one. Sound good?"
- Done: "Good news: [the rule-based prompt](link) worked (quality 82.6% vs
  75.8%, same latency, about $0.001 more per request). Would you like to
  [look at a few of its replies](link) first, or should I go ahead and apply
  it?"
- Done, nothing better: "None of the prompts made a difference (quality
  76–77% vs 75.8%). Most of the misses are very short messages, so a larger
  model might handle them better. Want me to try that? It would cost about
  $12."

The numbers and links in these examples are placeholders; yours come from the
results and the `url` fields the tools return.
