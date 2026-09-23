# Filtering requests

`list_requests` takes `filters`, a list of up to five conditions that must all
match. Each is `{field, predicate, value}` plus `key` for tags. Call
`get_request_facets` first: it returns, per field, the values present in the
window, and every entry's `example` is a filter you can pass as is. The
predicates each field accepts are in the table below.

| Field | Predicates | Value | Notes |
| --- | --- | --- | --- |
| `latency_ms` | `gt`, `gte`, `lt`, `lte` | number | Facets give `min`/`max` |
| `cost_usd` | `gt`, `gte`, `lt`, `lte` | number | Per request |
| `judge` | `eq` | `scored`, `unscored`, `pass`, `fail` | Live AI Judge verdict |
| `provider` | `eq`, `in` | string | `in` takes up to five values |
| `model` | `eq`, `in` | string | Model requested |
| `failure_mode` | `eq`, `in` | failure mode id (UUID) | Ids from `list_failure_modes` or the facets |
| `tag` | `eq` | string, with `key` | `key` is the tag name |
| `experiment` | `eq` | experiment slug | Switches the listing to that experiment's traffic and ignores `from`/`to` |
| `variant` | `eq` | variant slug | Only with `experiment`; `control` is production |
| `session` | `eq` | a row's `session_id` | The rest of that conversation's turns inside the window; one per call |
| `status_class` | `eq`, `in` | `2xx`, `4xx`, `5xx` | Provider errors are `4xx`/`5xx` |
| `content` | `contains` | text, 3+ characters | Case-insensitive, input or output; `from` within the last 30 days; not with `experiment`; one per call |

## Worked calls

Count the failed scored requests of the last week:

```json
{"use_case_slug": "support-bot", "from": "2026-09-03T00:00:00Z", "limit": 0,
 "filters": [{"field": "judge", "predicate": "eq", "value": "fail"}]}
```

Browse one failure mode's traffic for a customer segment:

```json
{"use_case_slug": "support-bot", "limit": 10,
 "filters": [
   {"field": "failure_mode", "predicate": "eq", "value": "019a2c3e-...-..."},
   {"field": "tag", "predicate": "eq", "key": "environment", "value": "production"}]}
```

Find the conversations that mention a refund:

```json
{"use_case_slug": "support-bot", "limit": 10,
 "filters": [{"field": "content", "predicate": "contains", "value": "refund"}]}
```

Compare a variant's replies with control in an offline experiment:

```json
{"use_case_slug": "support-bot", "limit": 10,
 "filters": [
   {"field": "experiment", "predicate": "eq", "value": "gpt-5-vs-sonnet"},
   {"field": "variant", "predicate": "eq", "value": "sonnet"}]}
```

Under an experiment each row carries `variant`, `is_replay` and, for a replay,
`source_request_id`, the production request it re-ran. The control rows list the
same id, so the two sides pair on it.

## Reading a row

- `input_preview` and `output_preview` are about 160 characters. Use
  `get_request_conversation` for the rest.
- Rows sharing a `session_id` are turns of one conversation, and a flagged
  turn is often mid-conversation. Refilter on `session` to read the turns
  around it; rows with no `session_id` come from traffic that sends none.
- `total` is the matching count across all pages; do not page to count.
- To see who or what a row came from (a customer, an environment), ask for
  `include_tags`; to count per tag value, use `get_request_facets` with
  `facet: tag:<key>` instead of paging rows.
- For the oldest request, narrow `from`/`to` with `limit: 0` counts rather
  than paging to the end.

## Reading a failure mode

- `severity` is `high`, `medium`, `low` or `unknown`. It is assigned when the
  mode is grouped and people change it in the app, so it is a priority hint and
  not a measurement; it is `unknown` on most modes.
- `is_unknown` marks the catch-all group of failures that matched no mode. It
  is often several problems in one, so read its examples rather than its count.
