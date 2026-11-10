<!-- Synced from https://docs.three.dev/sending-requests/sending-requests.md. Do not edit; the live page wins. -->

# Send requests through the proxy

Route your LLM requests through the three.dev proxy for observability.

The three.dev proxy forwards your requests to your AI provider and records them for observability. Your app keeps its provider key and sends it where the SDK sends it today; the proxy forwards it unchanged. To start using the proxy, make four changes to your application code:

* **Change your base URL** to `gate.three.dev`. This routes requests through the three.dev proxy, which forwards them to the AI provider.
* **Send your three.dev API key** in the `X-Three-Api-Key` header: `X-Three-Api-Key: <THREE_DEV_API_KEY>`.
* **Add the `X-Three-Use-Case` header** with your use case slug. Slugs follow the pattern `^[a-z0-9]+(?:-[a-z0-9]+)*$` and are at most 64 characters long — for example, `hotel-booking-assistant` or `code-review-assistant`. Create the use case on the [**Use cases**](https://app.three.dev/goto/use-cases?ref=docs-sending-requests) page and send its slug, or send a new slug and three.dev creates the use case on the first request. See [Creating use cases](#creating-use-cases).
* **Add the `X-Three-AI-Provider` header** with your provider, such as `openai` or `anthropic`. See [Choosing the target AI provider](https://docs.three.dev/sending-requests/ai-providers-integration.md#choosing-the-target-ai-provider).

{% hint style="info" %}
Azure OpenAI and Amazon Bedrock also need your provider's address in the `X-Three-AI-Provider-BaseURL` header. See [Sending your provider's address](https://docs.three.dev/sending-requests/ai-providers-integration.md#sending-your-providers-address). To store your provider key in three.dev instead, see [Storing your provider key in three.dev](https://docs.three.dev/sending-requests/pages/eSVyUHtGZZNdZc99D0y0#storing-your-provider-key-in-three.dev). For a step-by-step guide, see [Quickstart: Record your requests](https://docs.three.dev/getting-started/quickstart-record-requests.md).
{% endhint %}

## Speed and availability

The three.dev proxy is built to be fast and highly available. It forwards each request to your AI provider and returns the response to your app. three.dev stores and scores the request only after the response is on its way back to you. Recording and scoring add almost no latency to your calls, and they never decide whether a call succeeds.

For what your app sees when three.dev or your provider has a problem, see [Failure Behavior](https://docs.three.dev/sending-requests/failure-behavior.md).

## Creating use cases

There are two ways to create a use case. Both give you the same use case, with the same defaults.

* **From the UI.** Create the use case on the [**Use cases**](https://app.three.dev/goto/use-cases?ref=docs-sending-requests) page with a descriptive name and a slug, then send that slug in the `X-Three-Use-Case` header.
* **From your first request.** Send a slug that does not match any use case in your organization. three.dev creates the use case, named after its slug, and records the request under it. The use case appears in the sidebar as soon as the first request arrives.

A request under an existing use case is recorded under that use case; three.dev never modifies an existing use case.

The first-request path also suits onboarding with a coding agent: the agent wires in the proxy and sends traffic right away, and three.dev creates the use case on the first request. See [Onboard with an AI agent](https://docs.three.dev/getting-started/onboard-with-an-ai-agent.md).

three.dev forwards a request to the AI provider without recording it when:

* The `X-Three-Use-Case` header is missing.
* The slug is malformed: uppercase letters, underscores, spaces, or more than 64 characters. A well-formed slug with a typo is not malformed, so it creates a use case. Check the sidebar after your first request.
* Your organization already has 100 use cases that three.dev created automatically from a first request. The limit guards against an integration that puts a per-user or per-session value in the header. Use cases created from the **Use cases** page do not count toward it, and deleting a use case that three.dev created automatically frees a slot.
* Your organization has used its plan's processed data for the month. See [Plan limits](https://docs.three.dev/sending-requests/failure-behavior.md#plan-limits).

Deleting a use case while requests still arrive under its slug creates it again. Stop sending the slug before you delete the use case.

## Next

* [AI Providers Integration](https://docs.three.dev/sending-requests/ai-providers-integration.md): code examples for OpenAI, Anthropic, Gemini, Azure OpenAI, OpenRouter, Concentrate, Portkey, Amazon Bedrock, LiteLLM, the Vercel AI SDK, and LangChain.
* [Supported paths](https://docs.three.dev/sending-requests/supported-paths.md): advanced observability, session tagging, and request metadata.
* [Failure behavior](https://docs.three.dev/sending-requests/failure-behavior.md): what your app's calls do when three.dev or your provider fails or a plan limit is reached, and how to keep them working.
