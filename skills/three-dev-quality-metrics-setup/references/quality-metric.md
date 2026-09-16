<!-- Synced from https://docs.three.dev/live-experiments/quality-metric.md. Do not edit; the live page wins. -->

# Quality Metric

Live experiments measure quality through an event-based binary metric your application reports — a booking, a click, a resolution — attached to a session.

Live experiments measure quality through an event-based metric your application reports. Each metric is binary: an event either happened or it did not. A hotel booking completed, a user clicked a recommendation, a support ticket resolved. three.dev uses this metric as the primary target for the experiment, comparing how each variant performs against it.

Offline experiments use a different quality model — Acceptable Response, assessed per request by an AI Judge and domain experts. See [Offline quality metric](https://docs.three.dev/offline-experiments/quality-metric.md) for the contrast.

## Event-based model

Quality metrics follow an event-based model. Every metric starts `false` for every session and flips irreversibly to `true` when the event occurs.

The platform always knows the starting point: the event has not happened. When your application detects the event, it reports `true`, and the session's metric status is permanently updated. Report each metric once per session — reporting is a final action.

Because metrics are event-based, the platform expects to receive 100% of reports for events that happened. If no report arrives for a session, three.dev treats it as "the event has not happened yet", not as missing data. This allows the statistical engine to work without requiring explicit negative reports for every session.

## Optimization direction

three.dev categorizes quality metrics into two optimization directions:

* **Maximizing metrics** track positive outcomes you want as often as possible. A `true` evaluation represents a success — for example, a "Code Review Assistant" metric tracking whether the developer accepted the suggested code change.
* **Minimizing metrics** track negative outcomes you want to prevent. A `true` evaluation represents an undesirable event — for example, a "Customer Support Bot" metric tracking the escalation rate to a human agent.

Set the direction when you create the metric on the [Metrics](https://app.three.dev/metrics) page, or with the `optimize_for` field (`max` or `min`) of the report that creates the metric. See [Report Metric](https://docs.three.dev/api-reference/report-metric.md#creating-the-metric-on-first-report).

## Reporting metrics

Report metric outcomes from your application code using the [Report Metric](https://docs.three.dev/api-reference/report-metric.md) endpoint. You do not need to create the metric first: include `optimize_for` in the report, and three.dev creates the metric on its first report.

### What to report

At minimum, **report when the event happens** (`true`). Unreported sessions stay in their default state (`false`), so you do not need to report every session where the event did not occur.

If your application can determine that the event **definitively did not happen** — for example, the user closed the conversation without completing a purchase — report `false`. Reporting definitive negatives removes ambiguity: the platform no longer assumes the session might still convert. This leads to more reliable estimates and experiments that reach conclusions sooner.

### When to report

Report as soon as your application can determine the outcome:

* **Immediately** — the user clicked "thumbs up" or completed a checkout.
* **After a delay** — a human reviewer judged the response quality hours later.
* **Asynchronously** — a downstream system confirmed the action succeeded.
* **On session end** — the user closed the conversation without converting, so you report `false`.

There is no deadline. Sessions without a reported metric are assumed to be in their default state, and the statistical engine accounts for them by modeling the probability they might still convert.

Report each metric once per session. If a session has multiple opportunities to succeed (for example, multiple turns in a conversation), report the final outcome.

## Next

See [Creating experiments](https://docs.three.dev/live-experiments/creating-experiments.md) to set up a live experiment targeting your quality metric.
