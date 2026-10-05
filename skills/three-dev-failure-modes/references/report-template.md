# Report template

## Default

A few short sentences in plain language, each claim linked to the page that
shows it:

> [<Failure mode>](link) is the one to fix first: `<why, as Step 1 picked it>`
> (`<occurrences>` of `<scored>` scored requests, `<rate>`). `<The two or three
> largest shapes in plain words, each with its count, what reached the user and
> a linked example; the rest in one clause.>` `<The fixes that cover them, in one or two sentences.>` `<One
> question: make the change, or run the experiment with its rough cost.>`

One paragraph: no headers, tables or bullets. Numbers go in one parenthesis
per sentence; caveats and sizing limits go in the detail.

## Detail, when the user asks

- **Shapes**: the table from [fix-design.md](fix-design.md), over the `<n>`
  flagged requests classified, sample stated when one.
- **Evidence**: per conversation read, the linked request, what the user asked
  and the quoted turn where it went wrong; the passing one and what it did
  differently.
- **Root cause**: the mechanism with its confidence, the evidence for it and
  what would disprove it; both causes when two are plausible.
- **Fixes**: the exact prompt wording, the tool or file and new behaviour, or
  the alternative model.
- **Constraints**: what the fixes keep unchanged.
- **How to verify**: the verification plan from [fix-design.md](fix-design.md).
