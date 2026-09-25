# Designing the fix

Contents: [Judge check](#judge-check), [Shapes](#shapes), [Fix layers](#fix-layers), [Worked example](#worked-example), [Variants](#variants), [Verification plan](#verification-plan), [After the results](#after-the-results).

## Judge check

A failure mode is the AI Judge's reading of the traffic, and the judge can be
wrong. Before treating a flagged request as a product failure, check it against
the use case's own instructions, the system prompt you read in the
conversation. It is a judge false positive when:

- the verdict asks for something the instructions do not say, or forbid;
- the judge could not see what the model saw: an image or file recorded
  without its content, a part cut from the recording, a tool result the
  conversation does not carry;
- two instructions contradict each other and the judge picked one;
- the model's answer is right and the judge's reasoning is about wording or
  style the instructions do not ask for;
- the same input with the same behaviour passed elsewhere in the window: the
  verdict is inconsistent, so count those requests as noise, not failures.

A verdict about something checkable in the recording, a tool called or not, a
field missing, is rarely wrong; spend the check on verdicts about meaning,
tone or correctness.

Count the false positives per shape and report them with one quoted example.
Leave them out of the shapes' counts. When most of a mode is false
positives, the proposed fix is to the judge's criteria, which the user edits
in the three.dev app, and the product fix is secondary or none.

## Shapes

A shape is one recurring way the failure happens, named by the first thing
that went wrong, not the downstream symptom: "looked up the order before
verifying identity", not "disclosed account data". Two to five shapes cover a
mode; more means they are too fine, merge them. When the first thing that went
wrong is the same in every row, split by where it happens instead: which tool,
which kind of request, which input.

Present them as:

| Shape | Requests | Share of the mode | What reached the user | False positives |

`What reached the user` is observed, not assumed. Read the tool's response to
the flagged call, not only the call: in `get_request_conversation` of that
request, or of the session's next request when the flagged one ends at the
call. Then read what the user got: data, a wrong answer, a refusal, nothing.

No shape is dismissed because the tools caught it: the whole mode is the
user's problem. One fix can cover several shapes, and several shapes can need
different fixes.

## Fix layers

Pick the layer the shape points to, top row first:

| The shape is | Fix it in | Examples |
| --- | --- | --- |
| A tool called in the wrong order, with an argument the model should not supply, or two tools that are always chained | The tool interface or the code around it | Merge the chained tools; require the id the earlier step returns; reject the invalid call with an error that says how to fix it |
| A fact stated without reading its source, or read from a stale one | Retrieval or data | Return the fact where the model reads it; remove or demote the stale source |
| An instruction missing, ambiguous or contradicted | The prompt | The exact wording to add, remove or replace, and where |
| A broken output format | Structured output or the schema | Enforce the schema instead of asking for it |
| Beyond the model: long reasoning, long context, a skill it lacks | The model or its reasoning setting | Name the alternative and what to compare |
| A criterion the instructions do not support | The judge's criteria | The criterion to change, with the false positives as evidence |

Tighter prompt wording rarely changes which tools a model calls or in what
order; the interface does. A judge that grades against the system prompt also
grades a stricter prompt more harshly, so a prompt fix and a tool fix are not
compared on equal terms.

State the constraints the fix keeps: facts stay in their source of truth, the
model stays the same unless the cause is capability, and behaviour outside the
mode does not change.

## Worked example

A support bot, 83 requests flagged "account access before verification". The
judge's reasoning splits them into three shapes: verification and a lookup
issued in the same round (41; the tools refused the lookup, but the bot keeps
trying), a lookup by an order or serial number the customer typed before any
verification (32; the data came back), and text turns that mention the account
early (10). The prompt already forbids all three, so no shape is a missing
instruction. One interface fix covers the first two: a tool verifies and
returns the customer id, and the lookup tools require that id. The prompt
renames the tool and says the account stays private until verified, which
covers the third. What reached the user depends on each app's tools, so read
its responses rather than this example.

## Variants

An offline experiment holds up to nine variants against the same control, so
every plausible fix goes into one experiment:

- **Prompt**: two or three variants that fix the shape's mechanism in
  different ways, such as a rule, a short worked example, or moving the
  instruction where the model reads it first. Each is a minimal change to the
  recorded prompt, one idea per variant, so the result says which idea worked.
- **Model**: a larger model on the recorded prompt, when the shape looks like
  capability rather than instructions.
- **Reasoning**: more reasoning effort or extended thinking on the current
  model, for the same reason.


## Verification plan

The report ends with what should move and how to see it:

- each shape's count now, and the count it should reach;
- a count taken from the conversations where one exists (lookups before
  verification per conversation), because it does not depend on the judge;
- sibling failure modes compared as a union, since the judge moves requests
  between neighbouring modes from one run to the next;
- the noise: two judge runs on the same outputs disagree on a few percent of
  verdicts, so a change of a handful of requests in one mode is not a result.

An offline experiment replays recorded requests with a changed prompt, model
or reasoning setting; it cannot replay a tool or code change. For those, the
check is the mode's rate in a window after the change ships against the same
length before it. For an experiment, the dataset must hold enough of the
shape: at its rate, the dataset should include at least about
twenty flagged requests in control, or a halving cannot be told from noise;
raise the dataset size when it does not. When even the largest dataset the
preview accepts holds fewer, say so plainly and let the user choose, as in:
"This only happens in about 4 of every 2,000 requests, so an experiment would
give us a hint rather than proof. Would you like to run it anyway, or should I
just apply the fix and we'll see how it does after you deploy?"

## After the results

Read each variant on this failure mode first, then on every other mode:

- **It worked**: this mode fell, by up to the share of the shapes the variant
  was for, and no other mode rose or appeared. A variant
  whose overall quality went up while another mode got worse did not work.
- **Compare prompt variants on this mode**, not only on overall quality: when
  the judge grades against the prompt it is given, a stricter prompt raises its
  own bar.
- **Nothing worked**: read the judge's reasoning on the variants' remaining
  failures of this mode. Where they cluster (short messages, one tool, one
  kind of request), that is the next variant's angle; where they look like
  the model cannot do it, the next round is a larger model or more reasoning.
