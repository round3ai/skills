# Verifying a fix with an offline experiment

An offline experiment replays a sample of recorded production requests through
one or more **variants** (a different model, reasoning setting, prompt template,
or a combination) and has the use case's AI Judge score every reply, next to the
**control**: the production configuration on the same requests. Results compare
quality, latency, cost and failure modes per variant against control.

## Before proposing one

1. `list_available_models`: the providers and models the organization can use,
   and per model the reasoning settings it accepts. A variant's `provider` and
   `model` are copied from here verbatim.
2. For a prompt change, copy the current prompt template verbatim from a recorded
   conversation and apply the change to it. Requests the control template does not
   match are dropped when the experiment starts, so the final dataset can be
   smaller than the dry run says.
3. `create_offline_experiment` with `dry_run=true`: returns the eligible request
   count, the AI Judge that will be used, and the validated variants. It creates
   nothing and needs no consent. The dataset is the newest matching requests from
   the last 30 days that succeeded and are not already in an experiment; at least
   100 must match. Use `filters` (same grammar as `list_requests`) to target the
   traffic the failure mode lives in.

If the use case has no released AI Judge the call fails; the user creates one in
the three.dev app first.

## The proposal

Show, then ask "Do you want me to start this experiment?" and wait:

| Variant | Change | Provider / model | Reasoning |
| Dataset | N requests (from the dry run), filters used |
| Cost | replays and judging use the user's provider and AI Judge budget |
| Time | minutes to hours |

`dataset_size` defaults to 500 (minimum 100, maximum 2000). Prefer the default;
raise it only when the failure mode is rare enough that 500 requests would hold
too few occurrences to show a change.

## Running it

`create_offline_experiment` with `dry_run=false` and the exact proposal. Show the
`experiment_url`. Then `get_offline_experiment` every few minutes:

- `results_ready`: quality, latency and cost are final. Do not wait for
  `status: finished`.
- `failure_modes_ready`: the failure-mode comparison is in.
- `error_reason`: the experiment failed; report it.

## Reading the results

Per variant, always with counts next to rates:

- **Quality**: `pass_count`, `fail_count`, `pass_rate`, and `p_beats_control`,
  the probability that the variant's pass rate beats control's, computed from the
  AI Judge counts alone. Report it as judge-only evidence with the counts; do not
  turn it into a verdict. The app's Statistical stage adds domain expert
  assessments and gives the shipping recommendation (Ship, Shippable, Promising,
  Inconclusive, Behind). If the user asks whether to ship, point them there.
- **Latency**: `avg_ms` and p50/p90 posteriors with `p_beats_control`.
- **Cost**: `avg_request_usd` and its posterior.
- **Failure modes**: for each mode, distinct failed requests and their rate per
  variant (rate is requests over that variant's total requests, not over scored
  requests, because every replay is judged),
  `relative_change_vs_control` (−0.4 means 40% rarer), `new_vs_control` for a
  mode the variant introduced, and `p_fewer_than_control`. `origin: existing`
  is a mode already seen live; `origin: new` was first seen in this experiment.
  The mode being fixed should drop; check that nothing new appeared in its place.

Call a variant promising only when quality is not worse and the target failure
mode dropped without new ones appearing; otherwise say what the numbers show and
let the user decide.
