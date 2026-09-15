---
name: three-dev
description: Adds three.dev to a codebase so its LLM calls are recorded. Finds every LLM call site, groups the calls into use cases, and routes them through the three.dev proxy (gate.three.dev) with use case, session, and environment headers. Use when the user mentions three.dev, gate.three.dev, or X-Three headers, asks to record or monitor their LLM calls, or wants to set up or extend a three.dev integration. Covers OpenAI, Anthropic, Gemini, Azure OpenAI, OpenRouter, Bedrock, and LiteLLM clients. Read the docs before writing code; never guess header values or base URLs. Not for investigating failure modes or reading recorded conversations; that is the three-dev-failure-modes skill. Not for running or reading experiments; that is the three-dev-experiments skill. Not for defining or reporting quality metrics; that is the three-dev-quality-metrics skill.
---

# three.dev integration

three.dev records every LLM call that passes through its proxy at
`gate.three.dev`. This skill gets a codebase's traffic flowing: it finds the LLM
calls, groups them into use cases, and wires each call site with a base URL, an
auth header, and a few `X-Three-*` headers. Nothing else changes.

No three.dev key is needed during the session. A use case is created the first
time a request arrives under its slug, so the code only has to send the right
headers. The user's provider key (OpenAI, Anthropic, ...) moves to the three.dev
dashboard, which injects it server-side.

Once traffic flows, reading it belongs to another skill: why a feature fails is
the `three-dev-failure-modes` skill; testing a change on recorded traffic is the
`three-dev-experiments` skill. With no access to the user's code, point them at
https://docs.three.dev/getting-started/quickstart-record-requests.md instead.

## Where the facts are

The three.dev docs are the source of truth. If anything in this skill disagrees
with them, they win.

Read the live page when you can, in this order of preference:

1. The three.dev MCP server, if connected: `search_docs` to find a page,
   `read_doc` to read it in full.
2. A fetch tool that returns the file verbatim: every docs page is served as
   Markdown at `<page URL>.md`. The index is https://docs.three.dev/llms.txt.
3. The copies under `references/`, synced from those pages. Use them when you
   cannot fetch. They may lag the live docs.

Never work from a summary of a page. A summariser drops the exact base URL
path, the placeholder in a constructor, and the table of unsupported clients,
and the code you write from it fails silently.

| Need | Live page | Local copy |
| --- | --- | --- |
| Base URL, auth header, use-case header, how use cases get created | https://docs.three.dev/sending-requests/sending-requests.md | [references/sending-requests.md](references/sending-requests.md) |
| Per-provider and per-language wiring, accepted `X-Three-AI-Provider` values, unsupported clients | https://docs.three.dev/sending-requests/ai-providers-integration.md | [references/ai-providers-integration.md](references/ai-providers-integration.md) |
| Session and tag headers, which API paths get full observability | https://docs.three.dev/sending-requests/supported-paths.md | [references/supported-paths.md](references/supported-paths.md) |
| How to split use cases, what a session is, which tags | https://docs.three.dev/getting-started/planning-your-integration.md | [references/planning-your-integration.md](references/planning-your-integration.md) |
| Choosing session IDs and tag values in code | none | [references/sessions-and-tags.md](references/sessions-and-tags.md) |

## Ground rules

- **Decide, don't ask.** Apply the recommended option from the docs and this
  skill for use cases, session IDs, tags, and how the key is read. Never offer
  the user a menu. Stop only when the code gives no safe answer: no LLM calls
  found, or no worked example for the exact client.
- **Be brief.** No preamble, no narration, no repeating fetched docs, no diffs
  in chat. The only message the user needs is the one in Step 6.
- **Secrets never touch the chat or the repo.** Never ask the user to paste a
  key. Never hardcode, print, echo, or commit one.
- **Keep the SDK and API surface the user already has.** The proxy is a
  passthrough. Never migrate between SDKs or API surfaces to suit the proxy.
- **Never guess the wiring.** If the provider page has no worked example for
  the exact client in the code, leave that call site unchanged and report it.
  Do not infer a base URL, an auth header, or how an SDK merges per-request
  headers from a different SDK. A wrong guess forwards the request and records
  nothing, silently.
- **Minimal diff.** Base URL, auth header, `X-Three-*` headers, and the key
  variable. No refactors, no reformatting, no new dependencies. Match the
  existing style.

## Workflow

### Step 1: Understand the product and find the LLM calls

Read the README, the domain models, and the configuration first: what the
product does, who uses it, and how the business segments it (plans, markets,
channels, customer types). Steps 2 and 3 depend on it.

Scan for every LLM call site: `openai`, `anthropic`, `@anthropic-ai/sdk`,
`@google/genai`, `google.generativeai`, `litellm`, `langchain`, the Vercel `ai`
SDK, agent frameworks built on those SDKs, `bedrock-runtime` and `boto3`
clients, and raw HTTP to `api.openai.com`, `api.anthropic.com`,
`generativelanguage.googleapis.com`, Azure OpenAI endpoints, or an existing
gateway.

- Calls that already go through `gate.three.dev` keep their slug; extend the
  integration around them.
- Clients the provider page lists as unsupported stay as they are and are
  reported as skipped.
- If there are no LLM calls, say so and ask where they are.

### Step 2: Group the calls into use cases

A use case is one AI feature with one goal: the thing the user would want to
know is working or failing. Read the "How many use cases" section of
[references/planning-your-integration.md](references/planning-your-integration.md),
then decide:

- **Same use case** when a change to one prompt can change another's output:
  a classifier feeding a responder, retrieval feeding generation, agents
  handing off within one conversation, a multi-step pipeline. This holds
  across files and services.
- **Separate use cases** when features share no prompt or input and would be
  tuned independently.
- **The judge test.** Everything downstream is scoped per use case, including
  its one active AI Judge. If one set of pass/fail criteria could not judge
  every final output in the group, split it.
- **Never split by segment or environment.** Product line, tenant, plan tier,
  channel, locale, and environment are tags.
- **When unsure, fewer.** Adding a tag later is one line; splitting a use case
  later leaves its history, judge, and experiments behind.

Slugs name the feature, not the file, model, or provider, and are constant in
code. Never build a slug from a runtime value such as a user, tenant, or
session ID. Do not ask the user to confirm the grouping.

### Step 3: Wire the code

1. **Route each call site through the proxy** following the example for that
   provider and language on the AI Providers Integration page. Send
   `X-Three-Use-Case` and `X-Three-AI-Provider` in client defaults.
2. **Read the key like the provider key.** Read `THREE_DEV_API_KEY` through
   the same mechanism the code already uses for the provider key, usually an
   environment variable. Never add a loader, a dependency, or a new config
   layer to read it. If the repo has an env template (`.env.example`,
   `.env.sample`, or similar), add `THREE_DEV_API_KEY=` to it. If the repo
   documents a local secrets file, make sure git ignores it. Leave the old
   provider-key variables in place.
3. **Tags and session IDs.** Apply [references/sessions-and-tags.md](references/sessions-and-tags.md):
   a session ID on every call, and every tag that segments the traffic the way
   the business compares it.
4. Do not change models, prompts, parameters, or behaviour.

Do not commit unless the user asked you to.

### Step 4: Continue with quality metrics

Load the `three-dev-quality-metrics` skill, follow it, then come back here. It
wires reports only for outcomes that are clear and adds nothing otherwise.
Metrics never add a question or a line to the message in Step 6.

### Step 5: Verify

The change must build and behave exactly as before, apart from where the calls
go. No three.dev key exists yet, so verify without calling the proxy.

1. **Run the repo's own checks.** Type check, compile or build, lint, and the
   existing tests, using the commands the repo documents. If dependencies are
   missing, install them only through the repo's documented setup into its own
   environment: never globally, never a new package.
2. **Review the diff against this list:**
   - Every LLM call path goes through the proxy: streaming, retries,
     fallbacks, background jobs, sync and async clients. No direct provider
     call is left and none is made twice.
   - `X-Three-Use-Case` and `X-Three-AI-Provider` are on every client, and
     every per-call session header passed the merge check from Step 3.
   - An unset `THREE_DEV_API_KEY` fails the way an unset provider key did
     before. Nothing crashes at import, and every test that passed before
     still passes.
   - Models, prompts, parameters, timeouts, and error handling are unchanged.
   - No key is logged, printed, hardcoded, or committed.
   - A tag whose value can be missing sends no header rather than an empty or
     `None` value, and no tag carries personal data.
   - Every metric report is non-blocking, sends the session ID of its LLM
     calls, and carries `optimize_for`.
3. **Verify every instruction Step 6 will give:**
   - **Which process calls the LLM.** Trace it from the call sites: a
     backend, a worker, a CLI, not the frontend that talks to it.
   - **How to start it.** Take the command from the repo (README, package
     scripts, Makefile, Procfile, compose file), run it from the directory you
     will name, and see that process boot. When using the app needs more than
     one process (a backend and a frontend), check each command.
   - **Where that process reads the key.** Follow `THREE_DEV_API_KEY` from the
     place Step 6 will name to the running process. A containerized or
     process-managed app does not see a shell `export` unless its
     configuration passes the variable through; name the file or setting it
     actually reads.
   - **Which providers.** Only providers the wired call sites use.
4. **Fix what fails and repeat** until the checks, the list, and the
   instructions are clean.

### Step 6: Tell the user how to start sending traffic

Send this message, filled in, and nothing else. No summary of the changes, no
files, no test or verification status, no caveats, no defaults explained, and
no word on how the skill or plugin was loaded. Every command, directory, file,
and provider in it was verified in Step 5.

> three.dev is set up for `<slug>`. To start sending traffic:
>
> 1. Create a three.dev API key: https://app.three.dev/goto/api-keys
> 2. <One exact action that puts the key where the code reads it.>
> 3. Add your <provider> API key in three.dev: https://app.three.dev/goto/ai-provider-keys
> 4. Start <the process> with `<verified command>` from `<directory>`, and use the app. Requests appear in three.dev.

Step 2 is a single copyable action, the one Step 5 traced to the process: "Add
`THREE_DEV_API_KEY=<your key>` to `<path>`" when it reads a file, or "Run
`export THREE_DEV_API_KEY=<your key>` in the terminal where you run step 4"
when it reads a plain environment variable from that shell. When the location
could not be confirmed, step 2 is "Set `THREE_DEV_API_KEY=<your key>` in the
environment of the process that calls <provider>."

List every use case slug in the first line and every provider in step 3. Step
4 names each process the app needs, one clause per verified command; omit
"from `<directory>`" when it is the repository root. When no command could be
verified, step 4 is "Start the app and use it."

Add one line after the list only when it applies:

- A call site left unchanged: "Not connected: `<file>`, <reason in a few words>."
- A check from Step 5 that could not run: "Not verified: <what, and why in a few words>."
- The three.dev MCP server is not connected: "To investigate failures and run
  experiments, connect the three.dev MCP server and sign in."

## Hard rules

- `X-Three-Use-Case` and `X-Three-AI-Provider` go on every request. The
  accepted provider values are on the AI Providers Integration page; do not
  invent them.
- Slugs match `^[a-z0-9]+(?:-[a-z0-9]+)*$` and are at most 64 characters.
- Per-request headers must merge with client defaults, not replace them. A
  dropped session header takes the use-case header with it and the request is
  forwarded but never recorded.
- An organization records at most 20 use cases created from a first request.
  Beyond that, new slugs are forwarded but not recorded.
- SigV4-signed AWS clients cannot be proxied.
