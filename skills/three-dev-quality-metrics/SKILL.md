---
name: three-dev-quality-metrics
description: Sets up quality metrics for an LLM feature that three.dev already records. Decides whether a business outcome is worth tracking and, if so, wires the code that reports it; three.dev creates the metric from the first report. Use when the user wants to track conversions, bookings, resolutions, escalations, accepted suggestions, or another outcome of an LLM feature, asks which quality metric to use, or needs a metric for a live experiment. Not for adding three.dev to a codebase or routing calls through the proxy; that is the three-dev skill. Not for investigating failure modes or reading recorded conversations; that is the three-dev-failure-modes skill. Not for running or reading offline experiments; that is the three-dev-experiments skill.
---

# three.dev quality metrics

A **quality metric** is a business outcome the user's application reports to
three.dev for a session: a booking completed, a suggestion accepted, a
conversation escalated to a human. It is binary and has a direction: `max`
when `true` is good, `min` when `true` is bad. Live experiments use it as their
target.

Not every feature has one, and that is fine. Every use case already has a
quality signal without any code: Acceptable Response, the AI Judge's pass/fail
on each output, used by live scoring and offline experiments. A quality metric
adds the business view on top. This skill's first job is to decide whether an
outcome worth tracking exists; "none fits" is a valid result.

The LLM calls must already send use case and session headers; if they do not,
use the `three-dev` skill first. No metric has to be created in advance: the
first report that carries `optimize_for` creates it. With no access to the
user's code, work out the candidate outcomes from what the user tells you and
point them to the Metrics page in the app to create them.

When the `three-dev` skill loaded this skill during setup, skip Step 5 and
return to it.

## Where the facts are

| Need | Live page | Local copy |
| --- | --- | --- |
| The event-based model, direction, what and when to report | https://docs.three.dev/live-experiments/quality-metric.md | [references/quality-metric.md](references/quality-metric.md) |
| The report endpoint and its body | https://docs.three.dev/api-reference/report-metric.md | [references/report-metric.md](references/report-metric.md) |
| What a session is, and why it must end | https://docs.three.dev/getting-started/planning-your-integration.md | the `three-dev` skill's copy |
| Listing existing metrics without the MCP server | none | [references/control-plane-api.md](references/control-plane-api.md) |
| Wiring reports into code | none | [references/metric-reporting.md](references/metric-reporting.md) |

Read the live page when you can (the three.dev MCP server's `read_doc`, or a
fetch tool that returns the Markdown verbatim); the copies may lag it.

## Ground rules

- **Decide, don't ask.** Wire every outcome that passes Step 2. Never offer the
  user a menu or wait for a pick.
- **Never force a metric.** Leave out anything in doubt, and never build
  product features (a feedback button, a new event) to create one.
- **Secrets never touch the chat or the repo.** Never ask the user to paste a
  key. Never hardcode, print, echo, or commit one.
- **Never break the app.** Reports are non-blocking and a failure is logged,
  never raised into a user-facing flow.
- **Minimal diff.** A report call at each outcome point, the session ID
  carried to it, and at most one small helper. No refactors.
- **Be brief.** No narration, no tables of candidates in chat.

## Workflow

### Step 1: Confirm the wiring and find the outcomes

Find the use case slugs and the session IDs in the code (`X-Three-Use-Case`,
`X-Three-Session-ID`). Skip a use case that sends no session ID; if none does,
use the `three-dev` skill first.

For each use case, work out what the feature is for and what happens after the
LLM responds. Look in the code for business events that mark success or
failure of that goal: a record created (an order, a booking, a ticket), a
suggestion applied or discarded, a handoff to a human, a user leaving mid-flow,
feedback already stored.

### Step 2: Decide which outcomes to track

An outcome is tracked only when all of these hold:

- **Business outcome:** something the business counts in its own terms, such
  as a sale, a booking, a resolved request, or a customer handed to a human.
  Technical signals are never metrics: errors, timeouts, turn or token limits,
  retries, latency, guardrail trips, model or provider fallbacks.
- **Observable:** the code already detects the event at one specific place.
- **Session-bound:** it belongs to exactly one interaction, and that
  interaction's ID can reach the point where the event fires.
- **Binary:** it either happened in the session or it did not.
- **Tied to the goal:** moving it means the feature got better or worse.
- **Obvious direction:** it is clearly good (`max`) or clearly bad (`min`).

For each tracked outcome, settle its slug (the outcome's name, not the file or
model), direction, the point where `true` is reported, and the point where the
session definitively ends without it, if the code has one. A funnel with
several clear stages is one metric per stage.

If nothing passes, wire nothing. Quality is still measured by the AI Judge
through live scoring (https://docs.three.dev/live-scoring/live-scoring.md).

### Step 3: Reuse existing slugs

When the MCP server is connected, call `list_quality_metrics` for the use case;
otherwise use the REST API when `THREE_DEV_API_KEY` is available
([references/control-plane-api.md](references/control-plane-api.md)). If an
existing metric already tracks the outcome, report under its slug. With
neither available, keep the slugs from Step 2.

### Step 4: Wire the reports

Follow [references/metric-reporting.md](references/metric-reporting.md) for each
tracked outcome, at the points settled in Step 2. Change nothing else.

### Step 5: Wrap up

One short message: each metric with its direction and where it is reported,
noting it appears in three.dev with its first report, or that no outcome was
clear enough to track. Do not commit unless asked.

- To test a change against the metric on real users, the live experiment is
  created in the app: https://docs.three.dev/live-experiments/creating-experiments.md.
- To test a change on recorded traffic before shipping, use the
  `three-dev-experiments` skill.

## Hard rules

- One report per metric per session. A metric flips to `true` once and a
  report cannot be withdrawn.
- The `session_id` in a report is the exact value sent as `X-Three-Session-ID`.
- Metric slugs match `^[a-z0-9]+(?:-[a-z0-9]+)*$`, are at most 64 characters,
  and are constant in code.
- The metrics list includes three.dev's built-in metrics (`built_in` from
  `list_quality_metrics`, `"is_system": true` from the REST API). Never treat
  one as a metric you created.
- An event the user can undo (a cancelled booking) is reported when the system
  confirms it, not at the first click.
