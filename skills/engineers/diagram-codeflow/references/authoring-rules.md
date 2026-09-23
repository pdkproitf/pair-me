# Authoring rules

## Terminals (mandatory — every diagram must have a start and every end)

| kind | start | ends |
|---|---|---|
| `flowchart` | exactly one stadium entry node, `S(["START: <trigger>"])`, with no inbound edge | one stadium terminal per real outcome, with no outbound edge |
| `sequenceDiagram` | the first message, from the `actor` caller | one `-->>` back to that actor per real response, **including every error response** |
| `stateDiagram-v2` | exactly one `[*] --> <first>` | one `--> [*]` per real outcome |

- Name the trigger concretely: the HTTP route, the queue and consumer group, the cron expression, the CLI entry.
- Every real end: response returned, message published, transaction committed, early return, exception response. **No path may trail off** — every branch reaches a terminal.
- Mermaid has no `detach`/`kill`. A fire-and-forget hand-off is a `-.->` (flowchart) or `-)` (sequence) into the queue element; it does **not** count as the path's terminal. The path that publishes still needs its own terminal, and the consuming flow is a sibling `<name>.md`.
- A split flow gives each file its own start and its own full set of ends.

## Step numbering

- **`sequenceDiagram`: use `autonumber`.** It is native and cannot drift.
- **`flowchart` and `stateDiagram-v2`: prefix labels manually** — `N1["1. validate payload"]`, `state "3. awaiting capture" as S3`. Number in execution order along the main path; branches take dotted sub-numbers from their decision point (`3.1`, `3.2`); a loop body keeps one number set.
- Never skip or reuse a number. With no step table inside the fence, the numbers are the reader's only index — a gap reads as a missing step. They are also the join between the diagram and the `## Steps` sections below it, whose `###` headings repeat the same numbers, so settle the numbering in the diagram before writing those sections rather than after.
- **Two edges may share one ordinal when they genuinely run concurrently** — that is the documented fan-out form. Say so in both labels (`3. embed<br/>concurrent with 3`), or use `par` in a sequence diagram.

## Structure — code focus only

- One `subgraph fn["<fn>() — path/file.py:<line>"]` … `end` per function. Nest a subgraph when its function is only called from inside another.
- ~1 element per source line or logical block. Never fold distinct lines into one element or split one line across elements. A branch-free run of statements with nothing individually notable = 1 element.
- **Label form: `<n>. <call or condition> — <what it does><br/>file:line`.** Name the call and cite the line; do not paste the source line into the label. `C6["8. embed_query then index.upsert — mirror the claim<br/>persist.py:53"]` reads; `C6["8. vector = await self.embedder.embed_query(claim_text(claim))"]` is the code with worse formatting, and a reader who wants the code follows the citation.
  - **The citation replaces the quotation.** That is what `file:line` is for: the label says *which* call and *why*, the line says *how*.
  - Keep a **guard's condition** as a short question, not the expression — `D2{"7. embedder and vector index both injected?<br/>persist.py:51"}`, not `D2{"if self.embedder is not None and self.vector_index is not None"}`. A one-token condition (`if not claims`) may be named as-is when the plain-English form would be longer.
  - Argument lists, keyword arguments, `await`/`async with` noise, and the receiver chain are **mechanics for the `## Steps` prose**, where `limit=self.config.context_window` and the `if vector:` guard belong. Code focus means every call gets an element, not that every character gets drawn.
  - This is what separates the two focuses now: code focus is one element **per call**, named by what that call does; flow focus is one element per **business step**. Neither quotes source.
- Nodes inside a subgraph inherit its location from the title — do not repeat `file:line` on every node. Labelled **edges** still cite their own emitting line.

## Structure — flow focus only

- One `subgraph` (flowchart) or one `participant`/`actor` (sequence) per service, module, or actor. Not per function.
- One element per business step. A function whose whole job is one domain step is one element; a function performing three distinct domain steps is three.
- Service communication is explicit and labelled with transport and direction: `SVC_Api -->|"POST /v1/orders"| SVC_Orders`, `SVC_Orders -.->|"publish order.created"| Q_Events`. Give each external system its real node shape — `DB[("Postgres")]`, `Q[/"order.events"/]`, `EXT{{"Stripe"}}`.
- Omit logging, metrics, framework glue, and helpers with no domain meaning. Do include every guard that can reject the request — a rejection is business logic.
- Keep `file:line` on the subgraph or participant title even though elements are coarser.

## Structure — runtime order, never imports

A structure diagram answers "what exists, what calls what, in what order, and what waits for
what". It is a flow drawn at module or service granularity, not a dependency graph.

- **Every edge is something that happens at run time** — a call, a message, a publish, a read, a write. If the arrow cannot be given a moment in time, it is not an edge.
- **Never draw an `import`, a re-export, or a type-only reference.** Those describe the module graph, and a reader cannot tell from them whether the code ever runs. Where a shape or a type is *owned* is a fact for the `## Steps` / `## Parts` prose and the glossary — say "`mgraph.ingest.dto` owns `ConversationMessage`; `mgraph.dto` re-exports it" in words, and draw the call that actually carries a message instead. `E-IMPORT-EDGE` checks this.
- **A `TYPE_CHECKING`-guarded import is doubly not an edge** — it does not exist at run time at all. If the guard is worth knowing, it is a `**Defect worth knowing:**` note or a `%%` header caveat, never an arrow.
- **Number the edges in execution order**, like any other flow: `1.`, `2.`, `3.`, with `2.1`/`2.2` for branches off a decision. The ordinal goes first in the label, before the call and the citation: `|"3. persist one claim<br/>pipeline.py:164"|`.
- **Name the async mechanism on every edge that does not block the caller.** The reader's first question about any module boundary is whether the caller waits.

  | behaviour | draw it as | label says |
  |---|---|---|
  | caller awaits the result | solid `-->` / `->>` + `-->>` return | `await <call>` |
  | two or more calls run concurrently | one ordinal shared by both edges, or `par` in a sequence diagram | `asyncio.gather`, and which calls are in the group |
  | background task, caller does not wait | dotted `-.->` / `-)` | `create_task`, fire-and-forget |
  | queue hand-off | dotted `-.->` into a `Q_` node | `publish <topic>` |
  | thread or process pool | dotted `-.->` | `run_in_executor` / `submit` |

  `E-ASYNC` checks that a non-blocking edge says how it is non-blocking.
- **Prefer `sequenceDiagram` with `par` when order plus concurrency is the whole point.** A flowchart can carry ordinals, but it cannot show two calls overlapping in time; a sequence diagram can.
- **A structure diagram still has an entry and terminals.** Name the concrete caller that starts the flow (the route, the consumer, the service method) and where each path ends. A diagram with no entry is a topology sketch, and the reader cannot tell which arrow happens first.
- Ownership boundaries are `subgraph`s — one per package, module, or service. Their titles carry `file:line`; the edges carry their own emitting call site.

## Step granularity — merge or split

- **Merge** two operations when they are atomic from the caller's point of view: the caller cannot observe the intermediate state, and a failure between them is indistinguishable from a failure inside them.
- **Split** them when there is an interesting intermediate value worth showing, or when a failure *between* them is meaningfully different from a failure *inside* them. Different failure mode = different element.
- This criterion outranks "one element per line" in flow focus, and refines it in code focus: a branch-free run of lines with one observable outcome is one element.

## Topology

**Round trips are two messages** — if A calls B and uses the response, draw `A->>B` and `B-->>A`. One arrow hides where the latency and the failure live. The exception is genuine fire-and-forget (`-)`), which has no return.

**Direction carries meaning** — order participants along the path of the request: caller, edge/handler, orchestrator, backing services, stores. Once ordered, a right-to-left arrow means **a response**. A *request* pointing backwards against that order means the ordering is wrong or a step is missing — fix the model, not the arrow.

**Orientation is fixed per kind, not chosen per diagram** — `call-chain` and `runbook` are `flowchart TD`; pipeline/lineage, service maps and deployment are `flowchart LR`. Do not flip orientation to fix crossings; reorder nodes or split the diagram instead. Mermaid owns layout — you cannot hand-place, so those are your only two levers.

**Shared functions** — one function called from 2+ call sites (e.g. sync handler and async worker) is drawn ONCE. In a flowchart, declare the node once and point every call site at it. In a sequence diagram, give it one participant that receives arrows from both callers. Never duplicate the subgraph per caller.

## Anti-clutter motifs

Draw the interesting branch and describe the other:

- Cache-aside: draw the miss (cold) path; name the hit path in a `note` or in the step label. Not two parallel branches.
- Retries and backoff: a `note`, unless retry behaviour is the point of the diagram (`runbook`), in which case draw the loop.
- Fan-out to N identical consumers: one consumer plus a `note` giving N. Never draw all N.

## Every arrow cites its call site

A labelled arrow is a claim that one thing invokes another. Make it checkable:
append the emitting `file:line` to the label after a `<br/>`, so a reader can jump
straight from the edge to the code.

```
SVC_Api->>SVC_Orders: create_order(payload)<br/>orders/api.py:42
SVC_Orders-->>SVC_Api: 201 Order<br/>orders/api.py:71
Pending --> Paid : webhook.charge_succeeded<br/>billing/hooks.py:88
A -->|"publish order.created<br/>orders/events.py:12"| Q_Events
```

- **Cite the line that *emits* the message**, not the line that handles it. For a request that is the call site in the sender's file; for a return arrow it is the `return`/response statement in the receiver's file. Getting this backwards makes the citation useless for debugging, which is what it is for.
- **Citation goes last, after a `<br/>`**, so the meaning reads first.
- **Basename:line only** when the enclosing subgraph or participant declaration already establishes the directory **and no other traced package holds a file of that name**. Two `pipeline.py` in one repo makes `pipeline.py:343` unresolvable — cite `recall/pipeline.py:343`, enough path to be unique. `E-SOURCE` has a check for the collision. The `%%` header's `Sources:` line carries the full paths.
- **Applies to labelled edges**: sequence messages, state transitions, and quoted flowchart edge labels. Flowchart *nodes* carry their location in the subgraph title instead — do not repeat it on every node.
- **Exempt: branch-outcome labels.** `-->|yes|`, `-->|no|`, `-->|retry ≤3|` name which way a decision went, not a call — the decision node already carries the location via its subgraph title. Citing them adds noise and nothing checkable.
- **One location per arrow.** If a call happens at three call sites, that is either the shared-function case (draw it once) or three arrows.
- **Omit it, rather than guess it**, when the arrow is inferred — dynamic dispatch, DI container, decorator, config-driven wiring. An uncited arrow plus a line in your reply saying it was inferred is honest; an arrow citing the line you *think* wires it up is not. This is claim 3, extracted vs inferred. Record it in two places: the `## Open questions` section of the file, and the reply.

## Honesty

**Labels are semantic data** — when a label crowds the diagram, shorten the wording while preserving meaning. Omit wording only when it is already fully implied by both endpoints *and* carries no protocol, action, direction, sync/async behaviour, or cross-boundary mechanism. Deleting a meaningful label is not a layout fix.

**Never invent** — no element for a step you did not read. Status colour only where the source itself flags status (a `PHASE-3 done` vs `PHASE-4 pending` comment). A superseded-but-still-present function (a `TODO(TICKET): delete once ...` fallback) is mentioned in the reply, not drawn as a live branch — nothing on this path calls it.

**No decoration pretending to be notation** — do not write `«boundary»`, `<<control>>`, or a fake stereotype into a Mermaid label to imitate UML. Say the role in plain words or pick the right node shape.

**Annotations** — sample data (queue message shape, return value, row shape) only where it removes ambiguity about shape or types, not on every element. Use a `note` (sequence, state) or a `-.-`-linked node (flowchart) for anything longer than a label.

## Parse-error classes (Mermaid)

- First non-`%%` line is the diagram kind: `flowchart TD`, `sequenceDiagram`, `stateDiagram-v2`.
- Every `subgraph`, `alt`, `opt`, `loop`, `par`, `critical`, `break`, `rect`, and `box` needs its own `end`.
- `end` is reserved: never a node id, never a bare label. Quote it — `N9["end of stream"]`.
- Quote any label containing `(`, `)`, `:`, `,`, `#`, `{`, `}`, `|`, or starting with a digit.
- `<br/>` for a line break — not `\n`, not a raw newline. `\n` renders literally.
- `%%` comments only at the start of a line.
- In `sequenceDiagram`, every `activate` needs a matching `deactivate`, and a message to an undeclared participant silently creates one — declare every participant up front so a typo cannot invent a lifeline.
- In `stateDiagram-v2`, a transition label starts with ` : ` (spaces around the colon).

## Defects found while tracing

Tracing every branch reads the code more closely than a review does, so it surfaces
real bugs — a shadowed duplicate definition, an argument dropped at the live call
site, a default that silently takes over. Do not quietly diagram around one.

- Diagram the LIVE code path, not the dead one. Where a later definition shadows an earlier one, draw the shadowing definition and report both `file:line` in the reply, plus what the shadowed copy passed that the live one omits.
- Report the defect separately as Expected / Found / Impact / Proposed. Trace each consequence to a concrete outcome (which queue the message lands on, which guard never trips), not "this looks wrong".
- Do not fix it as part of the diagram task unless asked — one concern per step.
- Also record it in the `###` step section that owns it, as a short `**Defect worth knowing:**` note per `artifact-anatomy.md`. A reader of the file alone would otherwise trust a step the code does not honour.
