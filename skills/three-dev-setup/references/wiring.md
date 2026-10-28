# Wiring

Contents: [Files that may hold a key](#files-that-may-hold-a-key) ·
[Reading the provider page](#reading-the-provider-page) ·
[Every wired client](#every-wired-client) ·
[A provider's default export](#a-providers-default-export) ·
[LangChain and LangGraph](#langchain-and-langgraph) ·
[By kind of app](#by-kind-of-app)

The app keeps its own provider key and sends it as it does today. The proxy
forwards it untouched and learns who is calling from a separate header.
A provider's own address, a host three.dev does not forward to, and a client
already on three.dev are in
[provider-address.md](provider-address.md); the diff review and the check
request are in [check-request.md](check-request.md).

## Files that may hold a key

Work in this order, before you open any file. A README, a manifest, or a
quick look with `cat`, `head`, or your file tool counts as opening one.
Before step 1, read only names: `ls`, `git ls-files`.

**1. List.** Run these two commands once, each alone in its own call: never
join them with `;` or `&&`, or with a read. Both print file names, never a
line: the files with changes, which were made before you started, and the
files git does not ignore whose text has a key-shaped value. Outside a
repository too, the listing comes first: write `--no-index` for every
`--untracked` in this section.

```bash
git status --porcelain
```

```bash
git grep -lIE --untracked '(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-)[A-Za-z0-9_-]{32,}|AIza[A-Za-z0-9_-]{35}|(AKIA|ASIA)[A-Z0-9]{16})'
```

**2. Count before you open a listed file.** For source code, or a tracked
file with no changes, that the second command lists, test files and
templates included, count its
key-shaped values that are not placeholders (a placeholder word, or a run of
eight `0`, `1`, `a`, or `z`). It prints a number, never a value:

```bash
git grep -hoIE --untracked '(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-)[A-Za-z0-9_-]{32,}|AIza[A-Za-z0-9_-]{35}|(AKIA|ASIA)[A-Z0-9]{16})' -- <file> | grep -cviE 'test|fake|example|dummy|sample|placeholder|xxxx|your|0{8}|1{8}|a{8}|z{8}'
```

`0` (grep exits 1, which is normal here) means open it as usual. A higher
count means it may hold a key: when it has a call site, leave it unchanged,
with "Not connected: `<file>`, it holds a key, so I left it unchanged."
Other listed files follow step 3.

**3. Open only what the rules below allow.** A file may hold a key, whatever
its name, unless it is an installed dependency, when it is:

- an env file (not a template such as `.env.example`), a file git ignores,
  or an untracked file that is not source code;
- a config or data file (YAML, JSON, TOML, INI, `.properties`, XML, a
  secrets file) git tracks, with changes made before you started;
- the file the provider key's trace leads to, as "Is the provider key
  there?" says;
- a file the second command lists, except source code, or a file git tracks
  with no changes made before you started, whose count in step 2 is `0`.

Outside a repository, git cannot say which files are ignored or changed:
every env, config, data, or secrets file may hold a key, besides the files
the second command lists. A README, a dependency manifest or lock file
(`package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`), and any
other file that is none of these open as usual, once step 1 has run.

Never open a file that may hold a key, with your file tool or any other way.
What you need from it comes another way:

- Field and variable names come from the code that reads them and the
  templates you may open (`config.example.yaml`, `.env.example`), once step
  2 counts `0` for one the listing names. A template that may hold a key gets
  no `THREE_DEV_API_KEY=` line.
- Whether a key in it is set comes from the app's own loader, as "Is the
  provider key there?" in [check-request.md](check-request.md#the-check-request)
  says, never from a parser of your own.
- Its text comes only through the filter. A file that is on the second
  command's list and in no other rule above is read as it is:

```bash
sed -E 's#^[A-Za-z0-9+/=]{40,}$#[redacted]#; s#(://[^/:@[:space:]]+:)[^@[:space:]]+@#\1[redacted]@#g; s/([Ss][Ee][Cc][Rr][Ee][Tt]|[Pp][Aa][Ss][Ss][Ww]([Oo][Rr])?[Dd]|[Tt][Oo][Kk][Ee][Nn]|[Kk][Ee][Yy])([^A-Za-z0-9[:space:]:=]?[[:space:]]*[:=][[:space:]]*[^A-Za-z0-9[:space:]]?)[A-Za-z0-9+/=_-]*[a-z0-9+/][A-Za-z0-9+/=_-]*([^A-Za-z0-9+/=_.([-]|$)/\1\3[redacted]\4/g; s/(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-|AIza)[A-Za-z0-9_-]{8,}|(AKIA|ASIA)[A-Z0-9]{8,}|[a-z]{2}_(live|test)_[A-Za-z0-9]{8,}|xox[abpr]-[A-Za-z0-9-]{8,}|fw_[A-Za-z0-9]{8,})/\1[redacted]/g; s/[A-Za-z0-9]{32,}/[redacted]/g' <path>
```

Any other tracked one, only as its committed copy:

```bash
git show HEAD:<path> | sed -E 's#^[A-Za-z0-9+/=]{40,}$#[redacted]#; s#(://[^/:@[:space:]]+:)[^@[:space:]]+@#\1[redacted]@#g; s/([Ss][Ee][Cc][Rr][Ee][Tt]|[Pp][Aa][Ss][Ss][Ww]([Oo][Rr])?[Dd]|[Tt][Oo][Kk][Ee][Nn]|[Kk][Ee][Yy])([^A-Za-z0-9[:space:]:=]?[[:space:]]*[:=][[:space:]]*[^A-Za-z0-9[:space:]]?)[A-Za-z0-9+/=_-]*[a-z0-9+/][A-Za-z0-9+/=_-]*([^A-Za-z0-9+/=_.([-]|$)/\1\3[redacted]\4/g; s/(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-|AIza)[A-Za-z0-9_-]{8,}|(AKIA|ASIA)[A-Z0-9]{8,}|[a-z]{2}_(live|test)_[A-Za-z0-9]{8,}|xox[abpr]-[A-Za-z0-9-]{8,}|fw_[A-Za-z0-9]{8,})/\1[redacted]/g; s/[A-Za-z0-9]{32,}/[redacted]/g'
```

An untracked or ignored one, or any one outside a repository, never, except
the shape of a YAML, TOML, INI, or `.properties` file. This prints only its
section and field names, and drops every value and every line without a
name:

```bash
sed -nE 's/^([[:space:]-]*[A-Za-z_][A-Za-z0-9_.-]*[[:space:]]*:).*/\1/p; s/^([[:space:]]*[A-Za-z_][A-Za-z0-9_.-]*[[:space:]]*=)[^=].*/\1/p; /^[[:space:]]*\[[^]]*\][[:space:]]*$/p' <path> | sed -E 's#^[A-Za-z0-9+/=]{40,}$#[redacted]#; s#(://[^/:@[:space:]]+:)[^@[:space:]]+@#\1[redacted]@#g; s/([Ss][Ee][Cc][Rr][Ee][Tt]|[Pp][Aa][Ss][Ss][Ww]([Oo][Rr])?[Dd]|[Tt][Oo][Kk][Ee][Nn]|[Kk][Ee][Yy])([^A-Za-z0-9[:space:]:=]?[[:space:]]*[:=][[:space:]]*[^A-Za-z0-9[:space:]]?)[A-Za-z0-9+/=_-]*[a-z0-9+/][A-Za-z0-9+/=_-]*([^A-Za-z0-9+/=_.([-]|$)/\1\3[redacted]\4/g; s/(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-|AIza)[A-Za-z0-9_-]{8,}|(AKIA|ASIA)[A-Z0-9]{8,}|[a-z]{2}_(live|test)_[A-Za-z0-9]{8,}|xox[abpr]-[A-Za-z0-9-]{8,}|fw_[A-Za-z0-9]{8,})/\1[redacted]/g; s/[A-Za-z0-9]{32,}/[redacted]/g'
```

Never move, edit, or remove a key. Step 6 gets, word for word, when it
applies: the trace and the key check are what you saw, so state it.

- The provider key's trace leads to a tracked file with changes made before
  you started, and the key check says `set`: "`<file>` is tracked by git and
  has local changes, and your app reads its `<provider>` key from it: keep
  those changes out of commits, or move the key to `<env file>`."
- The trace leads to a file, or a call site is in one, whose committed copy
  counts above `0` with the command below: "`<file>` has a key committed to
  git: revoke it with your provider and remove it from the history."
- An env template the app does not load (`.env.example`, `.env.sample`) is
  on the second command's list and counts above `0` with step 2's count,
  run for it, and the key check for the file the app does load says `unset`:
  "`<template>` holds what looks like a key, but your app reads `<the file
  it loads>`: move the key there, and keep it out of `<template>`."

```bash
git grep -hoIE '(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-)[A-Za-z0-9_-]{32,}|AIza[A-Za-z0-9_-]{35}|(AKIA|ASIA)[A-Z0-9]{16})' HEAD -- <file> | grep -cviE 'test|fake|example|dummy|sample|placeholder|xxxx|your|0{8}|1{8}|a{8}|z{8}'
```

None of these lines changes the report's reason.

## Reading the provider page

The AI Providers Integration page ([live](https://docs.three.dev/sending-requests/ai-providers-integration.md),
[local copy](ai-providers-integration.md)) shows the three.dev key as the
SDK's key, with the provider key stored in three.dev. Take from its example
for the exact client in the code:

- the base URL and its path,
- the `X-Three-AI-Provider` value,
- how that SDK sets default headers and per-call headers,
- which clients are unsupported.

A client it has no example for is wired from its own library, as
[library-wiring.md](library-wiring.md) says.

Do not take from it where the keys go. Wherever an example sets the SDK's key
or an `Authorization` header to `<THREE_DEV_API_KEY>`, or a placeholder key
such as `default`, leave the app's own provider credential exactly as it is
and add `X-Three-Api-Key` instead. Ignore its instruction to add a provider
key in three.dev's settings. Its section "Using your app's own provider key"
shows this form, for Google's GenAI SDK.

For a client whose provider has its own address, take the client's URL and
the address header from this file, not from the page. The page may show the
address cut in two, host in the header and the rest on the client. That form
still works, and it is not the one you write.

## Every wired client

The page's OpenAI example:

```python
client = OpenAI(
    api_key="<THREE_DEV_API_KEY>",
    base_url="https://gate.three.dev/v1",
    default_headers={"x-three-use-case": "<USE_CASE_SLUG>", "x-three-ai-provider": "openai"},
)
```

What you write for an app whose client was `OpenAI()`, with its key read from
`OPENAI_API_KEY`:

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

- `X-Three-Api-Key` carries the three.dev key, read from `THREE_DEV_API_KEY`
  the way the code reads its provider key.
- Without the key, unset or empty, the client is built exactly as before:
  same address, no three.dev header, no error. Every argument the client
  already had goes in both branches.
- Per-call `X-Three-*` headers (the session ID, session tags, request tags)
  go only on a call that goes through three.dev. Set `through_three_dev`
  where the client is chosen, true exactly when the wiring points it at
  `gate.three.dev`, from the same test: `bool(three_dev_key)` when the key is
  that whole test, and false whenever a setting sends the client to another
  host. When the call is in another file, export the flag next to the client
  and import it with the client; never test the key again at the call site.
  Add the headers under it, in the call's own per-call option:

```python
response = client.chat.completions.create(
    model=MODEL,
    messages=messages,
    **({"extra_headers": {"X-Three-Session-ID": session_id}} if through_three_dev else {}),
)
```

- Without the key, or on another host, the call is exactly what it was
  before. When the call already passes headers, they stay on both branches
  and the `X-Three-*` ones are merged in under the test. In TypeScript the
  same spread goes in the option the installed SDK reads per call (`headers`
  in the Vercel AI SDK's `generateText` and `streamText`, the second
  argument's `headers` in the OpenAI and Anthropic SDKs). A framework's
  middleware or per-call config that adds these headers is added under the
  same test.
- `X-Three-AI-Provider` is required on every request: without it the proxy
  cannot tell which provider the credential is for.
- If the client already has default headers, add to them and keep the rest.
- If the client is built without an explicit key, leave it that way: the SDK
  reads its own variable.
- The three.dev key goes only where the library sends it as a header and
  never saves, logs, or traces it: the client's default headers, or an HTTP
  client the wiring builds. Never in per-call options, model settings, or a
  config object a framework records. [LangChain](#langchain-and-langgraph) is
  the case to know.
- A client whose transport the app's own code picks from a setting, such as
  WebSocket by default and HTTPS when a base URL or a mode is set, is wired
  on that HTTPS path: the three.dev branch takes it in code, the way the
  setting does, never by setting the variable, and the check goes through
  it. A transport with no HTTPS mode in the app stays unsupported. Step 6
  gets "`<file>` calls `<provider>` over WebSocket by default. With
  three.dev, it uses the app's own HTTPS mode, the one `<setting>` turns on,
  so its calls may be a little slower. Remove `THREE_DEV_API_KEY` to go back
  to WebSocket; three.dev then stops recording them."
- When settings choose between providers (a provider name, a model prefix,
  an address setting, whichever key is set), wire every provider the code
  offers, each by its own rule, never only the default: the settings keep
  choosing per run.
- The session ID, the environment tag, and the other tags are in
  [sessions-and-tags.md](sessions-and-tags.md).

**Streamed Chat Completions calls.** On a stream, Chat Completions sends usage
only on a last chunk, and only when the request asks for it; without it
three.dev records the call with no tokens and no cost. A streamed call
(`chat.completions.create(..., stream=True)`, the SDK's
`chat.completions.stream(...)`, or raw HTTP to `/chat/completions` with
`"stream": true`) to OpenAI, OpenRouter, or Concentrate gets `stream_options`
with `include_usage` set to true, only when the call goes through three.dev:
under the same test that points the client at `gate.three.dev`, not the key
alone.

```python
stream = client.chat.completions.create(
    model=MODEL,
    messages=messages,
    stream=True,
    **({"stream_options": {"include_usage": True}} if through_three_dev else {}),
)
for chunk in stream:
    if chunk.choices:
        print(chunk.choices[0].delta.content or "", end="")
```

- `through_three_dev` is the flag [above](#every-wired-client). When the
  same call site can also reach Azure OpenAI or Gemini through three.dev,
  test the provider too: the option goes only to OpenAI, OpenRouter, and
  Concentrate. In TypeScript, add
  `...(throughThreeDev ? { stream_options: { include_usage: true } } : {})`
  to the call's options; in raw HTTP, set the field in the body under the
  same test.
- Leave the call as it is when it already sets `stream_options`, or when its
  client asks for usage by itself, as its installed source shows (the Vercel
  AI SDK does). The Responses and Messages APIs send usage on every stream by
  themselves, and LangChain has [its own rule](#langchain-and-langgraph).
- The option adds a last chunk whose `choices` is empty. Add it only when
  every place that reads the stream's chunks, in the loop or after it,
  skips that chunk: it tests the chunk's `choices` (`chunk.choices`,
  `data["choices"]`) before indexing it, iterates over it, or reads
  `choices[0]?.` in TypeScript; the `.stream()` helper reads the chunks
  itself. Code that reads the first choice of every chunk, or a stream
  passed to code you cannot read, leaves the call unchanged, and Step 6 gets
  "`<file>`'s streamed calls are recorded without tokens or cost: it reads
  the first choice of every chunk. To record them, skip chunks with no
  choices there and add `stream_options` with `include_usage` set to
  true."
- Azure OpenAI refuses `stream_options` on some API versions: its streamed
  calls stay as they are, and Step 6 gets "`<file>`'s streamed calls to
  Azure OpenAI are recorded without tokens or cost. If your API version
  accepts `stream_options`, set `include_usage` to true in it." Gemini's
  OpenAI-compatible address stays as it is too.

## A provider's default export

Some SDKs export a ready-made client that takes no headers, such as the
Vercel AI SDK's `openai`, `anthropic`, and `google`. Replacing it with an
instance from the page's create function (`createOpenAI`, `createAnthropic`,
...) is the wiring, not a refactor. Keep the diff to the import:

- Create the instance under the name the code imports, so no call site
  changes.
- Give it only the base URL and the headers. Leave out the key, so it reads
  the variable the default read.
- When one file uses the default, create the instance in that file, in place
  of the import.
- When several files use it, create the instances once, in a new module next
  to the app's other LLM code, one per use case. In each file change only the
  import, renamed to the old name:
  `import { supportAssistant as openai } from "./threedev"`.
- Without the key, the instance is the default itself:

```typescript
import { createOpenAI, openai } from "@ai-sdk/openai";

const threeDevKey = process.env.THREE_DEV_API_KEY;

export const supportAssistant = threeDevKey
    ? createOpenAI({
          baseURL: "https://gate.three.dev/v1",
          headers: {
              "X-Three-Api-Key": threeDevKey,
              "X-Three-Use-Case": "support-assistant",
              "X-Three-AI-Provider": "openai",
          },
      })
    : openai;
```

- The default `openai` also reads `OPENAI_BASE_URL` by itself: when the code,
  the README, or the env template uses it, see
  [An address read from a setting](provider-address.md#an-address-read-from-a-setting).

## LangChain and LangGraph

A LangChain chat model (`ChatOpenAI`, `ChatAnthropic`,
`ChatGoogleGenerativeAI`, `AzureChatOpenAI`) is wired where it is created,
like any client. The page's example for the exact class and language names
its options for the base URL and the headers; a class it has no example for
(`langchain_openai.OpenAI`, a community class) is wired as
[library-wiring.md](library-wiring.md) says. Beyond that:

- Python's `ChatOpenAI` and `AzureChatOpenAI` get `stream_usage=True` in the
  three.dev branch, unless the app already sets `stream_usage` or
  `stream_options`, or the installed class has no such field. With a base
  URL set, LangChain stops asking for usage on streamed calls, and three.dev
  would record them without tokens or cost.
- `init_chat_model` or `initChatModel` takes the wiring of the class its
  provider creates. When the provider comes from a setting
  (`model_provider=settings.provider`), the code decides per run, as for
  [an address read from a setting](provider-address.md#an-address-read-from-a-setting): each
  provider the page has an example for gets a branch with its class's
  wiring, and any other value builds the model as before. A provider found
  only inside a model string read from a setting (`"openai:gpt-5"`), or
  switched at call time (`configurable_fields`), leaves the model unchanged,
  reported as not connected.
- In a LangGraph agent (`create_agent`, `create_react_agent`, `createAgent`),
  set the session with the page's middleware for that version only when the
  run already carries the ID in its context (`context=`), and add the
  middleware under the same test as the agent's model, as for
  [per-call headers](#every-wired-client). Otherwise the agent's calls go
  without a session header.
- Callbacks and tracing (Langfuse, LangSmith) stay as they are.

**Where the three.dev key goes.** LangChain saves each model's settings, its
headers included, and hands them to tracing (LangSmith, Langfuse) with every
call; only the SDK's key is hidden. The three.dev key never reaches a trace,
so `X-Three-Api-Key` goes only on a client the wiring builds, which LangChain
does not save:

- Python's `ChatOpenAI` and `AzureChatOpenAI`: on the OpenAI SDK's own HTTP
  clients, given as `http_client` and `http_async_client`. `ChatOpenAI`
  refuses those next to a proxy, which it also reads from `OPENAI_PROXY`:
  give the clients the proxy the model would have used, and set
  `openai_proxy=None`.
- Python's `ChatAnthropic`: the model is built as before. The three.dev
  branch then gives it Anthropic SDK clients built from its own client
  settings (`_client_params`), with the proxy address and every `X-Three-*`
  header added, as its `_client` and `_async_client`. Give both the
  model's `anthropic_proxy`, which it may read from `ANTHROPIC_PROXY`,
  through the SDK's `DefaultHttpxClient` and `DefaultAsyncHttpxClient`. The
  installed class's source must show those three names and its calls going
  through the two clients.
- Python's `ChatGoogleGenerativeAI` 4.x: the model is built as before. The
  three.dev branch then replaces its `client`, a field LangChain never
  saves, with a Gen AI SDK `Client` built from the same settings the
  installed class gives its own (its source shows them: in 4.4, the key,
  `api_version`, `client_args`, and `additional_headers`), plus the proxy
  address and every `X-Three-*` header. Only when the model's client is not
  in Vertex AI mode (`client.vertexai`).
- LangChain.js classes: on a `fetch` wrapper, given as `configuration.fetch`
  (`clientOptions.fetch` for `ChatAnthropic`). When the app already passes a
  `fetch`, the wrapper calls it.
- Any other class or version: look for a place in its installed source, as
  [library-wiring.md](library-wiring.md#what-to-write) says, the way the
  places above were found: an SDK or HTTP client the model takes or holds
  and LangChain does not save.

Only when the installed source shows no such place (`ChatGoogleGenerativeAI`
below 4.x, an installed `openai` with no `DefaultHttpxClient`, a Python model
the app already gives an HTTP client) leave the model unchanged and report
"Not connected: `<file>`, its library would put your three.dev key in
traces." Never add the key to an HTTP client the app passes: it may serve
other hosts.

The other headers stay in the page's header option, except on a client the
wiring builds whole. A model built as before keeps its own settings, so one
LangChain rebuilds from them (configurable fields, a copy) calls the
provider directly: unrecorded, never broken.

```python
from openai import DefaultAsyncHttpxClient, DefaultHttpxClient

three_dev_key = os.environ.get("THREE_DEV_API_KEY")
if three_dev_key:
    three_dev_key_header = {"X-Three-Api-Key": three_dev_key}
    proxy = os.environ.get("OPENAI_PROXY")
    llm = ChatOpenAI(
        model="gpt-5",
        base_url="https://gate.three.dev/v1",
        default_headers={"X-Three-Use-Case": "support-assistant", "X-Three-AI-Provider": "openai"},
        openai_proxy=None,
        http_client=DefaultHttpxClient(proxy=proxy, headers=three_dev_key_header),
        http_async_client=DefaultAsyncHttpxClient(proxy=proxy, headers=three_dev_key_header),
        stream_usage=True,
    )
else:
    llm = ChatOpenAI(model="gpt-5")
```

```typescript
const threeDevKey = process.env.THREE_DEV_API_KEY;

const withThreeDevKey = (key: string, send = fetch) =>
    (url: RequestInfo | URL, init?: RequestInit) => {
        const headers = new Headers(init?.headers);
        headers.set("X-Three-Api-Key", key);
        return send(url, { ...init, headers });
    };

export const llm = threeDevKey
    ? new ChatOpenAI({
          model: "gpt-5",
          configuration: {
              baseURL: "https://gate.three.dev/v1",
              defaultHeaders: { "X-Three-Use-Case": "support-assistant", "X-Three-AI-Provider": "openai" },
              fetch: withThreeDevKey(threeDevKey),
          },
      })
    : new ChatOpenAI({ model: "gpt-5" });
```

```python
import anthropic

llm = ChatAnthropic(model="claude-sonnet-4-5")
three_dev_key = os.environ.get("THREE_DEV_API_KEY")
if three_dev_key:
    client_params = llm._client_params
    three_dev_params = {
        **client_params,
        "base_url": "https://gate.three.dev",
        "default_headers": {
            **client_params["default_headers"],
            "X-Three-Api-Key": three_dev_key,
            "X-Three-Use-Case": "support-assistant",
            "X-Three-AI-Provider": "anthropic",
        },
    }
    proxy = llm.anthropic_proxy
    llm._client = anthropic.Anthropic(
        **three_dev_params, http_client=anthropic.DefaultHttpxClient(proxy=proxy)
    )
    llm._async_client = anthropic.AsyncAnthropic(
        **three_dev_params, http_client=anthropic.DefaultAsyncHttpxClient(proxy=proxy)
    )
```

```python
from google.genai import Client
from google.genai.types import HttpOptions

llm = ChatGoogleGenerativeAI(model="gemini-3-flash-preview")
three_dev_key = os.environ.get("THREE_DEV_API_KEY")
if three_dev_key and not llm.client.vertexai:
    llm.client = Client(
        api_key=llm.google_api_key.get_secret_value(),
        http_options=HttpOptions(
            base_url="https://gate.three.dev",
            api_version=llm.api_version,
            headers={
                **(llm.additional_headers or {}),
                "X-Three-Api-Key": three_dev_key,
                "X-Three-Use-Case": "support-assistant",
                "X-Three-AI-Provider": "gemini",
            },
            client_args=llm.client_args,
            async_client_args=llm.client_args,
        ),
    )
```

## By kind of app

For a provider with a fixed address, the client's URL is `gate.three.dev`
with the path of the SDK's own default address: `https://gate.three.dev/v1`
for a client whose default is `https://api.openai.com/v1`, or
`https://api.anthropic.com/v1` as in the Vercel AI SDK's Anthropic provider;
`https://gate.three.dev` for the Anthropic SDK, whose default has no path. The
page's example for the exact client shows it.

| The code has | The client's URL becomes | Headers beyond the three above | Ask the user |
| --- | --- | --- | --- |
| OpenAI: `OpenAI()` or `https://api.openai.com/v1` | `https://gate.three.dev/v1` | none | nothing |
| OpenAI with EU data residency: `https://eu.api.openai.com/v1` | `https://gate.three.dev/v1` | `X-Three-AI-Provider-BaseURL: https://eu.api.openai.com/v1` | nothing |
| Anthropic SDK or LangChain's `ChatAnthropic`: `Anthropic()`, `ChatAnthropic()` | `https://gate.three.dev` | none | nothing |
| Google's GenAI SDK: `genai.Client()`, `new GoogleGenAI()`, `genai.NewClient(...)` | `https://gate.three.dev`, with no API version: the SDK adds it, and the app's `api_version` stays | none | nothing |
| Vercel AI SDK's Anthropic provider: `createAnthropic()` or `anthropic` | `https://gate.three.dev/v1` | none | nothing |
| Gemini through its OpenAI-compatible URL | `https://gate.three.dev/v1beta/openai` | none | nothing |
| OpenRouter: `https://openrouter.ai/api/v1` | `https://gate.three.dev/v1` | none | nothing |
| Concentrate: `https://api.concentrate.ai`, with any path | `https://gate.three.dev`, with the same path | none | nothing |
| Azure OpenAI with an OpenAI client: `base_url="https://my-resource.openai.azure.com/openai/v1"` | `https://gate.three.dev/v1` | `X-Three-AI-Provider-BaseURL: https://my-resource.openai.azure.com/openai/v1` | to approve the address |
| Azure OpenAI with the `AzureOpenAI` classes or LangChain's `AzureChatOpenAI`: `azure_endpoint="https://my-resource.openai.azure.com"` | `azure_endpoint="https://gate.three.dev"`, nothing else changed; in LangChain.js, `azureOpenAIBasePath: "https://gate.three.dev/openai/deployments"`, which comes before an endpoint or instance name and before `AZURE_OPENAI_BASE_PATH` | `X-Three-AI-Provider-BaseURL: https://my-resource.openai.azure.com` | to approve the address |
| Azure OpenAI with the Vercel AI SDK: `createAzure({ resourceName: "my-resource" })` | `baseURL: "https://gate.three.dev/v1"`, nothing else changed | `X-Three-AI-Provider-BaseURL: https://my-resource.openai.azure.com/openai`, or the app's `baseURL` as it is | to approve the address |
| The same with `useDeploymentBasedUrls: true` | `baseURL: "https://gate.three.dev/openai"`, nothing else changed | As above | to approve the address |
| Bedrock with a Bedrock API key: `https://bedrock-runtime.<region>.amazonaws.com/...` | `https://gate.three.dev/...`, same path | `X-Three-AI-Provider-BaseURL: https://bedrock-runtime.<region>.amazonaws.com` | to approve the address |
| A company gateway, or another host that speaks a provider's API (Groq, DeepSeek, Mistral): `base_url="https://llm.example.com/v1"` | unchanged | none | nothing; not connected, as [provider-address.md](provider-address.md#the-providers-address) says |
| A client that already calls `gate.three.dev` | unchanged | none | nothing |

The `X-Three-AI-Provider` value for each is on the provider page; with an
address header, it is the provider whose host the header names
(`azure_openai` for an OpenAI client on Azure).

OpenRouter needs no address header, and its client path is `/v1`, not
`/api/v1`: the proxy adds `/api` itself.

Concentrate is a provider three.dev knows, wired by its fixed address: its
`X-Three-AI-Provider` is `concentrate` whichever SDK calls it, the Anthropic
SDK included, and it needs no address header and no question.

**Google's GenAI SDKs.** The app's Gemini key stays the SDK's key, sent as
`x-goog-api-key`. The base URL and the `X-Three-*` headers are added to the
client's own HTTP options (`http_options` in Python, `httpOptions` in
TypeScript, `HTTPOptions` in Go), keeping its API version, timeout, and
retries; per-call headers go in the call's config, under the same test as
[per-call headers](#every-wired-client).

- Vertex AI mode (`vertexai=True`, `vertexai: true`, `genai.BackendVertexAI`,
  or the `GOOGLE_GENAI_USE_VERTEXAI` or `GOOGLE_GENAI_USE_ENTERPRISE`
  variable) cannot go through the proxy. When the code sets it, leave the
  client unchanged. When a variable can set it, the code decides per run:
  build the client as before, and wire it only when it is not in Vertex AI
  mode (`client.vertexai` in Python, when the installed SDK has it). Never
  pin Go's `Backend` to `genai.BackendGeminiAPI` as the page does: a
  deployment that runs on Vertex AI would break.
- A client the app also uses for the Live API (`client.aio.live`,
  `ai.live`) stays unchanged: its WebSocket follows the base URL to the
  proxy and fails. Step 6 gets "Not connected: `<file>`, the same client
  opens Gemini Live sessions, which cannot go through three.dev."
- The SDK's replay recording (`GOOGLE_GENAI_CLIENT_MODE`) writes request
  headers to files. When the repository uses it, the three.dev branch also
  requires that variable to be unset.

```python
from google import genai
from google.genai import types

client = genai.Client()
three_dev_key = os.environ.get("THREE_DEV_API_KEY")
if three_dev_key and not client.vertexai:
    client = genai.Client(
        http_options=types.HttpOptions(
            base_url="https://gate.three.dev",
            headers={
                "X-Three-Api-Key": three_dev_key,
                "X-Three-Use-Case": "support-assistant",
                "X-Three-AI-Provider": "gemini",
            },
        ),
    )
```

The deprecated `google-generativeai` SDK uses gRPC by default, and
`genai.configure` sets it up for the whole process. When every call through
it, anywhere in the app, is synchronous, take the page's REST form in the
three.dev branch: `genai.configure` with `transport="rest"`,
`client_options={"api_endpoint": "https://gate.three.dev"}`, the app's key as
before, and the `X-Three-*` headers as lowercase `default_metadata` tuples.
Step 6 gets "`<file>` uses the deprecated `google-generativeai` SDK; with
three.dev it talks to Gemini over REST instead of gRPC." When the app makes
any async call through it (`generate_content_async`, an async chat), leave it
unchanged, since those calls fail over REST, with "Not connected: `<file>`,
the deprecated `google-generativeai` SDK cannot send its async calls through
three.dev; moving to `google-genai` would."

An older `@ai-sdk/azure` may still build Azure's path on the proxy's host. If
the check request answers that the path does not exist, put that call site
back as it was and report it as not connected.

Leave these unchanged and report them as not connected:

- a client the provider page lists as unsupported, or has no example for
  and [library-wiring.md](library-wiring.md) could not wire;
- an AWS client signed with access keys (`boto3`, the Converse API), and
  Bedrock Mantle;
- a Vercel AI SDK model given as a plain string (`model: "openai/gpt-5"`) or
  through `gateway(...)` from `ai` or `@ai-sdk/gateway`: those calls go to
  Vercel's AI Gateway, which the page does not cover;
- Google's SDKs set to Vertex AI mode in the code, and Gemini's Live API
  (`client.aio.live`, `ai.live`), which uses WebSockets.
