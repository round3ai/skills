<!-- Synced from https://docs.three.dev/getting-started/planning-your-integration.md. Do not edit; the live page wins. -->

# Planning your integration

Decisions to make before wiring in the proxy — how many use cases to create, whether environments need separate keys, what a session is for your feature, and which tags to send.

The proxy needs three headers to record a request: your API key, a use case slug, and a session ID. You can create a use case from the **Use Cases** page or let three.dev create it on the first request under a new slug; either way, the decisions on this page are about which slugs your code sends.

## How many use cases should I create?

A use case is one AI feature with one goal — the thing you want to know is working or failing. Create one use case per goal, not one per prompt, per segment, or per environment.

**Keep prompts in the same use case when a change to one can change the output of another.** A support assistant that classifies the customer's intent, retrieves matching help articles, and then drafts a reply runs three prompts, but it is one use case. An edit to the classification prompt shows up in the quality of the final reply, and you want to see that connection. Three separate use cases hide it.

**Split into separate use cases when features are independent and you tune them separately.** A ticket summarizer that shares no prompt or input with the support assistant is its own use case.

**Do not split a use case by segment.** If one support assistant serves 20 product lines, create one use case and send the product line as a tag. The Requests and Sessions pages filter by tag, so you get the per-segment view without 20 copies of every use case and its settings. See [Which tags should I send?](#which-tags-should-i-send).

**Do not split a use case by environment.** See [Do I need a separate API key per environment?](#do-i-need-a-separate-api-key-per-environment).

**Do not build the slug from a runtime value.** three.dev creates a use case for every new slug it sees, so a header filled from a user ID, tenant, or session ID creates one use case per value. three.dev stops recording after 20 use cases created this way. Keep the slug a constant per AI feature, and send the varying value as a tag. See [Creating use cases](https://docs.three.dev/sending-requests/sending-requests.md#creating-use-cases).

When in doubt, start with fewer use cases. Adding a tag to existing requests is a one-line change. Splitting a use case later leaves its history and failure modes behind.

## Do I need a separate API key per environment?

No. three.dev groups data by use case, not by API key. Requests that carry the same use case slug land in the same use case whichever key sent them, so a second key does not separate local, staging, and production traffic.

Use separate keys for security if you want to: you can revoke a leaked local key without touching production, and a key that lives on developer laptops never has to be the production key. Either way, send the traffic from every environment to the same use case and tag each request with its environment:

```
X-Three-Tag-Environment: production
```

Use the tag key `environment` exactly, and the value `production` for production traffic. Pick short lowercase values for the rest, such as `staging` and `local`, and use the same ones everywhere. Then narrow any view to one environment with a filter expression such as `tag["environment"] == "production"`.

Live scoring and failure modes span every environment in the use case. Send the tag on every request, including local ones, so you can tell which environment a failure came from.

## What should a session be for my feature?

A session is how three.dev shows one interaction as a whole: the Sessions page reads it as one conversation, and the failures live scoring finds in its requests appear together on it. The session must identify exactly one interaction.

| Feature shape                                                       | One session is                                                                   |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Chat                                                                | One conversation, from its first message to its end. Reuse the ID on every turn. |
| Agent run or multi-step pipeline                                    | One run, across all of its requests.                                             |
| One-shot generation — a recommendation, a summary, a classification | One request.                                                                     |

For one-shot features, generate a fresh UUID immediately before the request and send it as `X-Three-Session-ID`. Store it with the record the request produced, so you can find the session in three.dev from your own data.

### Every session must end

three.dev expects a session to finish, even when your product never marks an end. A session that runs forever turns months of separate interactions into one endless conversation: the Sessions page can no longer show where one attempt ended and the next began, and a failure in one chat is read alongside every other chat the customer ever had.

Bound each session to one attempt at the goal:

* **Do not key the session to a durable identity.** A customer who returns for ten separate support chats is ten sessions. A player who talks to the same character every day is a new session each time.
* **Roll the session ID over when the product has no explicit end.** For a persistent thread or an always-on assistant, start a new session ID after a period of inactivity, such as 30 minutes without a message, or when the user starts a new topic. Pick one rule and apply it everywhere.

**Do not build the session ID from business identifiers that can repeat.** If a user can request a summary of the same ticket twice, a session ID like `<TICKET_ID>-summary` merges two different outputs into one session, and the failures of both read as one interaction. A random UUID per request avoids this. Send the business identifiers as tags instead, so you can still filter on them.

## Which tags should I send?

Tags are free-form key/value pairs. Request tags (`X-Three-Tag-<TAG_KEY>`) describe one call; session tags (`X-Three-Session-Tag-<TAG_KEY>`) describe the whole session. Both are filterable — see [Filtering](https://docs.three.dev/exploring-your-data/filtering.md). Three kinds earn their place on almost every integration:

| Tag                                                  | Level              | Why                                                                  |
| ---------------------------------------------------- | ------------------ | -------------------------------------------------------------------- |
| `environment`                                        | request            | Separate local, staging, and production traffic inside one use case. |
| A segment — product line, plan tier, tenant, channel | request or session | Slice one use case by segment instead of splitting it into many.     |
| A configuration version                              | session            | Mark changes to the feature that never ship as a code deploy.        |

### Tagging configuration changes

Not every change to an AI feature is a code deploy. You point retrieval at a different source, edit the set of questions a prompt receives, or flip a feature flag that changes the prompt text. three.dev records the model on every request, and the messages for [supported APIs](https://docs.three.dev/sending-requests/supported-paths.md), but it cannot see the rest.

Send a session-level tag that identifies the configuration in force for the session:

```
X-Three-Session-Tag-Config: questions-v2
```

**Read the value from the configuration itself, not from a constant in code.** A hardcoded value only changes when you deploy, which defeats the purpose. Use the version number or updated-at timestamp of the config record, the feature flag value, or a short hash of the loaded config. Then the tag moves the moment the config does, with no deploy.

Compare before and after by filtering Sessions on `tag["config"] == "questions-v1"` and `tag["config"] == "questions-v2"` in turn. Pick any key and value scheme you like; three.dev reserves no tag names.

## Continue to

* [Quickstart: Record your requests](https://docs.three.dev/getting-started/quickstart-record-requests.md)
* [Supported paths](https://docs.three.dev/sending-requests/supported-paths.md)
