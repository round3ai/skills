# Sessions and tags

Header names, path coverage, and examples are on the Supported paths page
([live](https://docs.three.dev/sending-requests/supported-paths.md),
[local copy](supported-paths.md)). This file holds the rules for choosing
values in a codebase. Apply them without asking the user.

## Session ID

- Find the natural identifier for one user interaction: a conversation ID, a
  run ID, a job ID. Pass it as `X-Three-Session-ID` on every LLM call in that
  interaction.
- If none exists, generate a UUID at the start of the interaction and thread
  it through.
- One-shot and batch call sites (a summary, a classification, a cron job) get
  a fresh UUID per call. Each call is its own single-request session.
- Every session must end. Never use a durable identity (user ID, account ID,
  character ID) as the session ID. If a conversation can run indefinitely,
  start a new session ID after 30 minutes without a message.
- Never derive the session ID from business identifiers that can repeat.

## Where headers go

- Headers that never change per request (use case, provider) go in client
  defaults.
- The session ID goes in per-call options.
- Check that the pinned SDK version supports per-request extra headers and
  that they merge with the client defaults rather than replacing them. If you
  cannot check (nothing installed, no version pinned), leave the session
  header out of that call site and report it.

## Tags

- `X-Three-Tag-<Key>: <value>` tags a single request.
- `X-Three-Session-Tag-<Key>: <value>` tags the whole session and is sent
  alongside `X-Three-Session-ID`.
- Both prefixes are stripped by the proxy and never reach the AI provider.
- Always send `X-Three-Tag-Environment`, lowercase, read from the codebase's
  existing environment setting (`NODE_ENV`, `APP_ENV`, `RAILS_ENV`, or
  equivalent), with `production` for production traffic. If there is none,
  read it from a `THREE_DEV_ENVIRONMENT` variable that defaults to `local`,
  and add that variable to the env template next to `THREE_DEV_API_KEY`.
- Add a segment tag (plan tier, tenant, channel) only when the call site
  already has the value. Do not invent dimensions or add tracking.
