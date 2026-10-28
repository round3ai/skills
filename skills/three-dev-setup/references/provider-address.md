# The provider's address

Contents: [The provider's address](#the-providers-address) ·
[An address read from a setting](#an-address-read-from-a-setting) ·
[Already on three.dev](#already-on-threedev)

Everything in [wiring.md](wiring.md) holds here too.

## The provider's address

For Azure OpenAI, Bedrock, and OpenAI's EU host, the request says where the
provider is in `X-Three-AI-Provider-BaseURL`. The proxy forwards only to each
provider's own hosts, on the default port, and only under that provider's
`X-Three-AI-Provider` value:

| `X-Three-AI-Provider` | Hosts the header may name |
| --- | --- |
| `openai` | `api.openai.com`, `eu.api.openai.com` |
| `azure_openai` | `<resource>.openai.azure.com`, `<resource>.services.ai.azure.com`, `<resource>.cognitiveservices.azure.com` |
| `amazon_bedrock_runtime` | `bedrock-runtime.<region>.amazonaws.com` |

`<resource>` and `<region>` are one DNS label each. Any other base URL cannot
go through three.dev: a company gateway, a host that speaks a provider's API
(Groq, DeepSeek, Mistral, xAI, a LiteLLM or Portkey the company runs), a
private address, or one of these hosts with a port. Leave that call site
unchanged, with "Not connected: `<file>`, it calls `<host>`, which three.dev
does not forward to." Never send such an address to see whether it works:
the proxy refuses it and three.dev's on-call hears of it.

**The header is the base URL the app calls today, whole and unchanged.** Never
cut it and never add to it. The client then points at the proxy address
[By kind of app](wiring.md#by-kind-of-app) gives for its kind: the Azure or
Bedrock form listed there, or else `gate.three.dev` with the path of its SDK's
own default address.

The proxy joins the two. When the header's path ends with the segments the
app's path starts with, that part is sent once:

| Header | Client points at | App calls on the proxy | Sent to |
| --- | --- | --- | --- |
| `https://eu.api.openai.com/v1` | `https://gate.three.dev/v1` | `/v1/chat/completions` | `/v1/chat/completions` |
| `https://my-resource.openai.azure.com/openai/v1` | `https://gate.three.dev/v1` | `/v1/chat/completions` | `/openai/v1/chat/completions` |
| `https://my-resource.openai.azure.com/openai` | `https://gate.three.dev/openai` | `/openai/deployments/<name>/...` | `/openai/deployments/<name>/...` |
| `https://my-resource.openai.azure.com` as `azure_endpoint` | `azure_endpoint="https://gate.three.dev"` | `/openai/deployments/<name>/...` | the same path |
| `https://bedrock-runtime.<region>.amazonaws.com` | `https://gate.three.dev` | `/model/<id>/...` | the same path |

- The proxy accepts `https`, one of the hosts above with no port, and an
  optional path of plain segments (letters, digits, `.`, `_`, `~`, `-`). One
  trailing slash is fine.
- It refuses, with the code `invalid_ai_provider_base_url`: a query (such as
  `?api-version=`), a fragment, a username, an empty value, a `.` or `..`
  segment, percent-encoding, a `;`, `:`, or space in the path, and more than
  512 bytes. An IP address, `localhost`, or an internal name gets
  `ai_provider_base_url_internal_host` instead, and any other host or a port
  `ai_provider_base_url_unsupported_host`. An address in either shape cannot
  be wired.
- `api-version`, the deployment name, and every other query parameter or
  client option stay as the app has them.
- Never invent the value or build it from a guess at the resource name.
- A request the app sends to `/v1/chat/completions`, `/v1/responses`,
  `/v1/messages`, or Gemini's `/<version>/models/<model>:generateContent` and
  `:streamGenerateContent` on the proxy is recorded with its messages and
  tokens, whatever path the header carries. Other requests, embeddings
  included, are recorded with high-level details only. A model three.dev has no price for is
  recorded without a cost.

One case the join does not settle by itself: **the header's last segment is
not the one the app's path starts with** (an OpenAI-format client on
`https://my-resource.openai.azure.com/openai/deployments/<name>`). Wire it and
let the check request decide. If the provider answers that the path does not
exist, put that one call site back as it was and report it as not connected.
If no check can be sent for it, leave it unwired.

**Where the value comes from.**

| The address in the code is | Do |
| --- | --- |
| Written out | Copy it into the header as it is. |
| A variable or a setting, including one the SDK reads by itself, such as `AZURE_OPENAI_ENDPOINT`, `OPENAI_BASE_URL`, or LangChain's `OPENAI_API_BASE` | Make the header read the same variable; see [below](#an-address-read-from-a-setting). Never look up or ask for its value. |
| Built by the SDK from a region (Bedrock) | With the region in the code, the address is `https://bedrock-runtime.<region>.amazonaws.com`. Without it, ask the user for the region. |
| Built by the SDK from a resource name (`createAzure({ resourceName })`, LangChain.js's `azureOpenAIApiInstanceName`) | With the name in the code, the address is `https://<name>.openai.azure.com/openai` for `createAzure`, and `https://<name>.openai.azure.com` for LangChain.js. Without it, ask the user for the address. |
| Nowhere | Ask the user for it. |

Whichever row it comes from, the value names one of the hosts
[above](#the-providers-address), or the call site stays unchanged and is
reported as not connected.

OpenAI's EU host needs no question: it names no resource of the user's.
For Azure OpenAI and Bedrock, **ask before adding the header.** Show the
value, or the setting it will be read from, and add the header only after
the user says yes. This is one question, answered yes or no; put everything
the user has to know in it:

> Your app calls `<provider>` at `<address or setting>`. To record those calls,
> three.dev needs that address sent with each request, in a header. Add it?

On a no, or no answer, leave that call site unchanged, with "Not connected:
`<file>`, you did not approve sending `<address or setting>` to three.dev."
Never give another reason for it.

**Providers a setting chooses between.** Each provider a setting can pick
is wired by its own row: those three.dev does not forward to stay as they
are, each with its "Not connected" line. When more than one Azure OpenAI or
Bedrock address is among them, ask once for all of them, in place of one
question each, whichever the setting picks today:

> Depending on `<setting>`, your app calls `<provider>` at `<address>` or
> `<provider>` at `<address>`. To record those calls, three.dev needs that
> address sent with each request, in a header. Add them?

A yes wires each with its own address in the header, chosen per run by the
setting; their checks follow the usual rules. A no, or no answer, leaves them
unchanged, with "Not connected: `<provider>`, `<provider>`, you did not approve
sending their addresses to three.dev."

Never skip the question: when the provider this machine's settings choose
is an Azure OpenAI or Bedrock address, ask before its check, even when other
providers are wired. The report just before the question is
`decision_needed`; the final one
waits for the answer. An address read from a setting is asked about by the
setting's name.

## An address read from a setting

When the people who run the app choose the provider's address in a setting
(an environment variable, a config value, an admin option), the wiring reads
that same setting when the app runs. You never need its value, so never ask
for it and never look it up; for an Azure OpenAI or Bedrock address, the
consent question above still comes first, naming the setting. This covers
the SDK's own variable too (`OPENAI_BASE_URL`, `ANTHROPIC_BASE_URL`,
Google's `GOOGLE_GEMINI_BASE_URL`, LangChain's `OPENAI_API_BASE` and
`ANTHROPIC_API_URL`) when the code, the README, or the env template uses it:
a fixed proxy address on the client would silently override it. The
installed class's source names the variables it reads.

The code decides per run, from the setting's value:

| The setting | The client |
| --- | --- |
| Is not set, or is the SDK's default provider's fixed address as [By kind of app](wiring.md#by-kind-of-app) gives it (`https://api.openai.com/v1`, `https://api.anthropic.com`) | The fixed-address wiring for the SDK's default provider, as By kind of app says. No address header. |
| Names another of the hosts [above](#the-providers-address) for the provider the client calls, as the test below matches it | Goes through the proxy, with the setting's value in the header as it is. |
| Is anything else (a gateway, another provider's host, a port, `http`, a query such as `?api-version=`) | Exactly as before the change, straight to that address. The proxy would refuse it, and the app must keep working. |

```python
OPENAI_DEFAULT = re.compile(r"https://api\.openai\.com/v1/?")
OPENAI_EU = re.compile(r"https://eu\.api\.openai\.com/v1/?")

three_dev_key = os.environ.get("THREE_DEV_API_KEY")
address = os.environ.get("OPENAI_BASE_URL", "")
eu = bool(OPENAI_EU.fullmatch(address))
if not three_dev_key or (address and not eu and not OPENAI_DEFAULT.fullmatch(address)):
    client = OpenAI()
else:
    headers = {
        "X-Three-Api-Key": three_dev_key,
        "X-Three-Use-Case": "support-assistant",
        "X-Three-AI-Provider": "openai",
    }
    if eu:
        headers["X-Three-AI-Provider-BaseURL"] = address
    client = OpenAI(base_url="https://gate.three.dev/v1", default_headers=headers)
```

- The first branch builds the client exactly as the code did before. The
  test may be stricter than the proxy, never looser: an address it does not
  match goes there, so a gateway's address never reaches three.dev and the
  app never gets a refusal. These branches are the only logic the wiring may
  add: no parsing, and no cutting of the value.
- Write the pattern in the language's own regular expressions, matching the
  whole value, at most 512 bytes: one pattern for the SDK's default
  provider's fixed address, which gets no header, and one for the hosts in
  the table above for the client's provider, which do. Neither allows a
  port, and both end in the path below. For Azure OpenAI
  (`AZURE_OPENAI_ENDPOINT`), with `X-Three-AI-Provider: azure_openai`, the
  host is `https://[a-z0-9-]{1,63}\.(openai|services\.ai|cognitiveservices)\.azure\.com`,
  followed by `/openai/v1/?` for an OpenAI-format client and by `/?` alone
  for the `AzureOpenAI` classes and `AzureChatOpenAI`, so a deployment path
  (`/openai/deployments/<name>`) builds the client as before. For Bedrock: `https://bedrock-runtime\.[a-z]{2}(-[a-z]+)+-[0-9]+\.amazonaws\.com/?`.
- The path is the one the SDK's default address ends in, because the SDK
  adds only what comes after it (`/chat/completions`, `/messages`): `/v1`
  for an OpenAI-format client on OpenAI and the Vercel AI SDK's Anthropic
  provider. The Anthropic SDK and `ChatAnthropic` add `/v1/messages`
  themselves, and Google's GenAI SDKs add the API version. For an
  OpenAI-format client on Azure the path is `/openai/v1`; the `AzureOpenAI`
  classes take the endpoint with no path.
- `X-Three-AI-Provider` is the provider whose host the setting names: an
  OpenAI client pointed at Azure sends `azure_openai`. Add a branch for
  Azure OpenAI or Bedrock only when the code, the README, or the env template
  shows the setting names that provider; the test then picks the value by
  host, and any other host builds the client as before.
- For an Azure OpenAI or Bedrock setting, ask the one question above, naming
  the setting, not a value.
- Step 6 gets this line: "Calls are recorded when `<setting>` is unset or
  names `<provider>`'s own address; any other address, a gateway included, is
  called directly, as before." Leave out "is unset or" when an unset setting
  does not fall back to a fixed address, and name each provider the test
  accepts.

## Already on three.dev

A client is already on three.dev when its base URL is `gate.three.dev`. Then
look at where the three.dev key is:

- In the SDK's key or its `Authorization` header: the provider key is stored
  in three.dev. Leave the client exactly as it is; do not move it to
  `X-Three-Api-Key`.
- In `X-Three-Api-Key`, with no address header or one naming a host in the
  table [above](#the-providers-address) under its own provider's value: it is
  already wired. This includes a client wired with only the host in the
  address header and the provider's prefix in its own URL: that form keeps
  working, so do not rewire it.
- With an address header naming a host in the table under another
  provider's value (an Azure address sent as `openai`): correct
  `X-Three-AI-Provider` to the host's row.
- With an address header naming a host off the table: the proxy refuses it
  on every request. Point the client back at that address directly, remove
  its `X-Three-*` headers, and report "Not connected: `<file>`, three.dev no
  longer forwards to `<host>`; it now calls `<host>` directly, as before
  setup." It is then no longer in this group.
- With an address header read from a setting through a test looser than the
  one in [An address read from a setting](#an-address-read-from-a-setting)
  (any host, a port): replace that test with it, so any other value calls
  its address directly.
- With per-call `X-Three-*` headers sent with no condition on a call whose
  client can go to another host or be built without the key: put them under
  `through_three_dev`, as [per-call headers](wiring.md#every-wired-client)
  says.

Keep its slug either way, add only what Step 4 finds missing (a session ID,
tags), and request no key for it. When every call site is in this group, skip
Step 3 and send the check request.
