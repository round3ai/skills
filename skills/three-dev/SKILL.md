---
name: three-dev
description: Integrate three.dev into a codebase or extend an existing integration. three.dev is an LLM proxy (gate.three.dev) that records every LLM call for observability and runs experiments on models, prompts, and parameters against quality metrics. Use when the user mentions three.dev, gate.three.dev, or X-Three headers, or asks to record or monitor their LLM calls, or to add use cases, sessions, tags, or quality metrics to LLM code. Covers discovery of call sites, use case and metric design, wiring OpenAI, Anthropic, Gemini, Azure OpenAI, OpenRouter, Bedrock, or LiteLLM clients through the proxy, session IDs, tags, and metric reporting. Read the docs before writing code; never guess header values or base URLs. Not for investigating failure modes or reading recorded conversations; that is the three-dev-failure-modes skill. Not for running or reading experiments; that is the three-dev-experiments skill.
---

# three.dev integration

three.dev records LLM calls that pass through its proxy at `gate.three.dev` and
lets the user run experiments on models, prompts, and parameters against quality
metrics. An integration is three edits per call site: the base URL, the auth
header, and a small set of `X-Three-*` headers. Metric reporting is one REST call.

The user's provider key (OpenAI, Anthropic, ...) is stored in the three.dev
dashboard and injected server-side. It leaves the codebase.

This skill gets traffic recorded and metrics reported. Everything that reads the
recorded traffic starts once requests are flowing, and belongs to another skill:
why the feature is failing, or what the conversations show, is the
`three-dev-failure-modes` skill; testing a model, prompt, or reasoning change on
recorded traffic, or reading an experiment's results, is the
`three-dev-experiments` skill. Finish the integration first. A live experiment
on real users is set up in the dashboard,
https://docs.three.dev/getting-started/quickstart-run-live-experiment.md, and
only needs from this skill the metrics and session IDs it measures.

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
| Base URL, auth header, use-case header | https://docs.three.dev/sending-requests/sending-requests.md | [references/sending-requests.md](references/sending-requests.md) |
| Per-provider and per-language wiring, accepted `X-Three-AI-Provider` values, unsupported clients | https://docs.three.dev/sending-requests/ai-providers-integration.md | [references/ai-providers-integration.md](references/ai-providers-integration.md) |
| Sessions, tags, which API paths get full observability | https://docs.three.dev/sending-requests/supported-paths.md | [references/supported-paths.md](references/supported-paths.md) |
| Report a metric outcome | https://docs.three.dev/api-reference/report-metric.md | [references/report-metric.md](references/report-metric.md) |
| How many use cases, what a session is, which tags | https://docs.three.dev/getting-started/planning-your-integration.md | [references/planning-your-integration.md](references/planning-your-integration.md) |
| Use-case and quality-metric endpoints (no docs page yet) | none | [references/control-plane-api.md](references/control-plane-api.md) |

## Ground rules

- **The user approves, you do.** At each checkpoint present options as a
  numbered list with your recommendation marked and justified in one line, then
  stop and wait. One question at a time. Use a structured question tool if one
  exists.
- **Be brief.** No preamble, no narration, no repeating fetched docs. Findings
  go in the tables below. Never paste a diff or a code block the user did not
  ask for; name the file and describe the change in one line.
- **Secrets never touch the chat or the repo.** Never ask the user to paste a
  key. Never hardcode, print, echo, or commit one. Keys live in the repo's
  existing local-secrets mechanism.
- **Keep the SDK and API surface the user already has.** The proxy is a
  passthrough. Never migrate between SDKs or API surfaces to suit the proxy.
  If a different surface would record richer detail, present it as a tradeoff
  and let the user decide.
- **Never guess the wiring.** If the provider page has no worked example for
  the exact client in the code, stop and say which page you checked and what
  is missing. Do not infer a base URL, an auth header, or how an SDK merges
  per-request headers from a different SDK. A wrong guess forwards the request
  and records nothing, silently.
- **Minimal diff.** Base URL, auth header, `X-Three-*` headers, metric reports.
  No refactors, no reformatting. Match the existing style.
- **Never break the app.** Every call to the three.dev REST API is non-blocking
  and wrapped so a failure cannot take down a user-facing flow.

## Workflow

### Step 0: Prerequisites

Confirm as one checklist, with these links: a three.dev account
(https://app.three.dev), provider keys added under AI Provider Keys
(https://app.three.dev/goto/ai-provider-keys), a three.dev API key created under
API Keys (https://app.three.dev/goto/api-keys; shown once).

Do not ask for the key. Find where the repo keeps local secrets (`.env`,
`.env.local`, `.envrc`, a secrets manager) and tell the user the exact file and
line: `THREE_DEV_API_KEY=<paste your key here>`. First check git ignores that
file; if it does not, fix `.gitignore` before the user adds anything, and say
that a previously committed key must be rotated. Add an empty
`THREE_DEV_API_KEY=` to `.env.example`. If the repo has no local-secret pattern,
ask; do not invent one.

Once the key is in place, validate it with one command that loads the
environment without printing it: `GET https://api.three.dev/api/v1/use-cases`
with the bearer header (see [references/control-plane-api.md](references/control-plane-api.md)).
`200` means proceed; keep the response, Step 1 and Step 3 need the existing
use cases. `401` or an empty variable means help the user fix it first.

### Step 1: Discover use cases

Scan for every LLM call site: `openai`, `anthropic`, `@anthropic-ai/sdk`,
`@google/genai`, `google.generativeai`, `litellm`, `langchain`, the Vercel `ai`
SDK, `bedrock-runtime` and `boto3` clients, and raw HTTP to `api.openai.com`,
`api.anthropic.com`, `generativelanguage.googleapis.com`, Azure OpenAI
endpoints, or an existing gateway.

Group by product feature, one feature = one use case, and present:

| # | Proposed use case | Proposed slug | Provider | Model(s) | Call sites |

Rules:

- Prompts that feed each other are one use case, even across files or services.
- Never one use case per segment, tenant, tier, or environment. Those are tags.
- Reuse an existing slug from Step 0 rather than creating a duplicate; flag it.
- List unsupported providers anyway, marked as skipped.
- If there are no LLM calls, say so and ask where they are.
- Recommend where to start, ask the user to pick by number, stop and wait.

### Step 2: Recommend quality metrics

For each selected use case, find the real business outcome after the LLM
responds: an order or booking created, a document accepted, a suggestion
applied, a click-through, an escalation, a retry, an abandonment. Present:

| # | Use case | Proposed metric | Slug | optimize_for | Reported where (file:line) |

Rules:

- Every metric is a binary session-level outcome the code can observe and
  report from a specific place. Metrics that need product changes go in a
  separate "possible later" list.
- Capture a full funnel as one metric per stage, each with its own
  `optimize_for` and a one-line reason. `max` means true is good; `min` means
  true is bad.
- A use case with no observable outcome goes in the table as "none, recording
  only".
- Recommend, ask the user to pick by number, stop and wait.

### Step 3: Create everything in three.dev

Show the exact list, then on approval create use cases and metrics through the
REST API (see [references/control-plane-api.md](references/control-plane-api.md)).
Re-fetch both lists immediately before creating and skip what exists. Report one
line per item: slug, created or skipped. On 401 or 403, fall back to dashboard
instructions (Use Cases → New, Metrics → New) and continue once confirmed.

The proxy also creates a use case on the first request under a new slug, so
nothing is blocked if this step is skipped. Creating here gives each a
human-readable name and a place for metrics to attach.

### Step 4: Instrument the code

Leave every git decision to Step 6.

1. **Route each call site through the proxy** following the example for that
   provider and language on the AI Providers Integration page. Read the key
   from `THREE_DEV_API_KEY` through the codebase's existing config pattern. If
   the config layer fails fast on missing variables, say so: from now on CI and
   every developer need the variable set.
2. **Session IDs.** Read [references/sessions-and-tags.md](references/sessions-and-tags.md).
   Pass the natural identifier for one user interaction as `X-Three-Session-ID`
   on every call in that interaction; generate a UUID if none exists. Every
   session must end. Verify that the pinned SDK version supports per-request
   headers and merges them with client defaults; if you cannot verify, say so.
3. **Metric reporting.** Read [references/metric-reporting.md](references/metric-reporting.md)
   and the Report Metric page. Report at each outcome point with the same
   session ID, deferred past the five-second window, non-blocking, failures
   logged and swallowed, never silently dropped.
4. **Tags.** Always send `X-Three-Tag-Environment` from the existing
   environment setting. Propose other tags only for dimensions the code
   already tracks. Ask before adding them.
5. Do not change models, prompts, parameters, or behaviour. Leave the old
   provider-key variables in place.

Then stop for review. One line per file: path, what changed, why.

### Step 5: Verify

Offer to send one minimal request through the user's own code path, noting it
costs a fraction of a cent, and wait for approval. Success is HTTP 200 with an
`x-three-request-id` response header; then point the user at the dashboard
Requests page. With the MCP server connected, `list_requests` with `limit=0`
for the use case counts the request once it is recorded.

On failure: 401 is the key, 404 or a proxy error is the base URL path, a
request missing from the dashboard is the use-case header (absent, or a slug
that is not lowercase alphanumeric with single hyphens).

Once traffic flows, investigation moves to the `three-dev-failure-modes` skill
and experiments to the `three-dev-experiments` skill.

### Step 6: Wrap up

Ship the change the way the user normally does in this repo; ask if unclear.
Never commit a secret. Report, one line each: use cases and slugs instrumented,
metrics created with where each is reported and its direction, tags added.
If the three.dev MCP server is not connected, end by telling the user to connect
it and sign in, restarting the agent if their client needs that; both skills
named in Step 5 depend on it.

## Hard rules

- `X-Three-Use-Case` and `X-Three-AI-Provider` go on every request. The
  accepted provider values are on the AI Providers Integration page; do not
  invent them.
- Slugs match `^[a-z0-9]+(?:-[a-z0-9]+)*$`.
- Per-request headers must merge with client defaults, not replace them. A
  dropped session header takes the use-case header with it and the request is
  forwarded but never recorded.
- The quality-metrics list includes `is_system: true` entries. Never treat one
  as a metric you created.
- A use case that does not exist yet returns 404 from the metrics endpoint.
  That means "no metrics", not an error.
- SigV4-signed AWS clients cannot be proxied. Check the provider page for the
  current list of unsupported clients and report them as skipped.
