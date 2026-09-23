# <Name> — <code|flow> focus

Traced at `<sha>` on `<branch>`, `<YYYY-MM-DD>`.

Entry point: <the concrete trigger — route, queue consumer, cron, CLI command> at
`<path:line>`. <One sentence on where the traced code runs and what guards it: a lock, a
background task, a transaction.>

## Diagram

```mermaid
%% <name> — <entry point>. Exits: <list>.
%% Traced at <sha> on <branch>, <YYYY-MM-DD>.
%% Sources: <path/a.py:10-90> · <path/b.py:31-77>
%% Siblings: <other>.md (<what it covers>)
<diagram kind>
    <paste the filled-in body from templates/<kind>.mmd here — nothing but Mermaid>
```

<!-- Exactly one mermaid fence per file, closed by its own ``` line. Never write a sibling
     .mmd. Never put a heading, a table, or prose inside the fence. -->

## Steps

### START — <the trigger, worded as the diagram words it>

<What is already true when this runs, and what a failure here costs. One short paragraph.>

### 1 — <diagram label, verbatim>

`<the deciding expression or call>` at `<path:line>`.

<Why the step exists — the invariant, rule, or failure mode it protects.>

<Consequence a reader would otherwise get wrong: ordering guarantee, partial-failure
behaviour, what is skipped when a dependency is unconfigured, whether the caller waits.>

### 1.1 — <branch or failure terminal label, verbatim>

`<path:line>`.

<What state the system is left in, and who observes the outcome.>

### 2 — <diagram label, verbatim>

`<the deciding expression or call>` at `<path:line>`.

<Why.>

<!-- One ### per diagram element, in diagram order, numbered as the diagram numbers
     them. Include every terminal and every decision. Delete this comment.
     These sections are the only place source may be quoted — the argument list, the
     keyword arguments, the exact condition. The diagram label carries a reference
     (`<call> — <what it does><br/>file:line`), never the expression.
     A structure diagram with genuinely no execution order may title this section
     ## Parts instead — but numbered runtime order is the default. -->

## Terms

| term | means | defined at |
|---|---|---|
| `<term>` | <one line, from source — contrast it with the term readers confuse it with> | `<path:line>` |
| `<status value>` | <what this status permits and forbids downstream> | `<path:line>` |

<!-- 5-20 rows. Every term that appears in a node label, an arrow label, or a step
     section and is not plain English. Cite where the term is DEFINED, not used. -->

## What the diagram deliberately omits

- <plumbing the focus skipped — latency spans, logging, helpers>
- <branches collapsed into one element, and where the detail lives instead>
- <for a structure diagram: which package owns which shape, since imports are never drawn>

## Open questions

- <what you could not resolve from source, and what would resolve it>
- <every inferred edge: what wires it, and why source could not confirm it>

<!-- Delete this section if empty. -->

## Related

- `<sibling>.md` — <what that file covers and why a reader would go there>
