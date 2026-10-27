<!-- Synced from https://docs.three.dev/sending-requests/ai-providers-integration.md. Do not edit; the live page wins. -->

# AI Providers Integration

Configure the three.dev proxy for OpenAI, Anthropic, Gemini, Azure OpenAI, OpenRouter, Concentrate, Amazon Bedrock, LiteLLM, the Vercel AI SDK, and LangChain, with code examples per provider and langu

The three.dev proxy supports multiple AI providers. Point your SDK at `gate.three.dev`, authenticate with your three.dev API key, and set the `X-Three-AI-Provider` header to route to the right backend. See [Overview](https://docs.three.dev/sending-requests/sending-requests.md) for the three changes every integration requires.

## Provider examples

{% tabs %}
{% tab title="cURL" %}

```bash
curl https://gate.three.dev/v1/chat/completions \
  -H "Authorization: Bearer <THREE_DEV_API_KEY>" \
  -H "X-Three-Use-Case: <USE_CASE_SLUG>" \
  -H "X-Three-AI-Provider: openai" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

{% endtab %}

{% tab title="OpenAI" %}

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from openai import OpenAI

client = OpenAI(
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "openai"},
)

response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import OpenAI from "openai";

const client = new OpenAI({
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/v1",
    defaultHeaders: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "openai",
    },
});

const response = await client.chat.completions.create({
    model: "gpt-5",
    messages: [{ role: "user", content: "Hello!" }],
});
```

{% endcode %}

</details>

<details>

<summary>Go</summary>

{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/openai/openai-go/v3"
    "github.com/openai/openai-go/v3/option"
)

func main() {
    client := openai.NewClient(
        option.WithAPIKey("<THREE_DEV_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev/v1"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "openai"),
    )

    completion, err := client.Chat.Completions.New(
        context.TODO(),
        openai.ChatCompletionNewParams{
            Model: "gpt-5",
            Messages: []openai.ChatCompletionMessageParamUnion{
                openai.UserMessage("Hello!"),
            },
        },
    )
    if err != nil {
        panic(err)
    }

    fmt.Println(completion.Choices[0].Message.Content)
}
```

{% endcode %}

</details>
{% endtab %}

{% tab title="Anthropic" %}
The Anthropic SDKs require an API key, but the proxy authenticates through the `Authorization` header instead. Set the SDK's key to the placeholder `default` as shown below. Leave it out and the SDK falls back to your `ANTHROPIC_API_KEY` environment variable, sending your real Anthropic key to the proxy — or failing to construct the client when that variable is not set.

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from anthropic import Anthropic

client = Anthropic(
    api_key="default",
    base_url="https://gate.three.dev",
    default_headers={"Authorization": "Bearer <THREE_DEV_API_KEY>", "x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "anthropic"},
)

message = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
    apiKey: "default",
    baseURL: "https://gate.three.dev",
    defaultHeaders: {
        "Authorization": "Bearer <THREE_DEV_API_KEY>",
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "anthropic",
    },
});

const message = await client.messages.create({
    model: "claude-sonnet-4-5",
    max_tokens: 1024,
    messages: [{ role: "user", content: "Hello!" }],
});
```

{% endcode %}

</details>

<details>

<summary>Go</summary>

{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/anthropics/anthropic-sdk-go"
    "github.com/anthropics/anthropic-sdk-go/option"
)

func main() {
    client := anthropic.NewClient(
        option.WithAPIKey("default"),
        option.WithBaseURL("https://gate.three.dev"),
        option.WithHeader("Authorization", "Bearer <THREE_DEV_API_KEY>"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "anthropic"),
    )

    message, err := client.Messages.New(
        context.TODO(),
        anthropic.MessageNewParams{
            Model:     "claude-sonnet-4-5",
            MaxTokens: 1024,
            Messages: []anthropic.MessageParam{
                anthropic.NewUserMessage(
                    anthropic.NewTextBlock("Hello!"),
                ),
            },
        },
    )
    if err != nil {
        panic(err)
    }

    fmt.Printf("%+v\n", message.Content)
}
```

{% endcode %}

</details>
{% endtab %}

{% tab title="Gemini" %}
Use Google's GenAI SDKs, or the OpenAI SDK with Gemini's OpenAI-compatible API. three.dev records both with [advanced observability](https://docs.three.dev/sending-requests/supported-paths.md).

**Google GenAI SDK**

Set the base URL to `https://gate.three.dev`, without an API version. The SDK adds `/v1beta` itself, so a base URL of `https://gate.three.dev/v1beta` sends requests to `/v1beta/v1beta/models/...`. The SDK sends its API key in the `x-goog-api-key` header, and the proxy accepts the three.dev API key there. Set the session and request-level tags per call; headers set on a call merge with the client's headers.

<details>

<summary>Python</summary>

With `google-genai`:

{% code overflow="wrap" %}

```python
from google import genai
from google.genai import types

client = genai.Client(
    api_key="<THREE_DEV_API_KEY>",
    http_options=types.HttpOptions(
        base_url="https://gate.three.dev",
        headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "gemini"},
    ),
)

config = types.GenerateContentConfig(
    http_options=types.HttpOptions(
        headers={"x-three-session-id": "<SESSION_ID>", "x-three-tag-environment": "production"},
    ),
)

response = client.models.generate_content(
    model="gemini-3-flash-preview",
    contents="Hello!",
    config=config,
)

for chunk in client.models.generate_content_stream(
    model="gemini-3-flash-preview",
    contents="Hello!",
    config=config,
):
    print(chunk.text or "", end="")
```

{% endcode %}

Async calls through `client.aio` take the same `config`.

</details>

<details>

<summary>TypeScript</summary>

With `@google/genai`:

{% code overflow="wrap" %}

```typescript
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
    apiKey: "<THREE_DEV_API_KEY>",
    httpOptions: {
        baseUrl: "https://gate.three.dev",
        headers: {
            "x-three-use-case": "<USE_CASE_SLUG>",
            "x-three-ai-provider": "gemini",
        },
    },
});

const config = {
    httpOptions: {
        headers: {
            "x-three-session-id": "<SESSION_ID>",
            "x-three-tag-environment": "production",
        },
    },
};

const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: "Hello!",
    config,
});

const stream = await ai.models.generateContentStream({
    model: "gemini-3-flash-preview",
    contents: "Hello!",
    config,
});
for await (const chunk of stream) {
    process.stdout.write(chunk.text ?? "");
}
```

{% endcode %}

</details>

<details>

<summary>Go</summary>

With `google.golang.org/genai`. Set `Backend` to `genai.BackendGeminiAPI` so that the `GOOGLE_GENAI_USE_VERTEXAI` environment variable cannot switch the client to Vertex AI:

{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"
    "net/http"

    "google.golang.org/genai"
)

func main() {
    ctx := context.Background()

    headers := http.Header{}
    headers.Set("x-three-use-case", "<USE_CASE_SLUG>")
    headers.Set("x-three-ai-provider", "gemini")

    client, err := genai.NewClient(ctx, &genai.ClientConfig{
        APIKey:  "<THREE_DEV_API_KEY>",
        Backend: genai.BackendGeminiAPI,
        HTTPOptions: genai.HTTPOptions{
            BaseURL: "https://gate.three.dev",
            Headers: headers,
        },
    })
    if err != nil {
        panic(err)
    }

    callHeaders := http.Header{}
    callHeaders.Set("x-three-session-id", "<SESSION_ID>")
    callHeaders.Set("x-three-tag-environment", "production")
    config := &genai.GenerateContentConfig{
        HTTPOptions: &genai.HTTPOptions{Headers: callHeaders},
    }

    response, err := client.Models.GenerateContent(ctx, "gemini-3-flash-preview", genai.Text("Hello!"), config)
    if err != nil {
        panic(err)
    }
    fmt.Println(response.Text())

    for chunk, err := range client.Models.GenerateContentStream(ctx, "gemini-3-flash-preview", genai.Text("Hello!"), config) {
        if err != nil {
            panic(err)
        }
        fmt.Print(chunk.Text())
    }
}
```

{% endcode %}

</details>

{% hint style="warning" %}
Vertex AI mode (`vertexai=True` in Python, `vertexai: true` in TypeScript, `genai.BackendVertexAI` in Go, or the `GOOGLE_GENAI_USE_VERTEXAI` environment variable) authenticates with Google Cloud credentials and cannot go through the proxy. Use the Gemini API mode with an API key.
{% endhint %}

The deprecated `google-generativeai` Python SDK uses gRPC by default, which cannot go through the proxy. Migrate to `google-genai`. Until then, call `genai.configure` with `transport="rest"`, `client_options={"api_endpoint": "https://gate.three.dev"}`, and the three.dev headers as `default_metadata` tuples. Its async calls, such as `generate_content_async`, fail with the REST transport.

**OpenAI SDK**

These examples use Gemini's OpenAI-compatible Chat Completions API.

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from openai import OpenAI

client = OpenAI(
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1beta/openai",
    default_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "gemini"},
)

response = client.chat.completions.create(
    model="gemini-3-flash-preview",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import OpenAI from "openai";

const client = new OpenAI({
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/v1beta/openai",
    defaultHeaders: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "gemini",
    },
});

const response = await client.chat.completions.create({
    model: "gemini-3-flash-preview",
    messages: [{ role: "user", content: "Hello!" }],
});
```

{% endcode %}

</details>

<details>

<summary>Go</summary>

{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/openai/openai-go/v3"
    "github.com/openai/openai-go/v3/option"
)

func main() {
    client := openai.NewClient(
        option.WithAPIKey("<THREE_DEV_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev/v1beta/openai"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "gemini"),
    )

    completion, err := client.Chat.Completions.New(
        context.TODO(),
        openai.ChatCompletionNewParams{
            Model: "gemini-3-flash-preview",
            Messages: []openai.ChatCompletionMessageParamUnion{
                openai.UserMessage("Hello!"),
            },
        },
    )
    if err != nil {
        panic(err)
    }

    fmt.Println(completion.Choices[0].Message.Content)
}
```

{% endcode %}

</details>
{% endtab %}
{% endtabs %}

## Choosing the target AI provider

Specify the AI provider for each request with the `X-Three-AI-Provider` header. Accepted values are `openai`, `anthropic`, `gemini`, `azure_openai`, `amazon_bedrock_runtime`, `amazon_bedrock_mantle`, `openrouter`, and `concentrate`.

Add your provider's API key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys). One key can be marked as the Default Provider — used when no `X-Three-AI-Provider` header is specified. If a provider is specified but no key exists for it in three.dev, the request fails with an authentication error, unless the request carries [your app's own provider key](#using-your-apps-own-provider-key).

## Using your app's own provider key

To keep the provider key in your app instead of storing it in three.dev, send the three.dev API key in the `X-Three-Api-Key` header and leave the provider key where the SDK sends it. The proxy forwards the provider key unchanged and does not need a key in **Settings > AI Provider Keys**. For example, with Google's GenAI SDK for Python:

{% code overflow="wrap" %}

```python
from google import genai
from google.genai import types

client = genai.Client(
    api_key="<GEMINI_API_KEY>",
    http_options=types.HttpOptions(
        base_url="https://gate.three.dev",
        headers={
            "x-three-api-key": "<THREE_DEV_API_KEY>",
            "x-three-use-case": "<USE_CASE_SLUG>",
            "x-three-ai-provider": "gemini",
        },
    ),
)
```

{% endcode %}

The proxy rejects the request with `400 three_key_in_provider_header` when `Authorization`, `x-api-key`, `api-key`, or `x-goog-api-key` holds a three.dev API key alongside `X-Three-Api-Key`.

### Sending your provider's address

When your app keeps its own provider key and calls Azure OpenAI, Amazon Bedrock Runtime, or OpenAI's EU host, send the base URL it calls today, path included, in the `X-Three-AI-Provider-BaseURL` header. Send it with `X-Three-Api-Key` and `X-Three-AI-Provider`.

The header accepts only each provider's own hosts, over `https`:

| `X-Three-AI-Provider`    | Hosts                                                                                                                      |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| `openai`                 | `api.openai.com`, `eu.api.openai.com`                                                                                      |
| `azure_openai`           | `<RESOURCE_NAME>.openai.azure.com`, `<RESOURCE_NAME>.services.ai.azure.com`, `<RESOURCE_NAME>.cognitiveservices.azure.com` |
| `amazon_bedrock_runtime` | `bedrock-runtime.<AWS_REGION>.amazonaws.com`                                                                               |

Other providers need no header. The proxy refuses any other host, such as a company gateway or a service that speaks a provider's API; keep the app calling those directly. Keep query parameters such as `api-version` in the SDK's options, not in the header.

For example, with the OpenAI SDK on Azure OpenAI, using your Azure deployment name as the `model` parameter:

{% tabs %}
{% tab title="Python" %}
{% code overflow="wrap" %}

```python
from openai import OpenAI

client = OpenAI(
    api_key="<AZURE_OPENAI_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={
        "X-Three-Api-Key": "<THREE_DEV_API_KEY>",
        "X-Three-Use-Case": "<USE_CASE_SLUG>",
        "X-Three-AI-Provider": "azure_openai",
        "X-Three-AI-Provider-BaseURL": "https://<RESOURCE_NAME>.openai.azure.com/openai/v1",
    },
)

response = client.chat.completions.create(
    model="<AZURE_DEPLOYMENT_NAME>",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

{% endcode %}
{% endtab %}

{% tab title="TypeScript" %}
{% code overflow="wrap" %}

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: "<AZURE_OPENAI_API_KEY>",
  baseURL: "https://gate.three.dev/v1",
  defaultHeaders: {
    "X-Three-Api-Key": "<THREE_DEV_API_KEY>",
    "X-Three-Use-Case": "<USE_CASE_SLUG>",
    "X-Three-AI-Provider": "azure_openai",
    "X-Three-AI-Provider-BaseURL": "https://<RESOURCE_NAME>.openai.azure.com/openai/v1",
  },
});

const response = await client.chat.completions.create({
  model: "<AZURE_DEPLOYMENT_NAME>",
  messages: [{ role: "user", content: "Hello!" }],
});
```

{% endcode %}
{% endtab %}
{% endtabs %}

The proxy refuses the request with `400` and one of these codes:

| Code                                    | Cause                                                                         | Fix                                                                                            |
| --------------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `ai_provider_base_url_internal_host`    | `localhost`, an IP address, or an internal name.                              | Send the provider's public host.                                                               |
| `ai_provider_base_url_not_allowed`      | The header came without `X-Three-Api-Key`.                                    | Send your three.dev API key in `X-Three-Api-Key` and your provider key where the SDK sends it. |
| `invalid_ai_provider_base_url`          | The value is not a plain `https` base URL, for example it has a query string. | Send only the base URL.                                                                        |
| `ai_provider_base_url_unsupported_host` | The host is not in the table for that provider, or has a port.                | Correct `X-Three-AI-Provider`, or keep the app calling that host directly.                     |

## Azure OpenAI

Azure OpenAI is supported as a separate provider. When configuring an Azure OpenAI provider key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys), specify both your API key and your Azure resource endpoint URL (for example, `https://my-resource.openai.azure.com`).

To keep the Azure key in your app instead, send your resource's address in `X-Three-AI-Provider-BaseURL`. See [Sending your provider's address](#sending-your-providers-address).

Send requests through the proxy to Azure OpenAI using the OpenAI SDK pointed at `gate.three.dev` with `X-Three-AI-Provider: azure_openai`. Use your Azure deployment name as the `model` parameter:

{% tabs %}
{% tab title="Python" %}

```python
from openai import OpenAI

client = OpenAI(
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={
        "X-Three-Use-Case": "<USE_CASE_SLUG>",
        "X-Three-AI-Provider": "azure_openai",
    },
)

response = client.chat.completions.create(
    model="<AZURE_DEPLOYMENT_NAME>",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

{% endtab %}

{% tab title="TypeScript" %}

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: "<THREE_DEV_API_KEY>",
  baseURL: "https://gate.three.dev/v1",
  defaultHeaders: {
    "X-Three-Use-Case": "<USE_CASE_SLUG>",
    "X-Three-AI-Provider": "azure_openai",
  },
});

const response = await client.chat.completions.create({
  model: "<AZURE_DEPLOYMENT_NAME>",
  messages: [{ role: "user", content: "Hello!" }],
});
```

{% endtab %}

{% tab title="Go" %}

```go
package main

import (
    "context"
    "fmt"
    "github.com/openai/openai-go"
    "github.com/openai/openai-go/option"
)

func main() {
    client := openai.NewClient(
        option.WithAPIKey("<THREE_DEV_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev/v1"),
        option.WithHeader("X-Three-Use-Case", "<USE_CASE_SLUG>"),
        option.WithHeader("X-Three-AI-Provider", "azure_openai"),
    )

    response, _ := client.Chat.Completions.New(context.TODO(), openai.ChatCompletionNewParams{
        Model:    "<AZURE_DEPLOYMENT_NAME>",
        Messages: []openai.ChatCompletionMessageParamUnion{
            openai.UserMessage("Hello!"),
        },
    })
    fmt.Println(response.Choices[0].Message.Content)
}
```

{% endtab %}
{% endtabs %}

## OpenRouter

[OpenRouter](https://openrouter.ai) exposes an OpenAI-compatible API, so the integration matches the OpenAI example — point the OpenAI SDK at `gate.three.dev/v1` and set `X-Three-AI-Provider: openrouter`. Add your OpenRouter key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys).

Use OpenRouter's `<VENDOR>/<MODEL>` naming for the `model` parameter. This is a convenient way to reach open-weight models — the examples below call `z-ai/glm-5.2`.

{% tabs %}
{% tab title="Python" %}

```python
from openai import OpenAI

client = OpenAI(
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={
        "X-Three-Use-Case": "<USE_CASE_SLUG>",
        "X-Three-AI-Provider": "openrouter",
    },
)

response = client.chat.completions.create(
    model="z-ai/glm-5.2",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

{% endtab %}

{% tab title="TypeScript" %}

```typescript
import OpenAI from "openai";

const client = new OpenAI({
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/v1",
    defaultHeaders: {
        "X-Three-Use-Case": "<USE_CASE_SLUG>",
        "X-Three-AI-Provider": "openrouter",
    },
});

const response = await client.chat.completions.create({
    model: "z-ai/glm-5.2",
    messages: [{ role: "user", content: "Hello!" }],
});
```

{% endtab %}
{% endtabs %}

## Concentrate

[Concentrate](https://concentrate.ai) is an LLM gateway: one key and one API for about 200 models from many vendors. three.dev records Concentrate's Responses API, Chat Completions, Anthropic's Messages API, and System One with full details.

An app that calls Concentrate points its SDK at `https://api.concentrate.ai/v1`, or at `https://api.concentrate.ai` with the Anthropic SDK, and uses a key that starts with `sk-cn-`. To send its requests through three.dev, make these changes in any OpenAI or Anthropic SDK:

* Replace `https://api.concentrate.ai` with `https://gate.three.dev` and keep the rest of the base URL: `https://gate.three.dev/v1` for OpenAI SDKs, `https://gate.three.dev` for the Anthropic SDK.
* Set the `X-Three-AI-Provider: concentrate` header. The proxy knows Concentrate's address, so no provider base URL is needed.
* Keep the Concentrate key as the SDK's API key and send your three.dev API key in the `X-Three-Api-Key` header. The proxy forwards the Concentrate key unchanged, so nothing needs to be stored in **Settings > AI Provider Keys** to record requests. See [Using your app's own provider key](#using-your-apps-own-provider-key). Offline experiments replay requests from three.dev, so to use Concentrate models as variants, also add the Concentrate key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys).
* Send the `X-Three-Use-Case` header with your use case slug, as every integration does. See [Sending Requests](https://docs.three.dev/sending-requests/sending-requests.md).

Use a Concentrate model slug for the `model` parameter, for example `glm-5.3-flash`, `gpt-6-luna`, or `claude-opus-5-5`. The `<PROVIDER>/<MODEL>` form pins the provider that serves the request. Concentrate reports the serving provider as a prefix on the response's model, such as `zai/glm-5.3-flash`; three.dev shows the model you requested, `glm-5.3-flash`. See [Concentrate's model list](https://concentrate.ai/docs/api-reference/endpoint/supported-models) for the available slugs.

### Responses API

{% tabs %}
{% tab title="Go" %}
{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/openai/openai-go/v3"
    "github.com/openai/openai-go/v3/option"
    "github.com/openai/openai-go/v3/responses"
)

func main() {
    client := openai.NewClient(
        option.WithAPIKey("<CONCENTRATE_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev/v1"),
        option.WithHeader("x-three-api-key", "<THREE_DEV_API_KEY>"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "concentrate"),
    )

    response, err := client.Responses.New(
        context.TODO(),
        responses.ResponseNewParams{
            Model: "glm-5.3-flash",
            Input: responses.ResponseNewParamsInputUnion{OfString: openai.String("Hello!")},
        },
        option.WithHeader("x-three-session-id", "<SESSION_ID>"),
        option.WithHeader("x-three-tag-environment", "production"),
    )
    if err != nil {
        panic(err)
    }

    fmt.Println(response.OutputText())
}
```

{% endcode %}
{% endtab %}
{% endtabs %}

### Chat Completions API

Chat Completions (`/v1/chat/completions`) works with the same client: call `client.Chat.Completions.New` instead of `client.Responses.New`. When streaming, set `stream_options.include_usage` to `true` (`StreamOptions.IncludeUsage` in Go) so the final chunk carries tokens and cost.

### Messages API

For Anthropic's Messages API (`/v1/messages`), use the Anthropic SDK. Point it at `https://gate.three.dev`, without `/v1`: the SDK adds `/v1/messages` itself. The SDK sends the Concentrate key in the `x-api-key` header, which the proxy forwards unchanged. `option.WithoutEnvironmentDefaults()` stops the SDK from also sending a credential it finds in your environment, such as `ANTHROPIC_AUTH_TOKEN`, which the proxy would forward to Concentrate as well:

{% tabs %}
{% tab title="Go" %}
{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/anthropics/anthropic-sdk-go"
    "github.com/anthropics/anthropic-sdk-go/option"
)

func main() {
    client := anthropic.NewClient(
        option.WithoutEnvironmentDefaults(),
        option.WithAPIKey("<CONCENTRATE_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev"),
        option.WithHeader("x-three-api-key", "<THREE_DEV_API_KEY>"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "concentrate"),
    )

    message, err := client.Messages.New(
        context.TODO(),
        anthropic.MessageNewParams{
            Model:     "claude-opus-5-5",
            MaxTokens: 1024,
            Messages: []anthropic.MessageParam{
                anthropic.NewUserMessage(
                    anthropic.NewTextBlock("Hello!"),
                ),
            },
        },
        option.WithHeader("x-three-session-id", "<SESSION_ID>"),
        option.WithHeader("x-three-tag-environment", "production"),
    )
    if err != nil {
        panic(err)
    }

    fmt.Printf("%+v\n", message.Content)
}
```

{% endcode %}
{% endtab %}
{% endtabs %}

### System One (Jev)

Concentrate serves TypeSafe's Jev models, `jev-1.14.0` and `jev-1.13.0`, on its System One API (`/v1/systemone`). Jev does not generate text: it takes your application's `state` and a map of typed `questions` (`noul`, `choice`, `score`, or `box`) and returns calibrated probabilities. `state` accepts a string, a JSON object, or a JSON array. The OpenAI SDK has no method for System One, so call it with the SDK's generic `client.Post`:

{% tabs %}
{% tab title="Go" %}
{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/openai/openai-go/v3"
    "github.com/openai/openai-go/v3/option"
)

type question struct {
    Type         string `json:"type"`
    Instructions string `json:"instructions"`
    Criteria     any    `json:"criteria,omitempty"`
}

type systemOneRequest struct {
    Model     string              `json:"model"`
    State     any                 `json:"state"`
    Questions map[string]question `json:"questions"`
}

type answer struct {
    Choice     string  `json:"choice"`
    Confidence float64 `json:"confidence"`
    Noul       float64 `json:"noul"`
}

type systemOneResponse struct {
    Answers map[string]answer `json:"answers"`
}

func main() {
    client := openai.NewClient(
        option.WithAPIKey("<CONCENTRATE_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev/v1"),
        option.WithHeader("x-three-api-key", "<THREE_DEV_API_KEY>"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "concentrate"),
    )

    request := systemOneRequest{
        Model: "jev-1.14.0",
        State: "The export button does nothing when I click it, and I need the file for an audit on Friday.",
        Questions: map[string]question{
            "category": {
                Type:         "choice",
                Instructions: "What kind of request this ticket is",
                Criteria: map[string]string{
                    "bug":     "Something in the product is broken",
                    "how_to":  "The customer asks how to do something",
                    "billing": "Charges, invoices, or plan changes",
                },
            },
            "churn_risk": {
                Type:         "noul",
                Instructions: "The customer says or implies they may cancel",
            },
        },
    }

    var response systemOneResponse
    err := client.Post(
        context.TODO(),
        "systemone",
        request,
        &response,
        option.WithHeader("x-three-session-id", "<SESSION_ID>"),
        option.WithHeader("x-three-tag-environment", "production"),
    )
    if err != nil {
        panic(err)
    }

    category := response.Answers["category"]
    fmt.Printf("category: %s (confidence %.2f)\n", category.Choice, category.Confidence)
    fmt.Printf("churn risk: %.2f\n", response.Answers["churn_risk"].Noul)
}
```

{% endcode %}
{% endtab %}
{% endtabs %}

See Concentrate's [System One reference](https://concentrate.ai/docs/api-reference/endpoint/systemone) for every question type and answer shape.

### Cost

For the Responses API, Chat Completions, and the Messages API, three.dev records the cost Concentrate reports in its response, on the final event when streaming, split into input, cache, and output. No price table is involved, so the cost matches Concentrate's bill. A call Concentrate serves on your own vendor key (Concentrate's BYOK) is recorded with no cost, not as free. Concentrate reports no cost for System One calls, so three.dev prices Jev at TypeSafe's list price, with output tokens free.

## Amazon Bedrock

Amazon Bedrock is supported through two provider types: **Runtime** (available now) and **Mantle** (coming soon). When configuring a Bedrock provider key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys), select "Amazon Bedrock", choose Runtime, select your AWS region, and enter your Bedrock API key. The endpoint URL is derived automatically — no need to look it up.

To keep the Bedrock API key in your app instead, send `https://bedrock-runtime.<AWS_REGION>.amazonaws.com` in `X-Three-AI-Provider-BaseURL`. See [Sending your provider's address](#sending-your-providers-address).

### Bedrock Runtime

#### OpenAI SDK

Use the OpenAI SDK pointed at `gate.three.dev/openai/v1` with `x-three-ai-provider: amazon_bedrock_runtime`.

{% tabs %}
{% tab title="Python" %}

```python
from openai import OpenAI

client = OpenAI(
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/openai/v1",
    default_headers={
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "amazon_bedrock_runtime",
    },
)

response = client.chat.completions.create(
    model="global.openai.gpt-5.4",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

{% endtab %}

{% tab title="TypeScript" %}

```typescript
import OpenAI from "openai";

const client = new OpenAI({
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/openai/v1",
    defaultHeaders: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "amazon_bedrock_runtime",
    },
});

const response = await client.chat.completions.create({
    model: "global.openai.gpt-5.4",
    messages: [{ role: "user", content: "Hello!" }],
});
```

{% endtab %}

{% tab title="Go" %}

```go
package main

import (
    "context"
    "fmt"

    "github.com/openai/openai-go/v3"
    "github.com/openai/openai-go/v3/option"
)

func main() {
    client := openai.NewClient(
        option.WithAPIKey("<THREE_DEV_API_KEY>"),
        option.WithBaseURL("https://gate.three.dev/openai/v1"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "amazon_bedrock_runtime"),
    )

    completion, err := client.Chat.Completions.New(
        context.TODO(),
        openai.ChatCompletionNewParams{
            Model: "global.openai.gpt-5.4",
            Messages: []openai.ChatCompletionMessageParamUnion{
                openai.UserMessage("Hello!"),
            },
        },
    )
    if err != nil {
        panic(err)
    }

    fmt.Println(completion.Choices[0].Message.Content)
}
```

{% endtab %}
{% endtabs %}

#### Anthropic SDK

The Anthropic Go SDK uses `bedrock.WithConfig()` to talk to Bedrock Runtime. It rewrites `Messages.New(...)` calls to the InvokeModel format automatically — no manual path construction needed. The Python and TypeScript Anthropic SDKs are not supported here because they use SigV4-only authentication, which cannot be proxied through gate3.

{% tabs %}
{% tab title="Go" %}
{% code overflow="wrap" %}

```go
package main

import (
    "context"
    "fmt"

    anthropic "github.com/anthropics/anthropic-sdk-go"
    "github.com/anthropics/anthropic-sdk-go/bedrock"
    "github.com/anthropics/anthropic-sdk-go/option"
    "github.com/aws/aws-sdk-go-v2/aws"
)

func main() {
    cfg := aws.Config{
        Region:                  "<AWS_REGION>",
        BearerAuthTokenProvider: bedrock.NewStaticBearerTokenProvider("<THREE_DEV_API_KEY>"),
    }

    client := anthropic.NewClient(
        bedrock.WithConfig(cfg),
        option.WithBaseURL("https://gate.three.dev"),
        option.WithHeader("x-three-use-case", "<USE_CASE_SLUG>"),
        option.WithHeader("x-three-ai-provider", "amazon_bedrock_runtime"),
    )

    message, err := client.Messages.New(context.TODO(), anthropic.MessageNewParams{
        Model:     "global.anthropic.claude-sonnet-4-6",
        MaxTokens: 1024,
        Messages: []anthropic.MessageParam{
            anthropic.NewUserMessage(anthropic.NewTextBlock("Hello!")),
        },
    })
    if err != nil {
        panic(err)
    }

    fmt.Printf("%+v\n", message.Content)
}
```

{% endcode %}
{% endtab %}

{% tab title="cURL" %}

```bash
# Anthropic model via InvokeModel
curl -X POST https://gate.three.dev/model/anthropic.claude-sonnet-4-6-v1:0/invoke \
  -H "Authorization: Bearer <THREE_DEV_API_KEY>" \
  -H "X-Three-Use-Case: <USE_CASE_SLUG>" \
  -H "X-Three-AI-Provider: amazon_bedrock_runtime" \
  -H "Content-Type: application/json" \
  -d '{
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1024,
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

```bash
# OpenAI model via InvokeModel
curl -X POST https://gate.three.dev/model/openai.gpt-oss-120b:0/invoke \
  -H "Authorization: Bearer <THREE_DEV_API_KEY>" \
  -H "X-Three-Use-Case: <USE_CASE_SLUG>" \
  -H "X-Three-AI-Provider: amazon_bedrock_runtime" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai.gpt-oss-120b",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

{% endtab %}
{% endtabs %}

### Bedrock Mantle

{% hint style="info" %}
**Coming soon.** Amazon Bedrock Mantle support is not yet available.
{% endhint %}

### Model ID format

Use the full Bedrock model ID in your requests (for example, `us.anthropic.claude-sonnet-4-6-v1:0`). three.dev strips regional prefixes (`us.`), provider prefixes (`anthropic.`), and version suffixes (`:0`) before storing the model name.

{% hint style="warning" %}
**Not supported**

| Scenario                                                | Reason                                                                                               |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Converse API** (`boto3.converse(...)`)                | Only accessible via boto3 with SigV4. No bearer token path.                                          |
| **SigV4 clients** (`aws_access_key` + `aws_secret_key`) | SigV4 signatures are bound to the destination URL and become invalid when forwarded through a proxy. |
| {% endhint %}                                           |                                                                                                      |

## Using LiteLLM

[LiteLLM](https://github.com/BerriAI/litellm) provides a unified Python interface for calling multiple LLM providers. Use the `Router` to configure per-provider settings when integrating with three.dev. Set the `api_base` and `X-Three-AI-Provider` header for each deployment based on the provider examples above.

{% code overflow="wrap" %}

```python
from litellm import Router

router = Router(
    model_list=[
        {
            "model_name": "primary-model",
            "litellm_params": {
                "model": "anthropic/claude-sonnet-4-6",
                "api_base": "https://gate.three.dev",
                "api_key": "<THREE_DEV_API_KEY>",
                "extra_headers": {
                    "X-Three-Use-Case": "<USE_CASE_SLUG>",
                    "X-Three-AI-Provider": "anthropic",
                    "Authorization": "Bearer <THREE_DEV_API_KEY>",
                },
            },
        },
        {
            "model_name": "fallback-model",
            "litellm_params": {
                "model": "openai/gpt-5-mini",
                "api_base": "https://gate.three.dev/v1",
                "api_key": "<THREE_DEV_API_KEY>",
                "extra_headers": {
                    "X-Three-Use-Case": "<USE_CASE_SLUG>",
                    "X-Three-AI-Provider": "openai",
                },
            },
        },
    ],
    fallbacks=[{"primary-model": ["fallback-model"]}],
)

response = router.completion(
    model="primary-model",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"},
    ],
)
```

{% endcode %}

* Use `Router` instead of `litellm.completion(fallbacks=...)` — the Router binds `api_base` and `extra_headers` at the deployment level, enabling clean provider switching.
* For Anthropic deployments, add `"Authorization": "Bearer <THREE_DEV_API_KEY>"` to `extra_headers`. LiteLLM's Anthropic handler uses `x-api-key`, but three.dev requires `Authorization: Bearer`.
* Each deployment needs a distinct `model_name`. The `fallbacks` parameter maps model names.

## Vercel AI SDK

The [Vercel AI SDK](https://ai-sdk.dev) provider packages take a base URL and headers when you create a provider instance. Create the instance with the three.dev headers, then pass `provider("<MODEL>")` as the `model` to `generateText`, `streamText`, or `generateObject`. The examples work with `ai` v6 and v7.

{% tabs %}
{% tab title="OpenAI" %}
{% code overflow="wrap" %}

```typescript
import { createOpenAI } from "@ai-sdk/openai";
import { generateText } from "ai";

const openai = createOpenAI({
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/v1",
    headers: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "openai",
    },
});

const { text } = await generateText({
    model: openai("gpt-5"),
    prompt: "Hello!",
});
```

{% endcode %}
{% endtab %}

{% tab title="Anthropic" %}
As with the Anthropic SDKs above, set the SDK's key to the placeholder `default` and send your three.dev API key in the `Authorization` header.

{% code overflow="wrap" %}

```typescript
import { createAnthropic } from "@ai-sdk/anthropic";
import { generateText } from "ai";

const anthropic = createAnthropic({
    apiKey: "default",
    baseURL: "https://gate.three.dev/v1",
    headers: {
        "Authorization": "Bearer <THREE_DEV_API_KEY>",
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "anthropic",
    },
});

const { text } = await generateText({
    model: anthropic("claude-sonnet-4-5"),
    prompt: "Hello!",
});
```

{% endcode %}

You can also pass your three.dev API key as `authToken: "<THREE_DEV_API_KEY>"` instead of setting `apiKey` and the `Authorization` header. Don't set both `apiKey` and `authToken`: `createAnthropic` throws an error.
{% endtab %}

{% tab title="Gemini" %}
{% code overflow="wrap" %}

```typescript
import { createGoogleGenerativeAI } from "@ai-sdk/google";
import { generateText } from "ai";

const google = createGoogleGenerativeAI({
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/v1beta",
    headers: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "gemini",
    },
});

const { text } = await generateText({
    model: google("gemini-3-flash-preview"),
    prompt: "Hello!",
});
```

{% endcode %}
{% endtab %}

{% tab title="OpenRouter" %}
{% code overflow="wrap" %}

```typescript
import { createOpenAICompatible } from "@ai-sdk/openai-compatible";
import { generateText } from "ai";

const openrouter = createOpenAICompatible({
    name: "openrouter",
    apiKey: "<THREE_DEV_API_KEY>",
    baseURL: "https://gate.three.dev/v1",
    headers: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "openrouter",
    },
});

const { text } = await generateText({
    model: openrouter("z-ai/glm-5.2"),
    prompt: "Hello!",
});
```

{% endcode %}
{% endtab %}

{% tab title="Azure OpenAI" %}
Store your Azure API key and resource endpoint in Settings as described in [Azure OpenAI](#azure-openai). As with Anthropic, set the SDK's key to the placeholder `default` and send your three.dev API key in the `Authorization` header. Use your Azure deployment name as the model. To keep the Azure key in your app instead, see [Sending your provider's address](#sending-your-providers-address).

{% code overflow="wrap" %}

```typescript
import { createAzure } from "@ai-sdk/azure";
import { generateText } from "ai";

const azure = createAzure({
    apiKey: "default",
    baseURL: "https://gate.three.dev/v1",
    headers: {
        "Authorization": "Bearer <THREE_DEV_API_KEY>",
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "azure_openai",
    },
});

const { text } = await generateText({
    model: azure("<AZURE_DEPLOYMENT_NAME>"),
    prompt: "Hello!",
});
```

{% endcode %}

If your app uses deployment-style URLs, set `useDeploymentBasedUrls` and an Azure API version. `apiVersion` is an Azure API version such as `2025-04-01-preview` (the value after `api-version=` in the deployment's Target URI), not the model version shown next to the deployment. If the deployment name or `apiVersion` is wrong, Azure responds with `404 Resource not found`.

{% code overflow="wrap" %}

```typescript
import { createAzure } from "@ai-sdk/azure";
import { generateText } from "ai";

const azure = createAzure({
    apiKey: "default",
    baseURL: "https://gate.three.dev/openai",
    useDeploymentBasedUrls: true,
    apiVersion: "<AZURE_API_VERSION>",
    headers: {
        "Authorization": "Bearer <THREE_DEV_API_KEY>",
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "azure_openai",
    },
});

const { text } = await generateText({
    model: azure.chat("<AZURE_DEPLOYMENT_NAME>"),
    prompt: "Hello!",
});
```

{% endcode %}

Both styles work with the Responses API (`azure("<AZURE_DEPLOYMENT_NAME>")`) and the Chat Completions API (`azure.chat("<AZURE_DEPLOYMENT_NAME>")`).

Keep `apiKey: "default"`. Without it, `createAzure` reads `AZURE_API_KEY` from the environment: if it is not set, the call throws `LoadAPIKeyError` before any request is sent, and if it is set, your Azure key is sent to three.dev instead of staying in your app.
{% endtab %}
{% endtabs %}

* **Anthropic needs `/v1`.** The AI SDK's Anthropic base URL includes `/v1` (its default is `https://api.anthropic.com/v1`), unlike the Anthropic SDK examples above. Without `/v1`, requests fail.
* **Use a provider instance, not the default export.** The default exports, such as `import { openai } from "@ai-sdk/openai"` and likewise `anthropic`, `google`, and `azure`, cannot carry the three.dev headers. Setting `OPENAI_BASE_URL` to `gate.three.dev` with the default export fails with `401 invalid_api_key`. Create an instance with `createOpenAI`, `createAnthropic`, `createGoogleGenerativeAI`, or `createAzure` and use it everywhere the default export was used.
* **Set the session per request.** Headers passed to `generateText` or `streamText` merge with the instance's headers, and the per-call value wins. For example, `generateText({ model, prompt, headers: { "x-three-session-id": sessionId } })`. See [Supported paths](https://docs.three.dev/sending-requests/supported-paths.md) for sessions and tags.

## LangChain and LangGraph

[LangChain](https://www.langchain.com) chat model classes, such as `ChatOpenAI` and `ChatAnthropic`, take an API key, a base URL, and headers when you create them. Create the model with your three.dev API key and the three.dev headers, then use it as before: `invoke`, `stream`, `bind_tools`, `with_structured_output`, and [LangGraph agents](#langgraph-agents) all go through the proxy. three.dev uses the provider keys stored in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys). The Python examples work with `langchain` 0.3 and 1.x and `langgraph` 0.6 and 1.x. The TypeScript examples work with LangChain.js 1.x.

{% tabs %}
{% tab title="OpenAI" %}

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="gpt-5",
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "openai"},
    stream_usage=True,
)

response = llm.invoke("Hello!")
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI({
    model: "gpt-5",
    apiKey: "<THREE_DEV_API_KEY>",
    configuration: {
        baseURL: "https://gate.three.dev/v1",
        defaultHeaders: {
            "x-three-use-case": "<USE_CASE_SLUG>",
            "x-three-ai-provider": "openai",
        },
    },
});

const response = await llm.invoke("Hello!");
```

{% endcode %}

</details>

To use the Responses API, add `use_responses_api=True` in Python or `useResponsesApi: true` in TypeScript.
{% endtab %}

{% tab title="Anthropic" %}
As with the Anthropic SDKs above, set the SDK's key to the placeholder `default` and send your three.dev API key in the `Authorization` header. The base URL has no `/v1`.

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(
    model="claude-sonnet-4-5",
    api_key="default",
    base_url="https://gate.three.dev",
    default_headers={"Authorization": "Bearer <THREE_DEV_API_KEY>", "x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "anthropic"},
)

response = llm.invoke("Hello!")
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import { ChatAnthropic } from "@langchain/anthropic";

const llm = new ChatAnthropic({
    model: "claude-sonnet-4-5",
    apiKey: "default",
    anthropicApiUrl: "https://gate.three.dev",
    clientOptions: {
        defaultHeaders: {
            "Authorization": "Bearer <THREE_DEV_API_KEY>",
            "x-three-use-case": "<USE_CASE_SLUG>",
            "x-three-ai-provider": "anthropic",
        },
    },
});

const response = await llm.invoke("Hello!");
```

{% endcode %}

</details>
{% endtab %}

{% tab title="Gemini" %}

<details>

<summary>Python</summary>

With `langchain-google-genai` 4.x:

{% code overflow="wrap" %}

```python
from langchain_google_genai import ChatGoogleGenerativeAI

llm = ChatGoogleGenerativeAI(
    model="gemini-3-flash-preview",
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev",
    additional_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "gemini"},
)

response = llm.invoke("Hello!")
```

{% endcode %}

`langchain-google-genai` versions below 4.x use gRPC by default, which cannot go through the proxy. Set the REST transport and pass the proxy address in `client_options`:

{% code overflow="wrap" %}

```python
from langchain_google_genai import ChatGoogleGenerativeAI

llm = ChatGoogleGenerativeAI(
    model="gemini-3-flash-preview",
    api_key="<THREE_DEV_API_KEY>",
    transport="rest",
    client_options={"api_endpoint": "https://gate.three.dev"},
    additional_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "gemini"},
)
```

{% endcode %}

{% hint style="warning" %}
On `langchain-google-genai` 2.1.x, async calls such as `ainvoke`, `astream`, and async agent runs use gRPC whatever `transport` is set to, so they cannot go through the proxy. Use synchronous calls, or upgrade to 4.x.
{% endhint %}

</details>

<details>

<summary>TypeScript</summary>

With `@langchain/google-genai`:

{% code overflow="wrap" %}

```typescript
import { ChatGoogleGenerativeAI } from "@langchain/google-genai";

const llm = new ChatGoogleGenerativeAI({
    model: "gemini-3-flash-preview",
    apiKey: "<THREE_DEV_API_KEY>",
    baseUrl: "https://gate.three.dev",
    customHeaders: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "gemini",
    },
});

const response = await llm.invoke("Hello!");
```

{% endcode %}

With `@langchain/google`, the option names differ:

{% code overflow="wrap" %}

```typescript
import { ChatGoogle } from "@langchain/google";

const llm = new ChatGoogle({
    model: "gemini-3-flash-preview",
    apiKey: "<THREE_DEV_API_KEY>",
    endpoint: "https://gate.three.dev",
    customHeaders: {
        "x-three-use-case": "<USE_CASE_SLUG>",
        "x-three-ai-provider": "gemini",
    },
});
```

{% endcode %}

</details>

Gemini's OpenAI-compatible API also works with `ChatOpenAI`: use the example in the OpenRouter tab with a Gemini model, the base URL `https://gate.three.dev/v1beta/openai`, and `x-three-ai-provider: gemini`.
{% endtab %}

{% tab title="OpenRouter" %}

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="z-ai/glm-5.2",
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "openrouter"},
    stream_usage=True,
)

response = llm.invoke("Hello!")
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import { ChatOpenAI } from "@langchain/openai";

const llm = new ChatOpenAI({
    model: "z-ai/glm-5.2",
    apiKey: "<THREE_DEV_API_KEY>",
    configuration: {
        baseURL: "https://gate.three.dev/v1",
        defaultHeaders: {
            "x-three-use-case": "<USE_CASE_SLUG>",
            "x-three-ai-provider": "openrouter",
        },
    },
});

const response = await llm.invoke("Hello!");
```

{% endcode %}

</details>
{% endtab %}

{% tab title="Azure OpenAI" %}
Store your Azure API key and resource endpoint in Settings as described in [Azure OpenAI](#azure-openai), and send your three.dev API key in the `Authorization` header. For deployment URLs, use `AzureChatOpenAI` with the key set to the placeholder `default`: LangChain builds deployment URLs only when a key is set, and three.dev replaces the placeholder with your stored Azure key. The API version is an Azure API version such as `2025-04-01-preview`, not the model version shown next to the deployment. To keep the Azure key in your app instead, see [Sending your provider's address](#sending-your-providers-address).

<details>

<summary>Python</summary>

{% code overflow="wrap" %}

```python
from langchain_openai import AzureChatOpenAI

llm = AzureChatOpenAI(
    api_key="default",
    azure_endpoint="https://gate.three.dev",
    azure_deployment="<AZURE_DEPLOYMENT_NAME>",
    api_version="<AZURE_API_VERSION>",
    default_headers={"Authorization": "Bearer <THREE_DEV_API_KEY>", "x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "azure_openai"},
    stream_usage=True,
)

response = llm.invoke("Hello!")
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import { AzureChatOpenAI } from "@langchain/openai";

const llm = new AzureChatOpenAI({
    azureOpenAIApiKey: "default",
    azureOpenAIEndpoint: "https://gate.three.dev",
    azureOpenAIApiDeploymentName: "<AZURE_DEPLOYMENT_NAME>",
    azureOpenAIApiVersion: "<AZURE_API_VERSION>",
    configuration: {
        defaultHeaders: {
            "Authorization": "Bearer <THREE_DEV_API_KEY>",
            "x-three-use-case": "<USE_CASE_SLUG>",
            "x-three-ai-provider": "azure_openai",
        },
    },
});

const response = await llm.invoke("Hello!");
```

{% endcode %}

</details>

For v1 URLs, use the example in the OpenAI tab with your Azure deployment name as the model and `x-three-ai-provider: azure_openai`. This works with the Chat Completions API and the Responses API.
{% endtab %}
{% endtabs %}

* **Set the three.dev headers on the model.** Pointing `OPENAI_BASE_URL` or `ANTHROPIC_BASE_URL` at `gate.three.dev` without the headers fails with `401 invalid_api_key` (OpenAI) or `401 missing_api_key` (Anthropic).
* **Set `stream_usage=True` on `ChatOpenAI` in Python.** `ChatOpenAI` turns it off when you set a base URL, and streamed requests then reach three.dev without tokens or cost. LangChain.js streams usage by default. See [Supported paths](https://docs.three.dev/sending-requests/supported-paths.md).
* **Leave `/v1` out of the Anthropic base URL.** LangChain's Anthropic classes add `/v1/messages` themselves, unlike the Vercel AI SDK's Anthropic provider.
* **Use the REST transport with `langchain-google-genai` below 4.x.** Its default gRPC transport cannot go through the proxy. On 2.1.x, async calls use gRPC even with the REST transport.
* **Set the session per call.** In Python, pass `extra_headers` to `invoke` or `bind`, for both `ChatOpenAI` and `ChatAnthropic`. For example, `llm.invoke(messages, extra_headers={"x-three-session-id": session_id})`. In LangChain.js, use `llm.invoke(messages, { options: { headers } })` or `llm.withConfig({ options: { headers } })` for `ChatOpenAI`, and `llm.invoke(messages, { headers })` for `ChatAnthropic`. Per-call headers merge with the model's headers, and the per-call value wins. `RunnableConfig` metadata and `configurable` values do not become headers.
* **Pass the wiring per provider when switching models at runtime.** `init_chat_model("openai:gpt-5", ...)` and `initChatModel` pass the options through to the model class. A model switched at runtime with `configurable_fields` must list the key, base URL, and header fields, and receive each provider's values in `config["configurable"]`. If the OpenAI wiring is reused for Anthropic, Python requests fail with `404`, and LangChain.js sends them straight to `api.anthropic.com` without an error and without three.dev recording them. In LangChain.js, `initChatModel` needs a default model, and the runtime config must name `modelProvider`.
* **Langfuse works alongside the wiring.** With Langfuse's LangChain `CallbackHandler` or its OpenAI wrapper, each call goes through the proxy once, and three.dev records it once.

### LangGraph agents

Pass the model to `create_agent` (`langchain` 1.x), `create_react_agent` (`langgraph.prebuilt`), or `createAgent` (LangChain.js). three.dev records every model call in the tool loop. To group an agent run into one session, set the session header from the run's context:

<details>

<summary>Python (langchain 1.x)</summary>

{% code overflow="wrap" %}

```python
from dataclasses import dataclass

from langchain.agents import create_agent
from langchain.agents.middleware import wrap_model_call


@dataclass
class Context:
    session_id: str


@wrap_model_call
def three_session(request, handler):
    headers = {"x-three-session-id": request.runtime.context.session_id}
    return handler(request.override(model_settings={**request.model_settings, "extra_headers": headers}))


agent = create_agent(model=llm, tools=tools, middleware=[three_session], context_schema=Context)

agent.invoke({"messages": [{"role": "user", "content": "Hello!"}]}, context=Context(session_id="<SESSION_ID>"))
```

{% endcode %}

</details>

<details>

<summary>Python (langgraph 0.6)</summary>

{% code overflow="wrap" %}

```python
from dataclasses import dataclass

from langgraph.prebuilt import create_react_agent


@dataclass
class Context:
    session_id: str


def select_model(state, runtime):
    return llm.bind_tools(tools).bind(extra_headers={"x-three-session-id": runtime.context.session_id})


agent = create_react_agent(model=select_model, tools=tools, context_schema=Context)

agent.invoke({"messages": [{"role": "user", "content": "Hello!"}]}, context=Context(session_id="<SESSION_ID>"))
```

{% endcode %}

</details>

<details>

<summary>TypeScript</summary>

{% code overflow="wrap" %}

```typescript
import { createAgent, createMiddleware } from "langchain";
import { z } from "zod";

const threeSession = createMiddleware({
    name: "ThreeSession",
    contextSchema: z.object({ sessionId: z.string() }),
    wrapModelCall: (request, handler) =>
        handler({
            ...request,
            modelSettings: {
                ...request.modelSettings,
                options: { headers: { "x-three-session-id": request.runtime.context.sessionId } },
            },
        }),
});

const agent = createAgent({ model: llm, tools, middleware: [threeSession] });

await agent.invoke(
    { messages: [{ role: "user", content: "Hello!" }] },
    { context: { sessionId: "<SESSION_ID>" } },
);
```

{% endcode %}

With `ChatAnthropic`, set the headers on `modelSettings` directly:

{% code overflow="wrap" %}

```typescript
modelSettings: { ...request.modelSettings, headers: { "x-three-session-id": request.runtime.context.sessionId } },
```

{% endcode %}

The `options.headers` form works only with `ChatOpenAI`. With `ChatAnthropic`, it drops the session without an error: three.dev still records the requests but doesn't group them into the session.

</details>

In Python, both session examples work with `ChatOpenAI` and `ChatAnthropic`.
