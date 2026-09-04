<!-- Synced from https://docs.three.dev/sending-requests/ai-providers-integration.md by scripts/sync-references.sh. Do not edit; the live page wins. -->

# AI Providers Integration

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
The examples below use the Chat Completions API, which three.dev supports with [advanced observability](https://docs.three.dev/sending-requests/supported-paths.md). The [GenAI SDK](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/sdks/overview) is also supported with basic observability.

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

Specify the AI provider for each request with the `X-Three-AI-Provider` header. Accepted values are `openai`, `anthropic`, `gemini`, `azure_openai`, `amazon_bedrock_runtime`, `amazon_bedrock_mantle`, and `openrouter`.

Add your provider's API key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys). One key can be marked as the Default Provider — used when no `X-Three-AI-Provider` header is specified. If a provider is specified but no key exists for it in three.dev, the request fails with an authentication error.

## Azure OpenAI

Azure OpenAI is supported as a separate provider. When configuring an Azure OpenAI provider key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys), specify both your API key and your Azure resource endpoint URL (for example, `https://my-resource.openai.azure.com`).

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

## Amazon Bedrock

Amazon Bedrock is supported through two provider types: **Runtime** (available now) and **Mantle** (coming soon). When configuring a Bedrock provider key in [Settings > AI Provider Keys](https://app.three.dev/settings/ai-provider-keys), select "Amazon Bedrock", choose Runtime, select your AWS region, and enter your Bedrock API key. The endpoint URL is derived automatically — no need to look it up.

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
{% endhint %}

| Scenario                                                | Reason                                                                                               |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Converse API** (`boto3.converse(...)`)                | Only accessible via boto3 with SigV4. No bearer token path.                                          |
| **SigV4 clients** (`aws_access_key` + `aws_secret_key`) | SigV4 signatures are bound to the destination URL and become invalid when forwarded through a proxy. |

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
