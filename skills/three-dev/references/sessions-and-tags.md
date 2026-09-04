# Sessions and tags

Header names, path coverage, and examples are on the Supported paths page
([live](https://docs.three.dev/sending-requests/supported-paths.md),
[local copy](supported-paths.md)). This file holds the rules for choosing
values in a codebase.

## Session ID

- Find the natural identifier for one user interaction: a conversation ID, a
  request ID, a job ID. Pass it as `X-Three-Session-ID` on every LLM call in
  that interaction.
- If none exists, generate a UUID at the start of the interaction and thread
  it through.
- One-shot and batch call sites (cron jobs, pipelines) get a fresh UUID per
  call. Each call is its own single-request session.
- Every session must end. Never use a durable identity (user ID, account ID,
  character ID) as the session ID. If a conversation can run indefinitely,
  propose a rollover rule (an inactivity window or a topic reset) for the
  user's approval.
- Store the session ID on whatever record the call produces, so a later
  outcome (a save, a click, an approval) can be reported against it.
- Never derive the session ID from business identifiers that can repeat.

## Where headers go

- Headers that never change per request (use case, provider) go in client
  defaults.
- The session ID goes in per-call options.
- Check that the pinned SDK version supports per-request extra headers and
  that they merge with the client defaults rather than replacing them. If you
  cannot check (nothing installed, no version pinned), say so and flag it as
  unverified. A session ID that silently drops takes the use-case header with
  it, and the request is then forwarded but never recorded.

## Tags

- `X-Three-Tag-<Key>: <value>` tags a single request.
- `X-Three-Session-Tag-<Key>: <value>` tags the whole session and is sent
  alongside `X-Three-Session-ID`.
- Both prefixes are stripped by the proxy and never reach the AI provider.
- Always include `X-Three-Tag-Environment: <value>`, lowercase, read from the
  codebase's existing environment setting (`NODE_ENV`, `APP_ENV`, `RAILS_ENV`,
  or equivalent). If there is none, ask.
- Only tag dimensions the code already tracks: environment, plan tier,
  tenant, channel, prompt version. Do not invent dimensions or add tracking.
- Segments, tenants, tiers, and environments are tags, never separate use
  cases.
- Propose tags for approval before adding them.
