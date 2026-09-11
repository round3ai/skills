# Report template

One report per failure mode investigated. Keep each section to a few lines; the
evidence section carries the weight.

**Failure mode**: `<name>` (severity `<severity>`, use case `<slug>`)
`<title, one line>`

**How often**: `<occurrences>` occurrences in `<request_count>` of
`<scored_requests>` scored requests (`<rate>` per scored request) between
`<window.from>` and `<window.to>`. First seen `<first_seen_at>`.
`<Trend line when measured: rate in window A vs window B.>`

**What happens**: two or three sentences in the product's terms, from the judge's
description and the conversations, not a restatement of the name.

**Evidence**: for each conversation read, the request id, what the user asked,
and the quoted turn where it went wrong. Two or three entries.

**Root cause**: the mechanism, stated as a claim with its confidence. Say which
evidence supports it and what would disprove it. If two causes are plausible,
list both.

**Proposed fix**: the concrete change. For a prompt, the exact wording to add,
remove or replace and where it goes. For a model or parameter change, the
alternative and why. For a tool or code change, the file and behaviour.

**How to verify**: the offline experiment to run (variants, dataset, filters; the `three-dev-experiments` skill runs it), or
the window to re-check live after shipping, and what number should move.

**Links**: the failure mode and request URLs the tools returned, verbatim.
