---
name: three-dev-failure-modes
description: Investigates production quality problems in an LLM feature that three.dev already records. Triages the AI Judge's failure modes, reads the flagged conversations, finds the root cause, proposes a prompt, model, or code fix, and optionally verifies it with an offline experiment on recorded traffic. Use when the user asks why an LLM feature is failing or misbehaving in production, what its top failure modes, issues, or quality problems are, whether a problem is growing or started after a deploy, wants to see bad conversations or count or segment requests, or wants to test a prompt or model change offline before shipping. Needs the three.dev MCP server. Not for setting up three.dev, routing calls through the proxy, or defining quality metrics; that is the three-dev skill.
---

# three.dev failure-mode investigation

three.dev records every LLM call that goes through its proxy. An AI Judge scores a
sample of the production traffic of each use case and groups the failures it finds
into **failure modes**: recurring problems named in the product's own words, each
with a severity, counts, first and last seen, and example requests. This skill
turns those into a diagnosis grounded in real conversations and a fix the user can
apply, and verifies the fix against recorded traffic when the user wants that.

If the user's code is not sending traffic through three.dev yet, or `list_use_cases`
returns nothing, stop and use the `three-dev` skill first. Quality metrics (the
outcomes the user's code reports, set up by that skill) are a different signal
from failure modes and no tool here reads them; say so if asked about one.

## Where the facts are

Everything comes from the three.dev MCP server. If it is not connected, say so and
stop; do not answer from the prompt or the code alone. The tools:

| Need | Tool |
| --- | --- |
| Which use cases exist, their slugs | `list_use_cases` |
| Failure modes of a use case in a window, with counts and denominators | `list_failure_modes` |
| One failure mode in depth, with example requests | `get_failure_mode` |
| The full conversation behind one request | `get_request_conversation` |
| What the requests can be filtered by, and the values present | `get_request_facets` |
| Count, segment or browse requests | `list_requests` |
| Test a change offline | `list_available_models`, `create_offline_experiment`, `get_offline_experiment`, `list_offline_experiments` |
| How three.dev itself works | `search_docs`, then `read_doc` |

Every result carries `url` fields and an "Open in three.dev" link. Show them
verbatim when the user wants to look; never compose an app URL yourself.

## What the numbers mean

- **Only a sample is judged.** Live scoring runs on a sampling rate (often 1% or
  less). A failure rate is `occurrence_count / totals.scored_requests` (or
  `request_count / totals.scored_requests`). Never divide by `total_requests` and
  never report an occurrence count as if it were the share of all traffic.
- **The app shows a different number.** The failure-modes page and the docs show
  each mode's share of all failures (its requests over all failed requests). The
  tools return counts with denominators so you can report the rate per scored
  request. Both are valid; name the one you report, and use the tool
  denominators for rates even where the docs describe the share.
- **Occurrences and requests differ.** One request can hold several failure modes
  and one mode can fire more than once in a request, so occurrences can exceed
  requests and shares can add up to more than 100%.
- **Windows.** `from` and `to` are RFC3339, `to` exclusive. No window means the
  last 14 days; `to` alone means the 7 days before it. Every windowed result
  returns the `window` it answered for; report that, not the one you asked for.
- **`scored` and `failure_mode_ids` on a request.** An empty `failure_mode_ids`
  means either scored and clean or not scored at all. Read `scored` first.
- **Severity** (`high`, `medium`, `low`, `unknown`) is assigned when the mode is
  grouped and can be changed by people in the app. It is a priority hint, not a
  measurement.
- **`is_unknown`** marks the catch-all group of failures that matched no mode.
  Read its examples; it is often several problems in one.
- **No lifecycle.** A failure mode is never "resolved" in three.dev. Fixed means
  its rate dropped in a later window.

## Ground rules

- **Ground every claim in a conversation you read.** Name the request and quote
  the turn. A hypothesis from the description alone is labelled as such.
- **The user approves, you do.** Present findings and the proposed fix, then stop.
  Never edit the user's code, prompt, or configuration without a yes.
- **Never start an offline experiment on your own.** It spends the user's provider
  and AI Judge budget and runs for hours. When the user asked for the experiment
  or already said yes to your proposal, dry-run it and then create it without
  asking again; a dry run is validation, not a second request for permission.
  When the experiment is your own idea, propose it with the dry-run numbers and
  wait for an explicit yes. See
  [references/offline-experiments.md](references/offline-experiments.md).
- **Be brief.** No narration of tool calls. Numbers go in a table with their
  denominators next to them.
- **Prefer aggregates.** Ranking and counting come from `list_failure_modes`,
  `get_request_facets` and `list_requests` with `limit=0`. Read individual
  conversations to explain, not to count; two or three per failure mode is
  usually enough.

## Workflow

### Step 0: Pick the use case

If the user named one, use its slug. Otherwise call `list_use_cases`; with one
result use it, with several ask by number. If the user's question is about one
request id, go straight to Step 4; `get_request_conversation` also needs the use
case slug, so try the use cases in turn when it is unknown. No tool reads a
session; say so and ask for a request id from it.

If `list_failure_modes` answers that failure modes are not available for the use
case, report that message as is and stop that branch. If the offline-experiment
tools are missing from the tool list, or answer that they are not enabled for
the organization, offline experiments are not enabled: say so and skip Step 6.
Do not retry or work around either.

### Step 1: List and rank the failure modes

Call `list_failure_modes` for the use case. Default window unless the user is
asking about a change or a period; then pass `from`/`to` around it. Present:

| # | Failure mode | Severity | Occurrences | Requests | Rate per scored request | First seen | Last seen |

State the denominators once above the table: scored requests and total requests
in the window.

If the list is empty, find out why before answering. Call `list_requests` with
`limit=0` for the same window: no requests means the use case is not receiving
traffic, use the `three-dev` skill; requests but `totals.scored_requests` of zero
means live scoring is not enabled or has not sampled yet, point the user to
https://docs.three.dev/live-scoring/live-scoring.md; otherwise say what the
`note` says and offer a wider window. Then stop.

Rank by severity first, then rate. Offer the top one or two, or the one the user
named, as a numbered list with your recommendation marked, one question at a
time, using a structured question tool if one exists, and wait.

### Step 2: Check the trend when it matters

When the user asks whether something is new, growing, or caused by a deploy, call
`list_failure_modes` or `get_failure_mode` once per window and compare rates, not
counts: for a deploy, `to = deploy_time` against `from = deploy_time`; for growth,
the last 3 days against the 11 days before them. Windows must not overlap. Say
when the two windows have too few scored requests to tell (a handful of
occurrences either side is noise).

### Step 3: Drill into the chosen failure mode

Call `get_failure_mode` with the same window. Read the full description and each
example's `failure_summaries`, which are the judge's own reasons. If the examples
look alike, that is the pattern; if they differ, group them and say so. To see
the mode's traffic beyond the examples, call `list_requests` with a
`failure_mode` filter (see [references/filters.md](references/filters.md)).

### Step 4: Read the conversations

Call `get_request_conversation` on two or three example `request_id`s, choosing
different-looking ones. Conversations can be long; if a client hands you a large
result as a file instead of text, read the file. Read the system prompt and the
tool names once, then the turns around the failure; ask for `detail=full` or
`include_tools=true` only when a capped part or a tool definition matters. Look for what the model
saw and what it did: a missing or contradicting instruction, a tool result it
ignored, a fact it invented, a format it broke, a context it lost.

Also read one conversation that passed when the failure looks input-dependent.
A conversation carries its `session_id`; the request's app link opens the whole
session when the failure needs the earlier turns.

### Step 5: Report

Use [references/report-template.md](references/report-template.md): what the
failure mode is, since when and how often (rate with counts and window), the
root cause with quoted evidence, the proposed fix in the user's codebase, and how
to verify it. Where the fix is a prompt change, write the exact new wording in
the report, not in the user's files. Where the fix is a model or parameter
change, say what to compare.

Then stop and wait.

### Step 6: Verify offline, on request

If the user wants the fix tested before shipping, follow
[references/offline-experiments.md](references/offline-experiments.md):
`list_available_models`, a `dry_run=true` sizing, the proposal, the user's yes,
`create_offline_experiment`, then `get_offline_experiment` until `results_ready`.
Report the pass counts with `p_beats_control`, whether the failure mode being
fixed dropped, and whether new ones appeared. These are AI Judge results only;
the shipping recommendation comes from the app once domain experts have assessed
a sample.

## Other questions this skill answers

- **"How many requests..." / "which models..." / "requests tagged..."**: call
  `get_request_facets` for the use case, then `list_requests` with filters copied
  from it and `limit=0`; read `total`. Grammar and examples in
  [references/filters.md](references/filters.md).
- **"Show me bad conversations"**: `list_requests` with a `judge` `fail` filter,
  then `get_request_conversation` on the ones the user picks.
- **"What did the experiment change?"**: `get_offline_experiment`; read the
  `failure_modes` block per variant against control.

## Hard rules

- Rates are per `scored_requests`. If you cannot state the denominator, do not
  state the rate.
- Failure mode ids and request ids are UUIDs; copy them exactly from a result.
- The `to` bound is exclusive and windows are RFC3339 with an offset
  (`2026-09-01T00:00:00Z`).
- `create_offline_experiment` with `dry_run=false` only when the user asked for
  the experiment or said yes to the specific proposal you showed; then do not
  ask again.
- Do not paraphrase a conversation as evidence; quote it.
