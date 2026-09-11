# Worked calls

All values below are placeholders: provider, model and reasoning come from
`list_available_models`, the control prompt from a recorded conversation, filter
values from `get_request_facets`.

## Compare two models, dry run

```json
{"use_case_slug": "support-bot",
 "name": "GPT-5 vs Sonnet",
 "description": "Does either model match control's pass rate at lower cost? Production traffic of the last 30 days.",
 "dry_run": true,
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
 "description": "Does naming the refund window stop wrong refund promises? Production requests of the pro plan.",
 "dry_run": true,
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

## Creating it

Repeat the exact dry-run body with `"dry_run": false`. The response carries
`experiment_id` and `experiment_url`; poll with

```json
{"use_case_slug": "support-bot", "experiment_id": "<uuid>"}
```
