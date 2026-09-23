# Mermaid kinds, and what Mermaid cannot express

Mermaid is the only output format. There is no `uml` skill dependency, no PlantUML,
no mxgraph stencils. Write only constructs listed here or in `taxonomy.md` — a
guessed construct fails silently on a machine with no renderer.

| this skill's scenario | Mermaid header | start from |
|---|---|---|
| `api-request`, `async-roundtrip` | `sequenceDiagram` | `templates/sequence.mmd` |
| `call-chain`, `runbook / CI` | `flowchart TD` | `templates/flowchart.mmd` |
| `pipeline / lineage`, flow focus over several services | `flowchart LR` + one `subgraph` per service | `templates/swimlane-flowchart.mmd` |
| `state-lifecycle` | `stateDiagram-v2` | `templates/state.mmd` |
| `structure / service map`, `deployment` | `flowchart LR` + nested `subgraph`, or `sequenceDiagram` with `par` when order and concurrency are the point | `templates/component.mmd` |

Always `stateDiagram-v2`, never `stateDiagram` — v1 lacks directions, notes on
composite states, and choice states.

The `templates/*.mmd` files are diagram bodies only. Paste the filled-in body into the
```` ```mermaid ```` fence of `templates/diagram-doc.md`, which is the file you actually write. No
`.mmd` file is ever written into the repository.

A structure diagram is a flow: its edges are runtime calls numbered in execution order, and every
non-blocking edge names its async mechanism. See **Structure — runtime order, never imports** in
`authoring-rules.md`. `flowchart LR` carries ordinals; only `sequenceDiagram` with `par` can show
two calls overlapping in time.

## What Mermaid cannot do — say so, do not fake it

Each of these is a real capability gap against UML. Handle it the stated way and,
when it materially changes what the reader sees, mention it in the reply (never in
the file).

| gap | handling |
|---|---|
| No `boundary` / `control` / `entity` / `database` / `queue` participant stereotypes | `sequenceDiagram` has only `actor` and `participant`. Carry the role in the display name (`participant PG as PostgreSQL palace_drawers`). Do **not** write `«boundary»` in a label — decoration pretending to be notation. In a `flowchart`, use the real node shapes instead: `[(...)]` for a store, `[/.../]`  for a queue-ish feed, `{{...}}` for an external system. |
| No external entry/exit arrows (PlantUML's `[->` / `[<--`) | Declare the caller as an `actor` and draw real arrows to and from it. Every response, including errors, is an arrow back to that actor — that is what makes the terminal check meaningful. |
| No swimlanes | A `flowchart` `subgraph` per service is the substitute. It groups but does not enforce lanes, and Mermaid may lay two subgraphs side by side in either order. Do not fight the layout; if lane order is load-bearing, use `sequenceDiagram` instead. |
| No native per-`alt`-fragment background attribute | Wrap the body of each `alt` / `else` branch in a `rect rgb(...)` block — that renders as a per-branch wash. Fixed colours (success / failure / neutral) and the shape are in **Colour inside `alt` / `else`** in `taxonomy.md`. Indentation still carries depth; phase washes (a different use of `rect`) are still capped at two per diagram. |
| No `partition` | `flowchart` `subgraph "fn() — path.py:42"` is the code-focus equivalent, and it nests. |
| No vendor icon stencils (in a plain flowchart) | Name the vendor in the node label. `architecture-beta` does support icon packs, but it is experimental, needs Mermaid ≥11.1 plus a registered icon pack, and renders nowhere else — use it only if the user asks for it by name. |
| No `-[#colour]>` per-arrow colour by receiver | Colour nodes with `classDef`, not arrows. `linkStyle <index>` exists but is positional, so an inserted arrow silently recolours the wrong edge — avoid it. |
| `C4Context` / `C4Container` | Experimental, layout is poor, and it is not what most Mermaid renderers support well. Use `flowchart LR` with subgraphs for a service map. |

## Rendering target

Assume a plain Mermaid renderer (GitHub, an IDE preview, `mmdc`). Do not use
`%%{init: ...}%%` theme blocks unless the user asks for a theme — they are ignored
by some renderers and clutter the file the contract says is diagram-only.
