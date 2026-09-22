# Worked calls

All values below are placeholders: provider, model and reasoning come from
`list_available_models`, the control prompt from a recorded conversation, filter
values from `get_request_facets`.

## Naming it

Good and bad names for the same experiment:

| Instead of | Why it fails | Name it |
| --- | --- | --- |
| `Refund rule v2b` | a draft label; nothing says what changed | `Refund window named in prompt` |
| `Improve citation quality` | a goal, not a change; every experiment has one | `Cite source before answering` |
| `Prompt test 3` | names nothing | `Sonnet 5 vs GPT-5` |
| `Experiment comparing Sonnet 5 against the current production configuration on recent traffic` | that is the description | `Sonnet 5 at low reasoning effort` |

`description` says what the variants change and what traffic they run on. It is
not the question the experiment answers written out as a question: an
experiment list where every row opens with "Does ..." is a template, not a
description. This:

> Does tightening rule 2 (the policy lookup is the only valid check, search
> snippets are not, every policy statement ends with its article id) reduce the
> "Unverified policy claims" and "Fabricated or unsupported details" failure
> modes? Runs on production requests from the last 30 days that used prompt
> version v2.

says no more than this:

> The policy rule now makes the assistant read the article before stating a
> rule, and cite it. Last 30 days of production traffic on prompt v2.

Keep the second. The detail belongs in the variant names and the prompt, which
the experiment already carries.

## Compare two models, preview

```json
{"use_case_slug": "support-bot",
 "name": "GPT-5 vs Sonnet",
 "description": "GPT-5 and Sonnet replacing the production model, nothing else changed. Production traffic of the last 30 days.",
 "variants": [
   {"name": "GPT-5", "provider": "openai", "model": "gpt-5"},
   {"name": "Sonnet", "provider": "anthropic", "model": "claude-sonnet-5"}]}
```

## Prompt change on one segment

`control.prompt_template` is a recorded system prompt (from
`get_request_conversation` with `detail=full`) with every per-request value
replaced by a `{{placeholder}}`; two placeholders may not be adjacent. It is
matched anchored at both ends against each request's system message, else its
first user message, so every other character must be identical to the
recording. The variant's template applies the change to that copy and uses the
same placeholders.

```json
{"use_case_slug": "support-bot",
 "name": "Refund policy wording",
 "description": "The prompt now names the 14-day refund window. Production requests from customers on the pro plan.",
 "control": {
   "prompt_template": "You are the support assistant for {{company}}. ...",
   "filters": [{"field": "tag", "predicate": "eq", "key": "plan", "value": "pro"}]},
 "variants": [
   {"name": "Refund window named",
    "prompt_template": "You are the support assistant for {{company}}. Refunds are possible within 14 days of purchase. ..."}]}
```

## Reasoning setting

`reasoning_effort` and `adaptive_thinking` need `provider` and `model` on the
same variant, and only the values `list_available_models` lists for that model.

```json
{"name": "Low effort", "provider": "openai", "model": "gpt-5", "reasoning_effort": "low"}
```

## Dataset filters

`control.filters` accepts up to five conditions that must all match, on
`latency_ms`, `cost_usd` (`gt`, `gte`, `lt`, `lte`), `model`, `provider` (`eq`,
`in`) and `tag` (`eq`, with `key`). Omitted means all eligible traffic. Every
entry in `get_request_facets` carries an `example` you can pass as is.

## Reading the preview

- `eligible_request_count` is the traffic the filters matched; `dataset_size`
  is what will be replayed, capped by it.
- `ai_judge` is the judge three.dev chose, with `source` saying whether it came
  from live scoring or the active released judge.
- `dataset_note` appears below 100 eligible requests and says the comparison is
  weak.
- `estimated_cost` carries `total_usd` and `usd` per variant, `null` for a
  variant whose model has no list price; the total leaves that variant out, and
  is itself `null` when no variant has one. It prices the tokens the recorded
  requests used at list price, so it assumes similar response lengths and no
  prompt caching, and it leaves out AI Judge scoring. It is absent when no
  request is eligible.

## Creating it

Send the exact body you previewed to `create_offline_experiment`, which takes
the same arguments and always creates. The response carries `experiment_id`
and `experiment_url`; poll with

```json
{"use_case_slug": "support-bot", "experiment_id": "<uuid>"}
```
