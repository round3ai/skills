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
| `scoring` | `eq` | `scored`, `unscored`, `with_issues`, `clean` | Clean is scored with no issue |
| `provider` | `eq`, `in` | string | `in` takes up to five values |
| `model` | `eq`, `in` | string | Model requested |
| `failure_mode` | `eq`, `in` | failure mode id (UUID) | Ids from `list_failure_modes` or the facets; Unmatched has none, so filter `with_issues` and read `issues` |
| `tag` | `eq` | string, with `key` | `key` is the tag name |
| `session` | `eq` | a row's `session_id` | The rest of that conversation's turns inside the window; one per call |
| `status_class` | `eq`, `in` | `2xx`, `4xx`, `5xx` | Provider errors are `4xx`/`5xx` |
| `content` | `contains` | text, 3+ characters | Case-insensitive, input or output; `from` within the last 30 days; one per call |

## Worked calls

Count the scored requests with issues of the last week:

```json
{"use_case_slug": "support-bot", "from": "2026-09-03T00:00:00Z", "limit": 0,
 "filters": [{"field": "scoring", "predicate": "eq", "value": "with_issues"}]}
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

## Reading a row

- `input_preview` and `output_preview` are about 160 characters. Use
  `get_request_conversation` for the rest.
- Rows sharing a `session_id` are turns of one conversation, and a turn with
  an issue is often mid-conversation. Refilter on `session` to read the turns
  around it; rows with no `session_id` come from traffic that sends none.
- `total` is the matching count across all pages; do not page to count.
- To see who or what a row came from (a customer, an environment), ask for
  `include_tags`; to count per tag value, use `get_request_facets` with
  `facet: tag:<key>` instead of paging rows.
- For the oldest request, narrow `from`/`to` with `limit: 0` counts rather
  than paging to the end.

## Reading a failure mode

- `severity` is `high`, `medium`, `low` or unset. It is assigned when the mode
  is named and people change it in the app, so it is a priority hint and not a
  measurement; it is unset on most modes.
- **Unmatched** is often several problems in one, so its count says little;
  its examples say what they are.
- A **dismissed** mode is one the user set aside; a request whose only issues
  are dismissed is clean.
- A mode **merged** into another counts under that one; a mode **split** away
  no longer counts and its parts take its place. Report the modes it went to.
- An **outdated** request, `catalog_outdated` in `get_request_conversation`,
  was scored before a mode was created, split or merged: its issues show the
  failure modes as they stood then, so an Unmatched issue on it may belong to
  a mode named since.

## Questions outside the journey

- **"How many requests..." / "which models..." / "requests tagged..."**: call
  `get_request_facets` for the use case, then `list_requests` with filters copied
  from it and `limit=0`; read `total`, with the grammar above.
- **"How many of them are X rather than Y?"**: a split inside one failure mode,
  classified from its issues as in Step 3 of the skill.
- **"Show me bad conversations"**: `list_requests` with a `scoring`
  `with_issues` filter, then `get_request_conversation` on the ones the user
  picks.
- **"How did three.dev score my latest N requests?"**: `list_requests` with
  `include_issues=true`, paged until N rows; a rate of requests with issues
  over them is per scored row, not per `total`.
