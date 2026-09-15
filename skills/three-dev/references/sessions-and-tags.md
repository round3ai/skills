# Sessions and tags

Header names, path coverage, and examples are on the Supported paths page
([live](https://docs.three.dev/sending-requests/supported-paths.md),
[local copy](supported-paths.md)). This file holds the rules for choosing
values in a codebase. Apply them without asking the user.

## Session ID

Send `X-Three-Session-ID` on every LLM call. A session is one attempt at the
feature's goal:

| Feature shape | One session is | ID to use |
| --- | --- | --- |
| Chat | one conversation | the conversation or thread ID, on every turn |
| Agent run or multi-step pipeline | one run | the run or job ID, on every call of the run |
| One-shot generation (a summary, a classification, a cron job) | one request | a fresh UUID generated just before the call |
| An interaction with no ID in the code | the interaction | a UUID generated where it starts and passed down to each call |

- When the ID has to reach the call through other layers or services, pass it
  the way the code already passes request context: a parameter, a context
  object, a header between services. Do not add a new mechanism.
- Every session ends. Never use a durable identity (a user, account, tenant,
  or character ID): a customer who returns for ten chats is ten sessions. When
  the product has no explicit end, start a new session ID after 30 minutes
  without a message.
- Never build the ID from a business identifier that can repeat, such as a
  ticket ID with a suffix. Send those as tags.
- For one-shot calls, store the UUID with the record the call produces when
  the code already saves one, so a later outcome can refer to it.

## Where headers go

- The session ID goes in per-call options.
- Check the merge hard rule in the installed SDK's source. If the SDK is not
  installed, set it up as Step 4 allows and check then. Only if it still
  cannot be confirmed, leave the session header out of that call site.

## Tags

Tags are how the traffic of one use case gets segmented and compared: every
filter, dataset, and failure breakdown can slice by them. Add every tag that
answers a question the business would ask about this feature, using what Step 1
learned about the product.

- `X-Three-Tag-<key>: <value>` tags one request. `X-Three-Session-Tag-<key>:
  <value>` tags the whole session and is sent alongside `X-Three-Session-ID`.
  The proxy strips both before the request reaches the provider.
- Always send `X-Three-Tag-Environment`, lowercase, read from the codebase's
  existing environment setting (`NODE_ENV`, `APP_ENV`, `RAILS_ENV`, or
  equivalent), with `production` for production traffic. If there is none,
  read it from a `THREE_DEV_ENVIRONMENT` variable that defaults to `local`,
  and add that variable to the env template next to `THREE_DEV_API_KEY`.

### What to look for

| Dimension | Examples | Level |
| --- | --- | --- |
| Customer segment | plan tier, customer type, company size, market or region | session |
| Language | locale, language of the conversation | session |
| Entry point | channel (web, mobile, API, email, voice), surface or page the flow started from | session |
| Step within the use case | the agent, tool flow, or pipeline stage that made the call | request |
| Trigger | user-initiated or scheduled job | request |
| Configuration | prompt or config version, feature flag or cohort in force, read from the config itself | session |
| Release | app version or build, when the code already exposes it | request |

A session tag describes something constant for the whole interaction; a request
tag describes one call. Business identifiers that people look up (a tenant or
account ID) are tags too.

### Rules

- Use values the code already has at the call site or in the context it
  already passes there. Do not add queries, tracking, or new plumbing to
  compute a tag.
- Prefer a small, stable set of values: enum names and codes, not display
  strings. Keys are lowercase words joined by hyphens.
- Values must be ASCII and short; a header value that is not ASCII is dropped.
- Never tag personal data or content: names, emails, phone numbers, free
  text, or anything the user typed.
- When a value can be missing, send no header rather than an empty value.
