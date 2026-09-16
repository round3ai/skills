<!-- Synced from https://docs.three.dev/api-reference/report-metric.md. Do not edit; the live page wins. -->

# Report Metric

Report a binary quality metric outcome for a session.

Report a binary outcome for a quality metric on a specific session.

## Request

```
POST /api/v1/metrics/report
```

**Headers:**

| Header          | Required | Value                        |
| --------------- | -------- | ---------------------------- |
| `Authorization` | Yes      | `Bearer <THREE_DEV_API_KEY>` |
| `Content-Type`  | Yes      | `application/json`           |

**Body:**

| Field          | Type    | Required | Description                                                                                                                                                                                                                                                     |
| -------------- | ------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `metric`       | string  | Yes      | The metric slug.                                                                                                                                                                                                                                                |
| `use_case`     | string  | Yes      | The use case slug.                                                                                                                                                                                                                                              |
| `session_id`   | string  | Yes      | The session identifier. Must match the session ID used in the proxy request and the assignment call.                                                                                                                                                            |
| `outcome`      | boolean | Yes      | `true` if the session achieved the desired outcome, `false` otherwise.                                                                                                                                                                                          |
| `ts`           | string  | No       | ISO 8601 timestamp for when the outcome occurred. Defaults to the server's receive time. Providing this timestamp can improve the accuracy of the statistical analysis.                                                                                         |
| `optimize_for` | string  | No       | `max` or `min`, the metric's [optimization direction](https://docs.three.dev/live-experiments/quality-metric.md#optimization-direction). When set, three.dev creates the metric on its first report. See [Creating the metric on first report](#creating-the-metric-on-first-report). |

**Example:**

```bash
curl -X POST https://api.three.dev/api/v1/metrics/report \
  -H "Authorization: Bearer <THREE_DEV_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "metric": "hotel-booked",
    "use_case": "hotel-booking-assistant",
    "session_id": "78d7ee4c-c9f0-4515-9353-17283f3eb910",
    "outcome": true
  }'
```

## Creating the metric on first report

Without `optimize_for`, the metric must already exist in the use case. A deleted metric still counts as existing: three.dev records the report against it without restoring it. Send `optimize_for` to skip creating it first: when the use case has no metric with the `metric` slug, three.dev creates one and records the report against it. The new metric:

* Is binary and attaches to sessions.
* Takes the slug as its name.
* Optimizes in the direction set by `optimize_for`.

To create the metric, `metric` must be a valid slug: lowercase letters and digits in groups joined by single hyphens, at most 64 characters (for example, `hotel-booked`).

Later reports for the same metric can omit `optimize_for`. The field has no effect on a metric that already exists: three.dev keeps its name and direction and records the report against it. If you deleted a metric with the same slug, three.dev restores it and records the report against it. The restored metric takes the slug as its name, replacing the name it had, and optimizes in the direction set by `optimize_for`.

three.dev creates at most 50 metrics per use case this way. Metrics you create in the app do not count toward the limit, and deleting a metric three.dev created frees a slot.

If the use case does not exist either, three.dev creates it too, and `use_case` must be a valid slug as well. The new use case is the same as one created from a first proxied request, and counts toward the same limit of 20 per organization. See [Creating use cases](https://docs.three.dev/sending-requests/sending-requests.md#creating-use-cases).

**Example:**

```bash
curl -X POST https://api.three.dev/api/v1/metrics/report \
  -H "Authorization: Bearer <THREE_DEV_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "metric": "escalated-to-human",
    "use_case": "customer-support-bot",
    "session_id": "78d7ee4c-c9f0-4515-9353-17283f3eb910",
    "outcome": true,
    "optimize_for": "min"
  }'
```

## Response

**Success:** HTTP 201 Created with an empty body.

**Errors:**

| Status | Cause                                                                                                                                                                                                                                                         |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400    | `ts` is too old or earlier than the session's first request.                                                                                                                                                                                                  |
| 400    | `optimize_for` is not `max` or `min`.                                                                                                                                                                                                                         |
| 400    | three.dev would create the use case, but `use_case` is not a [valid slug](#creating-the-metric-on-first-report) or the organization already has 20 use cases three.dev created.                                                                               |
| 400    | three.dev would create the metric, but `metric` is not a [valid slug](#creating-the-metric-on-first-report), is reserved for a system metric (`verdict-<use_case>` or `verdict-paired-<use_case>`), or the use case already has 50 metrics three.dev created. |
| 400    | three.dev would restore a deleted metric that three.dev created, but the use case already has 50 metrics three.dev created.                                                                                                                                   |
| 404    | The metric or the use case does not exist and the request has no `optimize_for`. A deleted metric does not return 404.                                                                                                                                        |
