<!-- Synced from https://docs.three.dev/sending-requests/failure-behavior.md. Do not edit; the live page wins. -->

# Failure behavior

What your app's LLM calls do when three.dev or your AI provider fails or your plan's limits are reached, and how to keep them working when the three.dev proxy cannot be reached.

The three.dev proxy sits between your app and your AI provider, so a failure on either side reaches your app's calls. This page covers [What your app sees](#what-your-app-sees), [Plan limits](#plan-limits), [Telling the proxy's errors from your provider's](#telling-the-proxys-errors-from-your-providers), and [Keeping your app working when the proxy cannot be reached](#keeping-your-app-working-when-the-proxy-cannot-be-reached).

## What your app sees

| What fails                                                                                                                                                                               | Your app's call                                                                                                     | Recorded                       |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| The request has no three.dev API key                                                                                                                                                     | Fails with `401` and `three_dev_api_key_missing`                                                                    | No                             |
| The three.dev API key is unknown or was revoked                                                                                                                                          | Fails with `401` and `three_dev_api_key_invalid`                                                                    | No                             |
| The proxy cannot be reached                                                                                                                                                              | Fails with a connection error, or a `5xx` from the load balancer in front of the proxy                              | No                             |
| The proxy cannot check the key with three.dev's API, and the request sends [your app's own provider key](https://docs.three.dev/sending-requests/ai-providers-integration.md#using-your-apps-own-provider-key) | Goes through to your provider                                                                                       | No                             |
| The proxy cannot check the key with three.dev's API, and the request uses the provider key stored in three.dev                                                                           | Goes through for up to 15 minutes on the proxy's last check of the key, then fails with a `5xx` and `unknown_error` | Best effort                    |
| The proxy cannot reach your AI provider                                                                                                                                                  | Fails with `502` and `unknown_error`                                                                                | No                             |
| Your AI provider answers with an error                                                                                                                                                   | Gets the provider's error, unchanged                                                                                | Yes                            |
| Your organization reaches a plan limit                                                                                                                                                   | Goes through. See [Plan limits](#plan-limits)                                                                       | Up to the processed data limit |

A request with no `X-Three-Api-Key` header, and a provider key where the SDK sends its key, has no three.dev API key. The proxy refuses it with `401` and `three_dev_api_key_missing`, and the error message says to send the three.dev API key in `X-Three-Api-Key`.

A request that sends your app's own provider key also names its provider in `X-Three-AI-Provider`, and for Azure OpenAI and Amazon Bedrock sends its address in `X-Three-AI-Provider-BaseURL`, so the proxy can forward it without three.dev's API. The setup in [Onboard with an AI agent](https://docs.three.dev/getting-started/onboard-with-an-ai-agent.md) wires every client this way.

## Plan limits

Reaching a plan limit never blocks your app's calls. The proxy forwards every request to your AI provider and records it afterward. Two plan limits apply to that traffic, and each one stops only what three.dev does with it:

| Limit reached   | Your app's call | Recorded | Scored |
| --------------- | --------------- | -------- | ------ |
| Processed data  | Goes through    | No       | No     |
| Requests scored | Goes through    | Yes      | No     |

Each limit counts over a calendar month in UTC, and recording and scoring resume on the first day of the next month. three.dev never goes back to record the requests it forwarded while recording was paused. To resume sooner, contact three.dev. For what each plan includes, see [three.dev pricing](https://three.dev/pricing?ref=docs-failure-behavior).

While a limit applies, a banner across the top of the app names what paused and when it resumes, for example **Scoring paused until Dec 1, 2026.** Past the requests scored limit, each new request reads **Plan limit** on the Requests page.

This holds for plan limits only. A missing or revoked three.dev API key, or a proxy your app cannot reach, fails your app's calls. See [What your app sees](#what-your-app-sees).

## Telling the proxy's errors from your provider's

Every response that passes through the proxy carries `x-three-request-id`. An error the proxy returns itself also carries `x-three-error-code`, and repeats it as `error.code` in its body:

```json
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "code": "three_dev_api_key_invalid",
    "message": "three.dev API key rejected: it is unknown or was revoked.",
    "param": null
  },
  "request_id": "0199..."
}
```

Your SDK raises a three.dev `401` as the same exception as your provider's `401`, such as `AuthenticationError`. Read the code before you rotate a key: `three_dev_api_key_missing` and `three_dev_api_key_invalid` are about your three.dev API key, never your provider's. Create a new three.dev API key on the [API Keys](https://app.three.dev/goto/api-keys?ref=docs-failure-behavior) page.

An error without `x-three-error-code` came from your provider, and the proxy passed it through unchanged. A `5xx` without `x-three-request-id` came from in front of the proxy.

## Keeping your app working when the proxy cannot be reached

Build each client the way it was before three.dev whenever the three.dev API key is not set. Unsetting the variable, or setting it empty, and restarting your app then sends every call straight to your provider. Those calls are not recorded. The setup in [Onboard with an AI agent](https://docs.three.dev/getting-started/onboard-with-an-ai-agent.md) wires every client this way, reading `THREE_DEV_API_KEY`:

```python
three_dev_key = os.environ.get("THREE_DEV_API_KEY")
if three_dev_key:
    client = OpenAI(
        base_url="https://gate.three.dev/v1",
        default_headers={
            "X-Three-Api-Key": three_dev_key,
            "X-Three-Use-Case": "support-assistant",
            "X-Three-AI-Provider": "openai",
        },
    )
else:
    client = OpenAI()
```

## Next

* [Using your app's own provider key](https://docs.three.dev/sending-requests/ai-providers-integration.md#using-your-apps-own-provider-key): send the three.dev API key in `X-Three-Api-Key` and keep your provider key in your app.
* [AI Providers Integration](https://docs.three.dev/sending-requests/ai-providers-integration.md): code examples for every supported SDK.
