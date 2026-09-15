---
name: three-dev-quality-metrics
description: Sets up quality metrics for an LLM feature that three.dev already records. Decides whether a business outcome is worth tracking and, if so, creates the metric and wires the code that reports it. Use when the user wants to track conversions, bookings, resolutions, escalations, accepted suggestions, or another outcome of an LLM feature, asks which quality metric to use, or needs a metric for a live experiment. Not for adding three.dev to a codebase or routing calls through the proxy; that is the three-dev skill. Not for investigating failure modes or reading recorded conversations; that is the three-dev-failure-modes skill. Not for running or reading offline experiments; that is the three-dev-experiments skill.
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

Traffic must already flow through three.dev with session IDs; if it does not,
use the `three-dev` skill first. With no access to the user's code, describe
the candidate outcomes and point the user to the Metrics page in the app to
create one.

## Where the facts are

| Need | Live page | Local copy |
| --- | --- | --- |
| The event-based model, direction, what and when to report | https://docs.three.dev/live-experiments/quality-metric.md | [references/quality-metric.md](references/quality-metric.md) |
| The report endpoint and its body | https://docs.three.dev/api-reference/report-metric.md | [references/report-metric.md](references/report-metric.md) |
| What a session is, and why it must end | https://docs.three.dev/getting-started/planning-your-integration.md | the `three-dev` skill's copy |
| Listing and creating metrics, checking the key | none | [references/control-plane-api.md](references/control-plane-api.md) |
| Wiring reports into code | none | [references/metric-reporting.md](references/metric-reporting.md) |

Read the live page when you can (the three.dev MCP server's `read_doc`, or a
fetch tool that returns the Markdown verbatim); the copies may lag it.

## Ground rules

- **The user decides the metric.** Business intent cannot be read from code.
  Propose candidates as a numbered list with your recommendation marked and
  justified in one line, then stop and wait. One question at a time.
- **Never force a metric.** Do not stretch a vague signal into an outcome, and
  do not build product features (a feedback button, a new event) to create
  one. Name what would have to exist and leave it to the user.
- **Secrets never touch the chat or the repo.** Never ask the user to paste a
  key. Never hardcode, print, echo, or commit one.
- **Never break the app.** Reports are non-blocking and a failure is logged,
  never raised into a user-facing flow.
- **Minimal diff.** A report call at each outcome point and at most one small
  helper. No refactors.
- **Be brief.** No narration. Findings go in the table in Step 2.

## Workflow

### Step 1: Confirm traffic and find the outcomes

Find the use case slugs and how the session ID is set in the code
(`X-Three-Use-Case`, `X-Three-Session-ID`). If either is missing, stop and use
the `three-dev` skill.

For each use case, work out what the feature is for and what happens after the
LLM responds. Look in the code for events that mark success or failure of that
goal: a record created (an order, a booking, a ticket), a suggestion applied
or discarded, a handoff to a human, a retry or regeneration, a user leaving
mid-flow, feedback already stored.

### Step 2: Decide, with the user

A candidate is ready only when all of these hold:

- **Observable:** the code already detects the event at one specific place.
- **Session-bound:** it belongs to exactly one session, and the session ID is
  available where it fires.
- **Binary:** it either happened in the session or it did not.
- **Tied to the goal:** moving it means the feature got better or worse.

Present:

| # | Use case | Outcome | Slug | Direction | Reported at (file:line) | Definitive `false` at |

List candidates that need a product change (the event is not detected yet)
separately, with what would have to exist.

If no candidate is ready, say so in two lines: no business outcome fits yet,
and quality is measured by the AI Judge through live scoring
(https://docs.three.dev/live-scoring/live-scoring.md). Then stop.

Otherwise recommend one metric per use case, or one per funnel stage when the
user wants the funnel, and wait for the user to pick.

### Step 3: Create the metric

Check `THREE_DEV_API_KEY` works without printing it, then list the use case's
metrics and create the chosen ones that do not exist yet
([references/control-plane-api.md](references/control-plane-api.md)). A metric
must exist before any report for it is accepted.

- A `404` for the use case means no traffic has been recorded under that slug
  yet; the user runs the app once, then you retry.
- `401` or `403`, or no key: tell the user to create the metric on the Metrics
  page in the app with the slug and direction from Step 2, and continue once
  they confirm.

### Step 4: Wire the reports

Follow [references/metric-reporting.md](references/metric-reporting.md) for each
chosen metric, at the points from the Step 2 table. Change nothing else.

### Step 5: Wrap up

One short message: the metrics created, each with its direction and where it
is reported, and one line on next steps. Do not commit unless asked.

- To test a change against the metric on real users, the live experiment is
  created in the app: https://docs.three.dev/live-experiments/creating-experiments.md.
- To test a change on recorded traffic before shipping, use the
  `three-dev-experiments` skill.

## Hard rules

- One report per metric per session. A metric flips to `true` once and a
  report cannot be withdrawn.
- The `session_id` in a report is the exact value sent as `X-Three-Session-ID`.
- Metric slugs match `^[a-z0-9]+(?:-[a-z0-9]+)*$`.
- The metrics list includes entries with `"is_system": true`. Never treat one
  as a metric you created.
- An event the user can undo (a cancelled booking) is reported when the system
  confirms it, not at the first click.
