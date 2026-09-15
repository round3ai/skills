# Metric reporting

The endpoint and its body are on the Report Metric page
([local copy](report-metric.md)); what to report and when is on the Quality
Metric page ([local copy](quality-metric.md)). This file holds the rules for
wiring reports into a codebase without losing outcomes or breaking the app.

## Where

- Report `true` at the point where the code already knows the event happened:
  after the booking is saved, the suggestion applied, the handoff created.
- Report `false` where the code knows the session ended without the event: the
  conversation closed, the run finished, the flow abandoned. Skip it when the
  code has no such point; an unreported session stays `false` by default.
- When the event fires far from the LLM call (another request, a webhook, a
  job), read the session ID from wherever the code stored it with the record.
- A shared helper goes next to the repo's existing HTTP or analytics
  utilities and reads `THREE_DEV_API_KEY` the way the code already reads it.

## When

- Report as soon as the outcome is known. A report can arrive before the
  session's first request is materialized; the API accepts it.
- When the event happened earlier than the report is sent (a confirmation from
  a downstream system, a later review), send its time as `ts`.
- A deferred report must outlive the request that scheduled it. Use the
  codebase's existing background job or queue. If there is none, report inline
  with a short timeout rather than from a thread that dies with the process.

## Failures

- Use a short timeout, so a slow API never slows a user-facing flow.
- When an outcome point has no session ID available, skip the report and log
  the skip. Never drop an outcome silently.
