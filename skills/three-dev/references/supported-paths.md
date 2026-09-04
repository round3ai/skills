<!-- Synced from https://docs.three.dev/sending-requests/supported-paths.md by scripts/sync-references.sh. Do not edit; the live page wins. -->

# Supported paths

By default, the proxy forwards and records any type of LLM request. High-level details are stored and visible in the [Requests](https://app.three.dev/requests) page.

The proxy supports **advanced observability** for three interaction types:

* OpenAI's [Chat Completions API](https://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create) (`/v1/chat/completions`). This is supported when used from other providers as well, such as [Gemini](https://ai.google.dev/gemini-api/docs/openai) or [Anthropic](https://platform.claude.com/docs/en/api/openai-sdk). If you are [streaming responses](https://developers.openai.com/api/reference/resources/chat/subresources/completions/streaming-events), set the `include_usage` field of the `stream_options` object to `true` to make tokens and cost information available in three.dev.
* Anthropic's [Messages API](https://platform.claude.com/docs/en/api/python/messages/create) (`/v1/messages`).
* OpenAI's [Responses API](https://developers.openai.com/api/reference/resources/responses/methods/create) (`/v1/responses`), including streamed responses and reasoning summaries.

When one of these interaction methods is used, additional information appears in the [Requests](https://app.three.dev/requests) page — cost, tokens, and the full messages.

<figure><img src="/files/PIoxiZctVAXhHQzTFx6m" alt=""><figcaption></figcaption></figure>

## Specifying the session ID

Group requests into sessions to display aggregated information. In chat-based contexts, each conversation maps to a session containing several requests.

Specify the session ID for a request using the `X-Three-Session-ID` header. Sessions can be explored in the [Sessions](https://app.three.dev/sessions) page.

## Tracking prompt versions in requests

When using three.dev prompt management, include the `X-Three-Prompt` and `X-Three-Prompt-Version` headers to track which prompt version produced each request. three.dev extracts the variable values from the rendered prompt and stores them alongside the request.

| Header                   | Type    | Description                              |
| ------------------------ | ------- | ---------------------------------------- |
| `X-Three-Prompt`         | string  | The prompt slug.                         |
| `X-Three-Prompt-Version` | integer | The prompt version number that was used. |

See [Overview](https://docs.three.dev/prompts/prompts.md) for how to create and version prompts.

## Adding request-level tags

Add one or more request-level tags using the `X-Three-Tag-<TAG_KEY>: <TAG_VALUE>` header syntax. For example, `X-Three-Tag-Environment: production` and `X-Three-Tag-Team: backend` produce the tags `environment:production` and `team:backend`, visible in the UI when examining a request.

Send an `environment` tag on every request. three.dev groups data by use case, not by API key, so the tag is what separates local, staging, and production traffic. For the other tags worth sending, see [Which tags should I send?](https://docs.three.dev/getting-started/planning-your-integration.md#which-tags-should-i-send).

## Adding session-level tags

Tag the whole session rather than a single request using the `X-Three-Session-Tag-<TAG_KEY>: <TAG_VALUE>` header syntax. Send the header alongside `X-Three-Session-ID` on any request in the session.

Use session tags for attributes that describe the conversation rather than one call — the plan a customer is on, the surface the conversation started from, or the experiment cohort you assigned outside three.dev. For example:

```bash
curl https://gate.three.dev/v1/chat/completions \
  -H "Authorization: Bearer <THREE_DEV_API_KEY>" \
  -H "X-Three-Use-Case: <USE_CASE_SLUG>" \
  -H "X-Three-Session-ID: <SESSION_ID>" \
  -H "X-Three-Session-Tag-Plan: enterprise" \
  -H "X-Three-Session-Tag-Channel: mobile" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

Both tag types are filterable. See [Filtering](https://docs.three.dev/exploring-your-data/filtering.md) for the syntax.

## Reasoning and thinking parameters

three.dev records the reasoning configuration you send and normalizes it across providers, so you can compare reasoning behavior between variants that target different vendors.

| Provider                     | What you send            | Recorded as                                      |
| ---------------------------- | ------------------------ | ------------------------------------------------ |
| OpenAI, Azure OpenAI, Gemini | `reasoning_effort`       | Effort                                           |
| Anthropic                    | `thinking.type`          | Mechanism (`enabled`, `disabled`, or `adaptive`) |
| Anthropic                    | `thinking.budget_tokens` | Budget                                           |

Reasoning tokens are counted separately from output tokens and appear in the request details. Filter on `reasoning_effort` and `reasoning_mechanism` to isolate reasoning traffic — see [Filtering](https://docs.three.dev/exploring-your-data/filtering.md).

Accepted `reasoning_effort` values depend on the provider and the model. The proxy forwards what you send and leaves the decision to the provider. When you set a reasoning effort inside three.dev — on an experiment variant or an AI Judge — three.dev validates it against the target model up front and rejects a value that model does not accept.
