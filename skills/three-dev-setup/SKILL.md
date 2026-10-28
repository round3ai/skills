---
name: three-dev-setup
description: Adds three.dev to a codebase so its LLM calls are recorded. Connects the app to the user's three.dev organization with one approval in the browser, finds every LLM call site, groups the calls into use cases, and routes them through the three.dev proxy (gate.three.dev) with the app's own provider key plus use case, session, and environment headers. Use when the user mentions three.dev, gate.three.dev, or X-Three headers, asks to record or monitor their LLM calls, or wants to set up, connect, or extend a three.dev integration. Covers OpenAI, Anthropic, Gemini, Azure OpenAI, OpenRouter, Concentrate, Bedrock, LiteLLM, Vercel AI SDK, and LangChain and LangGraph clients. Not for investigating failure modes or reading recorded conversations; that is the three-dev-failure-modes skill.
allowed-tools: Bash(curl -sS -X POST https://api.three.dev/api/v1/setup/status *)
---

# three.dev integration

three.dev records every LLM call that passes through its proxy at
`gate.three.dev`. This skill connects the app to the user's three.dev
organization, finds the LLM calls, groups them into use cases, and wires each
call site with a base URL and a few `X-Three-*` headers. Nothing else changes.

The three.dev key arrives during the session: the user approves once in the
browser and the key goes straight into the app's env file, never through this
conversation. The provider key stays where the app has it, forwarded untouched.

This skill needs a shell and the repository. Without them, say setup runs from
a coding agent in the app's repository:
https://docs.three.dev/getting-started/quickstart-record-requests.md

## Where the facts are

Read the live docs page when you can: `search_docs` and `read_doc` on the
three.dev MCP server, else a fetch tool returning `<page URL>.md` verbatim
(index: https://docs.three.dev/llms.txt), else the copy under `references/`,
which may lag. Read the sections for the code's clients, never a summary.

The docs win except on where keys and the provider's address go, which
wiring.md and provider-address.md decide, with how to read them.

| Need | Live page | Local copy |
| --- | --- | --- |
| The connection: every command, its outcomes, the env file | none | [references/connect.md](references/connect.md) |
| Which key goes where; the provider's address; the diff review and the check call (together, the wiring files) | none | [references/wiring.md](references/wiring.md); [references/provider-address.md](references/provider-address.md); [references/check-request.md](references/check-request.md) |
| Wiring a client the docs have no example for | none | [references/library-wiring.md](references/library-wiring.md) |
| What each proxy error code means and how to fix it | none | [references/proxy-errors.md](references/proxy-errors.md) |
| Use-case header, how use cases get created | https://docs.three.dev/sending-requests/sending-requests.md | [references/sending-requests.md](references/sending-requests.md) |
| Base URL path per provider and SDK, accepted `X-Three-AI-Provider` values, unsupported clients | https://docs.three.dev/sending-requests/ai-providers-integration.md | [references/ai-providers-integration.md](references/ai-providers-integration.md) |
| Session and tag headers, which API paths get full observability | https://docs.three.dev/sending-requests/supported-paths.md | [references/supported-paths.md](references/supported-paths.md) |
| How to split use cases, what a session is, which tags | https://docs.three.dev/getting-started/planning-your-integration.md | [references/planning-your-integration.md](references/planning-your-integration.md) |
| Choosing session IDs and tag values in code | none | [references/sessions-and-tags.md](references/sessions-and-tags.md) |

## Ground rules

- **Decide, don't ask.** Use the recommended option for use cases, session
  IDs, tags, and the key; never offer a menu. Ask only for the browser
  approval and an Azure OpenAI or Bedrock address, and settle the rest by the
  repository's convention or the smallest change. One question at a time.
  That question is always asked, after a `decision_needed` report and before its
  check; no answer is a no. End no turn on another choice you could default.
- **Talk like a colleague.** What happened first, in plain words. No preamble,
  no narration, no repeated docs, no diffs in chat. The user sees only what you
  write, never a command's output. Say only what you saw: a value in a file you
  cannot open is unknown, so name its setting, never a template's value.
- **Secrets never touch the chat or the repo.** Never ask for, hardcode, print,
  echo, or commit a key, or open a file that may hold one (Step 1).
- **Commands run as printed.** Every command that names the env file or calls
  three.dev is copied from [references/connect.md](references/connect.md)
  character for character, one command at a time. If one is blocked or not
  approved, show the user the exact command and stop; never work around it.
- **Report how it ended.** Wire all you can first. The last command you run
  when your work stops, or finishes with a device code, is the report in
  connect.md, just before your message, which offers no further wiring.
- **Keep the SDK and API surface the user already has.** Never migrate between
  SDKs or API surfaces to suit the proxy; the app's own HTTPS mode is fine.
- **Never guess the wiring.** It comes from the page's worked example for the
  exact client or, with none, its installed library, kept only if proven.
- **Minimal diff.** Base URL, `X-Three-*` headers, and the key variable, in
  the code's style. No refactors, and no dependency but connect.md's loader.

## Workflow

### Step 1: Understand the product and find the LLM calls

Run the two listing commands in [files that may hold a key](references/wiring.md#files-that-may-hold-a-key)
first; until then open no repository file, a README included, and read only
names (`ls`). Then read the README, domain models, and configuration: what
the product does, who uses it, and how the business segments it (plans,
markets, channels, customer types). Steps 2 and 4 depend on it.

Scan for every LLM call site: `openai`, `anthropic`, `@anthropic-ai/sdk`,
`@google/genai`, `google.genai`, `google.generativeai`, `litellm`, `langchain`,
`@langchain/*`, `langgraph`, the Vercel `ai` SDK, agent frameworks, other
providers' SDKs, `bedrock-runtime` and `boto3` clients, the hosts
`openrouter.ai` and `api.concentrate.ai`, and raw HTTP to a provider, an
Azure OpenAI endpoint, or a gateway. Put each call site in one of five
groups; wiring.md and provider-address.md tell them apart:

- **Fixed address**: OpenAI, Anthropic, Gemini, OpenRouter, Concentrate.
- **Own address**: Azure OpenAI, Bedrock, OpenAI's EU host, or an address in a setting.
- **Already on three.dev**: it calls `gate.three.dev`. Keep it, and its slug.
- **No worked example**: none on the page. Wire it last, per library-wiring.md.
- **Unsupported**: a gateway, or ruled out by wiring.md or library-wiring.md. Not connected.

If there are no LLM calls, report `no_llm_calls`, say so, and ask where they are.

### Step 2: Group the calls into use cases

A use case is one AI feature with one goal: the thing the user would want to
know is working or failing. Read the "How many use cases" section of
[references/planning-your-integration.md](references/planning-your-integration.md),
then decide:

- **Same use case** when a change to one prompt can change another's output:
  a classifier feeding a responder, retrieval feeding generation, agents
  handing off within one conversation. This holds across files and services.
- **Separate use cases** when features share no prompt or input and would be
  tuned independently.
- **The criteria test.** Everything downstream is scoped per use case,
  including how its outputs are scored. If one set of pass/fail criteria could
  not score every final output in the group, split it.
- **Never split by segment or environment.** Product line, tenant, plan tier,
  channel, locale, and environment are tags.
- **When unsure, fewer.** Adding a tag later is one line; splitting a use case
  later leaves its history and scoring behind.

Slugs name the feature, not the file, model, or provider, and are constant in
code. Never build a slug from a runtime value.

### Step 3: Connect

Skip this step when every call site is already on three.dev. Otherwise follow
[references/connect.md](references/connect.md) for each command and outcome.

1. **Choose the env file** as connect.md says, which also decides whether to
   make the app load one, and make sure git ignores it before anything else.
2. **Start**, open the link, and end your turn on the link and the code, as
   connect.md prints them.
3. **Wait** for the decision once the user answers, with the status call
   every 5 seconds. Change no code until the key has landed.
4. **Collect** the key straight into the env file, once.

### Step 4: Wire the code

1. **Route each call site through the proxy** as the wiring files say
   for its group: the base URL from
   the provider page, the provider key left alone, and `X-Three-Api-Key`,
   `X-Three-Use-Case`, and `X-Three-AI-Provider` in client defaults.
2. **Read `THREE_DEV_API_KEY` like the provider key**, through the mechanism
   the code already uses, or its environment lookup when that reads a file
   the key cannot go in (YAML, TOML, a secrets file). Without the key, build
   every client exactly as before. No config layer, loader, or dependency but
   connect.md's loader; add `THREE_DEV_API_KEY=`, empty, to an env template.
3. **Tags and session IDs.** Apply
   [references/sessions-and-tags.md](references/sessions-and-tags.md): a
   session ID on every call, and every tag that segments the traffic the way
   the business compares it.
4. Do not change models, prompts, parameters, or behaviour. Do not commit
   unless the user asked you to.

### Step 5: Verify

1. **Run the repo's own checks.** Type check, build, lint, and the existing
   tests, with the commands the repo documents. Every command that runs the
   app's code uses the project's own interpreter or runner (its virtualenv's
   `python`, its pinned tool), never the system's; an import that prints
   nothing worked. Install only declared dependencies, the documented way.
2. **Review the diff** against check-request.md's "Before the check request".
3. **Send one check request** through the app's client code, as
   check-request.md says, with `X-Three-Traffic-Type: synthetic` on it only.
   A 2xx with three.dev's request ID, or a rise in `verified_checks`, proves
   it. Fix a three.dev error per [proxy-errors.md](references/proxy-errors.md),
   then resend; report a provider's own error with its status. When no check
   can be sent, check-request.md says what to tell the user and three.dev.
4. **Verify every instruction Step 6 will give**, per check-request.md's
   "Before Step 6".
5. **Fix what fails and repeat.** If the checks still fail, or the user
   rejects the changes, say so and stop. Undo only what the references say.

### Step 6: Tell the user how to start sending traffic

Run the report connect.md's step 12 has for this ending. Your message is this
template, filled in, plus only the lines listed below. Do not describe your
changes or your checks; the user reads the diff.

> three.dev is connected to organization `<name>` and your app's LLM calls now go through it.
>
> 1. Start `<the process>` with `<verified command>` from `<directory>`, and use the app. Requests appear in three.dev.
> 2. For production, add `THREE_DEV_API_KEY` to the environment your deployed app runs in: the value in `<env file>`, or a new key from https://app.three.dev/goto/api-keys
> 3. Restart `<your coding agent>` and sign in to the three.dev MCP server, or connect it first if your agent has none: https://github.com/round3ai/skills#readme

Item 1 names each process the app needs; omit "from `<directory>`" at the
repository root, and say "Start the app and use it" when no command could be
verified. Item 3 only when the three.dev MCP server is not connected here.
When the app does not load `<env file>` itself, item 1 is the one in
connect.md's "The env file".

Add one line after the list for each that applies; name things, never count:

- "Use cases: `<slug>`, `<slug>`.", every slug the wiring sends.
- "I chose `<choice>` (`<why, in a few words>`); say if you want another.", for
  each choice of yours that changed what got wired.
- "Not connected: `<file>`, `<reason in a few words>`."
- "Not verified: `<what, and why>`." When no check request succeeded, add "Your
  app's first request is the test: the setup page reads "`<title>`" until it
  arrives.", with the title connect.md gives.
- "Git is not protecting `<env file>` here: this folder is not a repository."
- "Added `<package>` and one line in `<file>` so your app reads `<env file>`."
- The wiring files' lines, and library-wiring.md's for clients wired from it.
  Before the report, check each Step 6 line here and in those files in turn,
  each `<slot>` filled with what this run found, never a generic word.
  Backticks stay only around names from the code (a file, a setting, a
  command, a slug); words like a reason or a provider go in plain text.

## Resume an interrupted setup

When asked to finish, resume, or fix a setup, do not start over: a new code
needs a new approval. Run the status call with this session's device code,
or by key without one, and follow its outcome. Do Step 4 for what is not
wired or is wrong, then Step 5; only a key proxy-errors.md calls gone or
revoked sends you back to Step 3. End with the report and Step 6.

## Hard rules

- The three.dev key never enters this conversation. Only connect.md's
  commands and the wiring files' check request, key check, counts, listings, and
  filtered reads name a file that may hold a key. Never print, `cat`, `head`,
  read, or open one; `source` only a file step 2 created, in connect.md's check
  command. Learn variable names from the code and the templates you may open.
  Never run `env`, `printenv`, `set`, `export -p`, `set -x`, or a command that
  prints resolved settings (`docker compose config`). Ask whether a key is set
  only as `[ -n "${NAME:+x}" ] && echo set || echo unset`, or by the key check.
- Every command that runs app code or the wiring ends with the filter and
  prints only what the wiring files list: never a client, its settings, header
  values, or the environment. Never edit an installed package for a check.
- Every code is shown: after each start call, your turn ends on its link and
  code, the second code too; no status call comes before it.
- Whole lines come only from `git grep -n <pattern> HEAD` through wiring.md's
  filter, a file wiring.md lets you open, or code you wrote. Any other search
  prints file names, counts, or the names it matched (`-l`, `-c`, or `-o`
  anchored at the line's start, stopping before the value), and so does any
  search outside a repository of a file that may hold a key.
- The token call runs only as connect.md prints it, with its output going to
  the env file. Any other form would print the key.
- The report carries only the parts connect.md prints, with values from its
  lists. Only its `detail` has your words: no key, name, path, or address.
- `X-Three-Traffic-Type` goes on the check request only, never in app code.
- `X-Three-AI-Provider-BaseURL` is an `https` base URL, uncut, from the code,
  its SDK's default host, or the user, on a host provider-address.md lists.
- The three.dev key goes in `X-Three-Api-Key`, never in a provider credential,
  and never where a library saves, logs, or traces it.
- `X-Three-Use-Case` and `X-Three-AI-Provider` go on every request, with a
  provider value from the AI Providers Integration page, never invented.
- Slugs match `^[a-z0-9]+(?:-[a-z0-9]+)*$`, at most 64 characters. At most
  20 per organization come from first requests; later new ones go unrecorded.
- Per-request headers merge with client defaults, never replace them: a
  request that loses its use-case header is forwarded but never recorded.
