# Metric reporting

The endpoint, its body, and its responses are on the Report Metric page
([live](https://docs.three.dev/api-reference/report-metric.md),
[local copy](report-metric.md)). This file holds the rules for wiring it into a
codebase without losing outcomes or breaking the app.

## Where and what

- Report at each outcome point selected in Step 2, with the same session ID
  the LLM calls used. `POST /api/v1/metrics/report`.
- A metric is a binary session-level outcome. `optimize_for: "max"` means
  true is good; `"min"` means true is bad.
- If several metrics share plumbing, add one small helper next to the repo's
  existing utilities. No new abstractions beyond that.

## Timing

- A session becomes reportable up to five seconds after its first proxied
  request. Any outcome that can fire in the same request as the LLM call (an
  escalation, an immediate failure, a one-shot job) races that window.
- Delay, queue, or retry those reports. Do not fire and hope.
- Whatever defers the report must outlive the request that scheduled it. A
  background thread or task that dies with a short-lived process (a cron run,
  a worker that exits after one job, a serverless invocation) silently drops
  the conversion. If the codebase has no mechanism that survives that, say so
  and let the user choose rather than picking the convenient one.

## Failure handling

- Fire-and-forget otherwise: non-blocking, short timeout, failures logged and
  swallowed. A report must never take down a user-facing flow.
- If an outcome point can fire without a session ID available, skip the
  report but log the skip. Never silently drop conversions.
