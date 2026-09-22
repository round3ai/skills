# Reading offline experiment results

`get_offline_experiment` returns one block per variant, each compared with
control on the same requests. Always put the counts next to the rate.

The AI Judge scores `dataset_size` requests in every arm, control included, so
a one-variant run of 100 produces 200 verdicts and the app's progress bar
counts those, not the dataset.

## Quality

`quality.pass_count`, `fail_count`, `pass_rate`, and `p_beats_control`: the
probability that the variant's pass rate beats control's, computed from the AI
Judge counts alone. Report it as judge-only evidence with the counts; do not
turn it into a verdict. The app moves the experiment to its Statistical stage
once at least five domain expert assessments are in, and only then shows the
per-variant badge (Ship, Shippable, Promising, Inconclusive, Behind) and a
shipping recommendation. If the user asks whether to ship, point them there:
https://docs.three.dev/offline-experiments/understanding-results.md.

## Latency and cost

`latency.avg_ms`, and `p50_ms` and `p90_ms` posteriors; `cost.avg_request_usd`
and `avg_request_usd_posterior`. Each posterior carries `mean`, `ci90` (a 90%
credible interval), `p_beats_control` and `lift_vs_control`. Report the mean
with its interval. A cheaper or faster variant is only worth reporting as such
together with its quality line.

## Failure modes

The `failure_modes` block has a `status`, `per_variant` totals
(`total_requests`, `failed_requests`, `unclustered_failed_requests`), the
`modes` list, `omitted_modes` (how many small modes were left out; say so if
it is not zero) and a `how_to_read` or `note` line to pass on when present.

Per mode, `per_variant` cells carry `requests` (distinct failed requests) and
`rate`: requests over that variant's `total_requests`, not over scored
requests, because every replay is judged. `relative_change_vs_control` of −0.4
means 40% rarer; `new_vs_control` marks a mode the variant introduced;
`p_fewer_than_control` is the probability the variant has fewer failures of
that mode. On the mode itself, `origin: existing` means it was already seen
live and `origin: new` that it was first seen in this experiment.

## Saying what it means

Answer the question the experiment was built for, in one sentence, with the
numbers behind it:

- A model or cost question ("cheaper at the same quality"): the variant holds
  quality when its pass rate is not worse and no failure mode rose or appeared;
  then report the cost and latency deltas.
- A fix question ("does this prompt stop mode Y"): mode Y's rate should drop
  with `p_fewer_than_control` high, quality not worse, and nothing new in its
  place.
- Anything else: say what the numbers show and let the user decide.

Call a variant promising only when quality is not worse and the change it was
built for shows up; otherwise say so plainly.

## Reporting table

| Variant | Pass / total | Pass rate | P(beats control) | Avg latency | Avg cost |
| --- | --- | --- | --- | --- | --- |

then, once `failure_modes_ready`, one row per failure mode that moved:

| Failure mode | Control rate | Variant rate | Relative change | P(fewer) | Origin |
