# Proxy errors

When the proxy itself refuses a request, it answers with this body and repeats
the code in the `x-three-error-code` response header:

```json
{
  "type": "error",
  "error": {
    "type": "authentication_error",
    "code": "missing_api_key",
    "message": "Missing three.dev API key.",
    "param": null
  },
  "request_id": "0199..."
}
```

Act on `error.code`. The message is one short sentence and may change. An
error with no `x-three-error-code` header and another body shape came from the
provider: three.dev passed it through unchanged.

## Codes on a refused request

| `error.code` | Status | What happened | Fix |
| --- | --- | --- | --- |
| `missing_api_key` | 401 | The request carried no three.dev key and no credential the proxy could read as one. | `X-Three-Api-Key` is missing from that client's default headers, or `THREE_DEV_API_KEY` is empty in the process. Check the header is set and that the process loads the env file. Never open the file to look. |
| `invalid_api_key` | 401 | The proxy did not recognise the three.dev key it read. | First check the client sends `X-Three-Api-Key` and that `THREE_DEV_API_KEY` reaches the process: when that header is missing or empty, the proxy reads the provider's key in `Authorization` as the three.dev key and answers this code. Only when the header is there is the key itself the problem: it was revoked, often because a later setup replaced it. Then run Step 3 again for another one. |
| `three_key_in_provider_header` | 400 | The three.dev key is where the provider's key belongs (the SDK's key, `Authorization`, `x-api-key`, `api-key`, or `x-goog-api-key`). | Put the provider's key back as the SDK's key and send the three.dev key in `X-Three-Api-Key` only. |
| `ai_provider_key_missing` | 401 | The proxy could not tell where to send the request. | On a client wired with `X-Three-Api-Key`, the cause is a missing `X-Three-AI-Provider` header, or, for Azure OpenAI and Bedrock, a missing `X-Three-AI-Provider-BaseURL`. Add the missing header. Only an app that sends the three.dev key as its provider key needs a provider key stored in three.dev: https://app.three.dev/goto/ai-provider-keys |
| `invalid_ai_provider` | 400 | The `X-Three-AI-Provider` value is not one the proxy knows. | Use a value from the AI Providers Integration page, spelled exactly. |
| `invalid_ai_provider_base_url` | 400 | `X-Three-AI-Provider-BaseURL` is not an `https` base URL the proxy accepts. | Send the base URL the app called before, unchanged, as [provider-address.md](provider-address.md#the-providers-address) says. `http`, a query, a fragment, a username, an empty value, a `.` or `..` segment, percent-encoding, a `;`, `:`, or space in the path, or more than 512 bytes is refused. When the app's address has one of these, leave that call site unchanged and report it as not connected. An IP address or an internal name gets `ai_provider_base_url_internal_host`, any other host `ai_provider_base_url_unsupported_host`. |
| `ai_provider_base_url_not_allowed` | 400 | The address header came without `X-Three-Api-Key`. | Send the three.dev key in `X-Three-Api-Key` and the provider's own key as the SDK's key. A client that sends the three.dev key as its provider key cannot use the address header: remove it there. |
| `ai_provider_base_url_unsupported_provider` | 400 | The address header was sent for a provider that three.dev hosts itself. | Remove `X-Three-AI-Provider-BaseURL` from that client. |
| `ai_provider_base_url_unsupported_host` | 400 | `X-Three-AI-Provider-BaseURL` names a host that is not one of that provider's own, or has a port. The message lists the hosts it accepts. three.dev's on-call hears of every one. | When `X-Three-AI-Provider` names another provider than the host's (an Azure address sent as `openai`), correct it once. Otherwise no retry fixes it: put the call site back as it was and report it as not connected, as [provider-address.md](provider-address.md#the-providers-address) says. |
| `ai_provider_base_url_internal_host` | 400 | `X-Three-AI-Provider-BaseURL` names `localhost`, an IP address, or an internal name. The proxy checks this before anything else. | Put the call site back as it was and report it as not connected. Never send it again with another value. |
| `insufficient_scope` | 403 | The three.dev key is not allowed to send requests. | Tell the user: the key needs Traffic access. A key from Step 3 has it; one created by hand may not. |
| `unknown_error` | other 4xx | The proxy could not accept the request. | Report the status and the `request_id`. Do not guess a fix. |
| `unknown_error` | 5xx | three.dev or the provider could not be reached. | Not the wiring. Try once more, then report the status and the `request_id`. |

## Codes the request never shows

These are not in a response. The request is forwarded, the app gets its
answer, and nothing is recorded. three.dev shows them on its setup page, so
they reach you only when the user reads one out.

| Code | What happened | Fix |
| --- | --- | --- |
| `missing_use_case` | A request arrived with no `X-Three-Use-Case`. | A call site sends no use-case header, or a per-call header replaced the client defaults. Find it and fix the merge. |
| `invalid_use_case` | The slug is malformed. | Make it match `^[a-z0-9]+(?:-[a-z0-9]+)*$`, at most 64 characters. |
| `use_case_limit_reached` | The organization already has 20 use cases created from a first request. | Tell the user to delete unused ones, or to create this one on the Use Cases page. Check that no slug is built from a runtime value. |
| `upstream_<status>` | The provider answered with that status. | The provider's own error; the app saw the same response. |

## On the approval page

`setup_agent_not_enabled` is shown to the user in the browser as "Not
available for this organization", never to you. What to tell them is in
[connect.md](connect.md), under Wait.
