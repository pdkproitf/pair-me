# Element taxonomy (Mermaid)

A closed vocabulary, so notation means the same thing in every diagram this skill
writes. Use nothing outside these tables; a construct Mermaid does not know fails
silently when no renderer is available to catch it.

## `flowchart` (`call-chain`, `runbook`, `pipeline`, `structure / service map`, `deployment`)

| Mermaid | code focus | flow focus |
|---|---|---|
| `S(["START: POST /v1/orders"])` stadium | entry | entry |
| `T(["200 Created"])` stadium | terminal — one per real outcome | same |
| `N["1. label"]` rect | statement or block | business step |
| `D{"2. order.total > limit?"}` rhombus | branch condition | business decision / gate |
| `-->|yes|` / `-->|no|` | branch outcome | branch outcome |
| `-->|retry ≤3|` back to an earlier node | loop | retry loop |
| `subgraph fn["handle_order() — api/orders.py:42"]` … `end` | one per function | one per service or actor |
| `DB[("Postgres orders")]` cylinder | data store | data store |
| `Q[/"order.events"/]` parallelogram | queue or topic | queue or topic |
| `EXT{{"Stripe"}}` hexagon | external system | external system |
| `-.->` dotted | fire-and-forget publish / async hand-off | same |
| `==>` thick | the main path, when a diagram has many side branches | same |
| `classDef guard fill:#f8cecc` + `G:::guard` | auth / policy / permission guard | same |
| `NOTE["note: text"]` linked with `-.-` , or a `%%`-free label line | annotation | annotation |

`flowchart` has no `note` primitive: attach a plain node with `-.-` (no arrowhead)
when a caveat cannot fit the label.

Parallel work has no `fork` primitive either — draw one node fanning out to several
nodes and rejoining, or say in the label that the branches run concurrently. Concurrent edges
share one ordinal, and both labels say so (`3. embed<br/>concurrent with 3`).

A `structure / service map` uses this same vocabulary as a flow: entry node, ordinal-prefixed edge
labels in execution order, terminals. An `import` or a type-only reference is not in this table and
is never an edge — see **Structure — runtime order, never imports** in `authoring-rules.md`.

## `sequenceDiagram` (`api-request`, `async-roundtrip`)

Mermaid has only two lifeline types; the role lives in the display name.

| Mermaid | meaning |
|---|---|
| `actor Client` | human or external caller — **also carries the entry and exit arrows** |
| `participant SVC_Api as POST /v1/orders` | service, module, store, or queue; name it so the role is obvious |
| `box "billing" ... end` | group related participants (Mermaid ≥10) |
| `A->>B: msg` | synchronous call |
| `B-->>A: msg` | return / response |
| `A-)B: msg` | async, fire-and-forget (open arrowhead) |
| `A--)B: msg` | async return / callback |
| `A->>A: msg` | in-process work on one lifeline |
| `activate A` / `deactivate A` | lifespan of the call |
| `alt` / `else` / `end`, `opt`, `loop`, `par`, `critical`, `break` | branch, optional step, loop, parallel, guarded, early exit |
| `note over A,B: text` / `note right of A: text` | annotation |
| `rect rgb(240,248,255)` … `end` | wash one phase of the call |

`autonumber` is mandatory — never hand-number a sequence diagram.

## `stateDiagram-v2` (`state-lifecycle`)

| Mermaid | meaning |
|---|---|
| `[*] --> Pending` | **start** (mandatory) |
| `Paid --> [*]` | **terminal** (one per real outcome) |
| `A --> B : payment.submitted<br/>billing/api.py:22` | event-labelled transition |
| `state check <<choice>>` | decision point |
| `state f <<fork>>` / `<<join>>` | parallel split / rejoin |
| `state "awaiting capture" as Awaiting` | wait / retry state |
| `note right of Awaiting : text` | annotation |
| `direction LR` | orientation |

## Every labelled arrow carries its call site

Every arrow above takes its emitting `file:line` appended to the label after a
`<br/>`. See **Every arrow cites its call site** in `authoring-rules.md` for which
line to cite and when to omit it.

- sequence: `A->>B: create_order(payload)<br/>api/routes.py:24`
- flowchart edge: `A -->|"publish order.created<br/>orders/events.py:12"| Q_Events`
- state: `Pending --> Paid : webhook.charge_succeeded<br/>billing/hooks.py:88`

Mermaid has no font-size markup that works across renderers, so the citation is
plain text on its own line. Keep it last in the label so the meaning reads first.

## Colour

- **Colour nodes, not arrows.** `classDef` plus `:::` is stable across edits; `linkStyle` is positional and silently recolours the wrong edge when an arrow is inserted. Never use `linkStyle`.
- Colour only when the diagram has ≥3 services or ≥2 outcome types; below that it adds nothing.
- Fixed meanings, declared once via `classDef`: success terminal `fill:#d5e8d4`, failure terminal `fill:#f8cecc`, guard `fill:#f8cecc`, external system `fill:#e1d5e7`, store `fill:#ffe6cc`.
- ≤6 distinct colours per diagram, washes included.

## Depth in a `sequenceDiagram`

Indent every fragment body one level — that is the depth cue. Prefer sibling
fragments to nested ones: a branch that terminates the call (an error path that
returns 503) is a sibling `alt` followed by the rest of the flow, not a wrapper
around it. Three depth levels means the diagram should split.

## Colour inside `alt` / `else`

Mermaid has no per-fragment background attribute, but a `rect rgb(...)` block
wrapped **around the body** of each `alt` / `else` branch renders as a coloured
wash for that branch. Use it — the wash makes the success and failure paths
readable at a glance, which indentation alone does not.

Fixed meanings, matching the terminal palette in the Colour section:

| branch outcome | wrap the body in |
|---|---|
| success / happy path | `rect rgb(213,232,212)` (light green — matches `#d5e8d4`) |
| failure / rejected / error | `rect rgb(248,206,204)` (light red — matches `#f8cecc`) |
| neutral / conditional-but-not-outcome (e.g. "if cached") | `rect rgb(222,235,247)` (light blue) |

Shape:

```
alt charge succeeds
    rect rgb(213,232,212)
        SVC_Orders->>EXT_Stripe: POST /v1/charges
        …
    end
else card declined
    rect rgb(248,206,204)
        SVC_Orders->>EXT_Stripe: POST /v1/charges
        …
    end
end
```

Every `rect` still needs its own `end`; the wash `end` closes before the
`else` / outer `end`. These branch washes do **not** count against the ≤2
phase-wash cap in `W-DEPTH` — they are notation, not decoration.

When a phase (not a branch) genuinely needs a wash, `rect rgb(...)` still
applies — at most twice per diagram, wider block lighter: `rgb(247,251,255)`
outer, `rgb(222,235,247)` inner.
