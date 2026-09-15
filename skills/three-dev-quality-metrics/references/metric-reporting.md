# Metric reporting

The endpoint and its body are on the Report Metric page
([local copy](report-metric.md)); what to report and when is on the Quality
Metric page ([local copy](quality-metric.md)). This file holds the rules for
wiring reports into a codebase without losing outcomes or breaking the app.

## What every report sends

- `metric`, `use_case`, `session_id` and `outcome`, as on the Report Metric
  page, plus `optimize_for` with the direction settled in Step 2.
- A metric three.dev creates from a report is named after its slug. Without
  `optimize_for`, a report under an unknown slug is rejected and the outcome is
  lost.
- An active metric keeps its own direction; `optimize_for` does not change it.
  A deleted metric is re-enabled by the next report, taking that report's
  direction and its slug as name.
- A use case accepts at most 50 active auto-created metrics.
- `verdict-<use case slug>` and `verdict-paired-<use case slug>` are reserved
  for three.dev's built-in metrics and are rejected.
- Because every report carries `optimize_for`, deleting the metric in three.dev
  does not stop it: the next report restores it. To retire a metric, remove its
  report from the code.

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
  a downstream system, a later review), send its time as `ts`. A `ts` older
  than 7 days is rejected, so report late outcomes within that window.
- A deferred report must outlive the request that scheduled it. Use the
  codebase's existing background job or queue. If there is none, report inline
  with a short timeout rather than from a thread that dies with the process.

## Failures

- Use a short timeout, so a slow API never slows a user-facing flow.
- When an outcome point has no session ID available, skip the report and log
  the skip. Never drop an outcome silently.
