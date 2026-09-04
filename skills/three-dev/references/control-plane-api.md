# Control-plane endpoints

These endpoints have no docs page yet. Base URL `https://api.three.dev`, header
`Authorization: Bearer $THREE_DEV_API_KEY` on every call. All slugs match
`^[a-z0-9]+(?:-[a-z0-9]+)*$`.

## Use cases

`GET /api/v1/use-cases` → `200`

```json
{"use_cases": [{"id", "org_id", "name", "slug", "created_at", "creator_type", "creator_slug", "auto_created"}, ...]}
```

Match on `slug`. `auto_created` is true when three.dev created the use case on
the first proxied request under its slug rather than through the UI or this API.

`POST /api/v1/use-cases` with `{"name": "...", "slug": "..."}` → `201`

```json
{"use_case_id": "<uuid>"}
```

## Quality metrics

`GET /api/v1/quality-metrics?use_case_slug=<slug>` → `200` and a bare JSON
array, not an object:

```json
[{"id", "slug", "name", "type", "optimize_for", "level", "is_system", "created_at", "outcomes": {...}}, ...]
```

Match on `slug`. The array includes three.dev's own built-in metrics, marked
`"is_system": true`; never treat one of those as a metric you created. A use
case that does not exist yet returns `404`, which means "no metrics", not an
error.

`POST /api/v1/quality-metrics` with
`{"slug": "...", "name": "...", "use_case_slug": "...", "type": "binary", "optimize_for": "max" | "min"}`
→ `201`

```json
{"metric_id": "<uuid>"}
```

`optimize_for: "max"` means true is good (a booking completed). `"min"` means
true is bad (escalated to a human).

## Validating the key without printing it

For a plain `KEY=value` file:

```bash
set -a; . ./.env; set +a
curl -s -w "\n%{http_code}\n" https://api.three.dev/api/v1/use-cases \
  -H "Authorization: Bearer $THREE_DEV_API_KEY"
```

If the key lives somewhere that is not sourceable that way (an `.envrc`, a
secrets manager, an IDE run configuration), use that tool's own "run one
command with the environment loaded" form, such as `direnv exec . <cmd>`.
Never reformat the user's setup to suit the check. Never echo the key or write
it into a command the user can see.
