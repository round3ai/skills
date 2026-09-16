<!-- Synced from https://docs.three.dev/sending-requests/sending-requests.md. Do not edit; the live page wins. -->

# Overview

Route your LLM requests through the three.dev proxy for observability and experimentation.

The three.dev proxy forwards your requests to your AI provider and records them for observability and experimentation. To start using the proxy, make three changes to your application code:

* **Change your base URL** to `gate.three.dev`. This routes requests through the three.dev proxy, which forwards them to the AI provider.
* **Authenticate with your three.dev API Key** in the `Authorization` header: `Authorization: Bearer <THREE_DEV_API_KEY>`.
* **Add the `X-Three-Use-Case` header** with your use case slug. Slugs follow the pattern `^[a-z0-9]+(?:-[a-z0-9]+)*$` and are at most 64 characters long — for example, `hotel-booking-assistant` or `code-review-assistant`. Create the use case on the [**Use Cases**](https://app.three.dev/use-cases) page and send its slug, or send a new slug and three.dev creates the use case on the first request. See [Creating use cases](#creating-use-cases).

{% hint style="info" %}
Before sending requests, add a valid AI Provider Key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys). See [Quickstart: Record your requests](https://docs.three.dev/getting-started/quickstart-record-requests.md) for a step-by-step guide.
{% endhint %}

## Creating use cases

There are two ways to create a use case. Both give you the same use case, with the same defaults, including the Acceptable Response quality metric.

* **From the UI.** Create the use case on the [**Use Cases**](https://app.three.dev/use-cases) page with a descriptive name and a slug, then send that slug in the `X-Three-Use-Case` header.
* **From your first request.** Send a slug that does not match any use case in your organization. three.dev creates the use case, named after its slug, and records the request under it. The use case appears in the sidebar as soon as the first request arrives.

A request under an existing use case is recorded under that use case; three.dev never modifies an existing use case.

The first-request path also suits onboarding with an AI coding agent: the agent wires in the proxy and sends traffic right away, and three.dev creates the use case on the first request. See [Onboard with an AI agent](https://docs.three.dev/getting-started/onboard-with-an-ai-agent.md).

three.dev forwards a request to the AI provider without recording it when:

* The `X-Three-Use-Case` header is missing.
* The slug is malformed: uppercase letters, underscores, spaces, or more than 64 characters. A well-formed slug with a typo is not malformed, so it creates a use case. Check the sidebar after your first request.
* Your organization already has 20 use cases that three.dev created automatically, from a first request or from a [metric report](https://docs.three.dev/api-reference/report-metric.md#creating-the-metric-on-first-report). The limit guards against an integration that puts a per-user or per-session value in the header. Use cases created from the **Use Cases** page do not count toward it, and deleting a use case that three.dev created automatically frees a slot.

Deleting a use case while requests or [metric reports](https://docs.three.dev/api-reference/report-metric.md#creating-the-metric-on-first-report) with `optimize_for` still arrive under its slug creates it again. Stop sending the slug before you delete the use case.

## Next

* [AI Providers Integration](https://docs.three.dev/sending-requests/ai-providers-integration.md) — code examples for OpenAI, Anthropic, Gemini, Azure OpenAI, and LiteLLM.
* [Supported paths](https://docs.three.dev/sending-requests/supported-paths.md) — advanced observability, session tagging, and request metadata.
