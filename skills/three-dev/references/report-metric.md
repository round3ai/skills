<!-- Synced from https://docs.three.dev/api-reference/report-metric.md by scripts/sync-references.sh. Do not edit; the live page wins. -->

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

| Field        | Type    | Required | Description                                                                                                                                                             |
| ------------ | ------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `metric`     | string  | Yes      | The metric slug.                                                                                                                                                        |
| `use_case`   | string  | Yes      | The use case slug.                                                                                                                                                      |
| `session_id` | string  | Yes      | The session identifier. Must match the session ID used in the proxy request and the assignment call.                                                                    |
| `outcome`    | boolean | Yes      | `true` if the session achieved the desired outcome, `false` otherwise.                                                                                                  |
| `ts`         | string  | No       | ISO 8601 timestamp for when the outcome occurred. Defaults to the server's receive time. Providing this timestamp can improve the accuracy of the statistical analysis. |

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

## Response

**Success:** HTTP 201 Created with an empty body.
