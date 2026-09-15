# Metric endpoints

These endpoints have no docs page yet. Base URL `https://api.three.dev`, header
`Authorization: Bearer $THREE_DEV_API_KEY` on every call.

## Checking the key without printing it

For a plain `KEY=value` file:

```bash
set -a; . ./.env; set +a
curl -s -o /dev/null -w "%{http_code}\n" https://api.three.dev/api/v1/use-cases \
  -H "Authorization: Bearer $THREE_DEV_API_KEY"
```

`200` means the key works. When the key lives elsewhere (an exported shell
variable, an `.envrc`, a secrets manager), use that tool's "run one command with
the environment loaded" form, such as `direnv exec . <cmd>`. Never echo the key
or write it into a command the user can see.

## Listing metrics

`GET /api/v1/quality-metrics?use_case_slug=<slug>` → `200` and a bare JSON
array, not an object:

```json
[{"id", "slug", "name", "type", "optimize_for", "level", "is_system", "created_at", "outcomes": {...}}, ...]
```

Match on `slug`.

## Creating a metric

`POST /api/v1/quality-metrics` with

```json
{"slug": "booking-completed", "name": "Booking completed", "use_case_slug": "<slug>", "type": "binary", "optimize_for": "max"}
```

→ `201` with `{"metric_id": "<uuid>"}`. `optimize_for` is `"max"` when `true`
is good and `"min"` when `true` is bad.
