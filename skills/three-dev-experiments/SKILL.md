---
name: three-dev-experiments
description: Runs an offline experiment in three.dev to test a prompt, model, or reasoning change on recorded production traffic, and reads the results. Use when the user has a change in hand and wants to know whether it is better, cheaper, or faster before shipping, wants to compare two models or providers on their own traffic, asks whether a cheaper or smaller model holds the same quality, wants to A/B test a prompt, or asks what an existing offline experiment showed. Also routes live experiments, which run on real users and start in the three.dev app. Needs the three.dev MCP server. Not for finding out why a feature is failing in production; that is the three-dev-failure-modes skill. Not for wiring calls through the proxy; that is the three-dev-setup skill. Not for defining or reporting the quality metric a live experiment measures; that is the three-dev-quality-metrics-setup skill.
---

# three.dev experiments

three.dev records every LLM call that goes through its proxy. An **offline
experiment** replays a sample of those recorded requests through one or more
**variants** (a different model, reasoning setting, prompt template, or a
combination) and has the use case's AI Judge score every reply next to the
**control**, the production configuration on the same requests. The result is
quality, latency, cost and failure modes per variant against control, on the
user's own traffic, without touching a user.

A **live experiment** assigns a share of real user sessions to each variant and
measures the quality metrics the user's code reports. No tool here creates or
reads one: it starts in the three.dev app at
https://docs.three.dev/getting-started/quickstart-run-live-experiment.md. When the
user wants a live experiment and has no metric yet, load the
`three-dev-quality-metrics-setup` skill first.

If `list_use_cases` returns nothing, traffic is not flowing yet; use the
`three-dev-setup` skill first. If the experiment tools are missing from the tool list
or answer that they are not enabled for the organization, say so and stop; do
not retry or work around it.

## Where the facts are

| Need | Tool |
| --- | --- |
| Which use cases exist, their slugs | `list_use_cases` |
| Providers, models and reasoning settings a variant may use | `list_available_models` |
| Size and validate a proposal | `preview_offline_experiment` |
| Create it once the user asked or confirmed | `create_offline_experiment` |
| Status and results of one experiment | `get_offline_experiment` |
| The use case's past and running experiments | `list_offline_experiments` |
| Values a dataset filter can take | `get_request_facets` |
| The replayed conversations themselves | `list_requests` with an `experiment` filter, then `get_request_conversation` |
| How three.dev itself works | `search_docs`, then `read_doc` |

## Ground rules

- **Never start an offline experiment on your own.** It spends the user's
  provider and AI Judge budget and runs for hours. When the user asked for the
  experiment or already said yes to your proposal, preview it and then create it
  without asking again; the preview is validation, not a second request for
  permission. When the experiment is your own idea, propose it with the preview
  numbers and wait for an explicit yes.
- **Copy, do not type.** `provider`, `model` and reasoning values come verbatim
  from `list_available_models`; the control prompt template comes verbatim from
  a recorded system message. A typed value is rejected or, worse, silently tests
  the wrong thing.
- **Results are judge-only evidence.** Report counts next to every rate and
  `p_beats_control` as a probability, not a verdict. The shipping recommendation
  comes from the app's Statistical stage once domain experts have assessed a
  sample; when the user asks whether to ship, point them there.
- **Be brief.** No narration of tool calls. Numbers go in a table with their
  denominators.

## Workflow

### Step 0: Pick the use case and the question

If the user named a use case, use its slug; otherwise call `list_use_cases`,
use the only one, or ask by number. Then state the question in one line before
building anything: "does model X match control's quality at lower cost", "does
this prompt wording stop failure mode Y", "does reasoning effort low cut latency".
That question is yours to aim with; the `description` field states what the
variants change and what traffic they run on, in plain language a customer
would say out loud: no parentheses, no quoted failure-mode names, no jargon,
and not the question written out again. Its `name` is the change itself in 3 to 6
plain words, in the user's own vocabulary: the phrase a customer scanning the
experiment list a month later would recognise, never a goal or a draft label.
Good and bad names: [references/worked-calls.md](references/worked-calls.md).

If the user only wants to know what an experiment showed, skip to Step 4.

### Step 1: Build the variants

Call `list_available_models`. One variant per change the user wants to compare,
up to nine; a variant changes the model (provider and model together), the
prompt, reasoning, or several at once. Keep each variant to one idea so the
result attributes the difference. A two-model comparison is two variants, one
per model, against the same control.

For a prompt change, `control.prompt_template` is a template that must parse
every recorded request it will replay: three.dev matches it against the system
message, else the first user message, anchored at both ends, and drops every
request it does not match when the experiment starts. Build it from recorded
conversations, not from the user's source code:

1. `get_request_conversation` with `detail=full` on two or three recent
   requests. The default view caps the system prompt, and a template copied
   from a capped prompt matches nothing.
2. Copy one system prompt character for character. Replace only what differs
   between the conversations (a name, a date, retrieved context) with
   `{{placeholder}}`s; two placeholders may not touch, put literal text
   between them. Do not tidy whitespace or wording.
3. Check the template against the other conversations by eye before the dry
   run. The preview does not test it.

The variant's `prompt_template` is that template with the user's change
applied, using the same placeholders. The preview's count does not account for
the template; a `progress.total` well below it once the experiment runs is the
tell that the template matched few requests. Worked calls:
[references/worked-calls.md](references/worked-calls.md).

### Step 2: Size it with a preview

Call `preview_offline_experiment` with the body you would create. Nothing
enforces this step: `create_offline_experiment` called on its own creates the
experiment unsized. The preview creates nothing, needs no consent, and sizes
the dataset, resolves the judge and validates the variants; read its numbers
with
[references/worked-calls.md](references/worked-calls.md). The tool's parameter
descriptions say which requests are eligible and the dataset size bounds;
repeat them to the user when proposing.

- On a weak dataset, widen the filters, or the user proceeds knowingly.
- Treat the cost figure as rough when you quote it.
- Keep the default `dataset_size` unless the behaviour under test is rare
  enough that the default would hold too few cases; then raise it and say why.
- `control.filters` narrow the dataset to the traffic the question is about,
  with values from `get_request_facets`: one model or provider when the change
  only concerns it, a tag such as `environment` or a customer segment, a
  latency or cost band. Fields and predicates:
  [references/worked-calls.md](references/worked-calls.md).
- If the call fails because the use case has no released AI Judge, the user
  creates one in the app first; there is no tool for that. If it answers that
  prompt offline experiments are not enabled for the organization, report that
  as is; model and reasoning variants still work.
- A variant must change something: provider and model together, a reasoning
  setting (with provider and model), or the prompt. The tool rejects one that
  changes nothing.

### Step 3: Propose, or create

If the user asked for this experiment or confirmed it, create it now with
the exact body you previewed. Otherwise show the proposal
and ask "Do you want me to start this experiment?", then wait. The proposal
names:

- the name it will be saved under;
- each variant and what it changes (provider and model, reasoning, prompt);
- the dataset: the preview's count, the filters used, and the judge;
- that replays and judging spend the user's provider and AI Judge budget, with
  the preview's `estimated_cost` as the rough replay figure, judge cost on top;
- that it takes minutes to hours.

After creating, show the name and the `experiment_url` and say the user can
close the conversation; results stay in the app.

### Step 4: Read the results

`get_offline_experiment` takes the experiment's UUID from the create or list
response; `list_requests` filters take its `slug`, from the same responses.
Call it every few minutes while the user waits, or once when they come back.
`results_ready` means quality, latency and cost are final; do not wait for
`status: finished`. `failure_modes_ready` means the failure-mode comparison is
in. `error_reason` means it failed; report the reason as is (a missing provider
key for a variant's provider is the common one, fixed in the app). Each
variant's `progress` counts `replayed`, `replay_failed`, `judged`,
`judge_failed` and `judge_skipped`; report a variant whose failures are a
sizeable share of `total` as unreliable rather than reading its rates.

Report per variant against control using
[references/results.md](references/results.md): pass counts and rate with
`p_beats_control`, latency and cost, and which failure modes fell, rose, or are
new. Answer the Step 0 question in one sentence, with the numbers that support
it, and stop. To show what a variant actually said, `list_requests` with the
`experiment` and `variant` filters pairs replays with their production request
on `source_request_id`; read a few with `get_request_conversation`.

### Existing experiments

"What did we test on this use case?" is `list_offline_experiments`, newest
first. It pages, so answer "no experiment tried X" only once you have paged to
the end. "What did experiment X show?" is
`get_offline_experiment`, read as in Step 4. When the user found a problem
in production and wants it fixed, not just measured, hand over to the
`three-dev-failure-modes` skill; come back here with the fix.

## Hard rules

- `create_offline_experiment` only when the user asked for the experiment or
  said yes to the specific proposal you showed; then do not ask again. It always
  creates; sizing is `preview_offline_experiment`.
- Provider, model, reasoning values and the control prompt are copied, never
  typed from memory.
- Every rate is reported with its counts; `p_beats_control` is evidence, not a
  ship decision.
- A control prompt template is copied from a `detail=full` conversation and
  checked against others; a template that does not parse a request silently
  drops it.
- Experiment ids are UUIDs and experiment slugs are slugs; copy each exactly
  from a result and use the one the tool asks for.
