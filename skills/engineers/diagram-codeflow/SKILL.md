---
name: diagram-codeflow
description: Diagram a code flow as a Mermaid diagram — asks code focus (line-by-line) vs flow focus (business logic, steps, service communication) first, picks a Mermaid diagram kind with a must-include checklist, then writes one markdown file holding the diagram in a ```mermaid fence plus the sections explaining every step and defining every term. Trigger when the user asks to create/update a diagram of a code flow, pipeline, request path, worker chain, call chain, or module structure, to split one into per-stage diagrams, to explain or annotate the steps of an existing one, or to fix a Mermaid parse error in one.
metadata:
  phase: "documentation"
  input: "a code flow to diagram, or an existing diagram file to update against current source; plus the focus (code or flow)"
  output: "one file per diagram at docs_dir/diagrams/<name>.md — the diagram in a single ```mermaid fence (parse-clean Mermaid, %% provenance header, nothing else) followed by per-step explanation, term glossary, omissions"
---

# Code Flow Diagram (Mermaid)

Diagrams are **Mermaid**. Never emit PlantUML, never emit HTML, never emit an image.

Each diagram is **one file** — `docs_dir/diagrams/<name>.md` — holding the diagram and its
explanation together:

- **The diagram** lives in a single fenced ```` ```mermaid ```` block near the top of the file, so
  GitHub, an IDE preview, and any Markdown renderer draw it in place. Inside the fence there is
  nothing but Mermaid: no headings, no prose, no legend, no step table. The only non-diagram
  content permitted there is a short `%%` provenance header (see `references/artifact-anatomy.md`),
  which renderers ignore.
- **The explanation** lives in the Markdown sections *after* the fence: one section per diagram
  step, a glossary of every term the diagram uses, and what the diagram deliberately omits.

Never write a separate `.mmd` file. The fenced block is the diagram; a sibling `.mmd` would be a
second copy that drifts.

The diagram must still stand alone as a picture — `file:line` on labels, a `note` for a caveat,
honest node names — because a reader looking at a rendered SVG has no prose in front of them. The
sections below the fence add the *why*; they never carry load the diagram should have carried
itself.

This file is the router. Load a reference when its step arrives — not all of them up front.

| file | load when |
|---|---|
| `references/mermaid-kinds.md` | before drafting — scenario → Mermaid kind → template mapping, and what Mermaid cannot express |
| `references/artifact-anatomy.md` | writing the file — the fenced-diagram contract, `%%` header, required sections, per-step form, the term glossary, naming, size envelope, splitting |
| `references/taxonomy.md` | choosing notation — the closed element vocabulary per kind, colour rules |
| `references/authoring-rules.md` | drafting — terminals, numbering, per-focus structure, runtime order and async in a structure diagram, granularity, motifs, parse-error classes, defects found while tracing |
| `references/validation.md` | after writing, and after every edit — the checks, repair order, stop rule, five claims |
| `templates/diagram-doc.md` | copy as the file skeleton — fence, required sections and the glossary table already laid out |
| `templates/{flowchart,swimlane-flowchart,sequence,state,component}.mmd` | copy the body **into the fence** — terminals, numbering, and `autonumber` already wired correctly |

## Trigger

- "create/make a diagram of this code flow" (pipeline, request path, worker chain, call chain)
- "diagram the structure of this package/service" — draw the runtime flow between its parts, per the `structure / service map` row below
- update an existing flow diagram after source changed
- explain, annotate, or add step notes / a glossary to an existing flow diagram (write or refresh the sections below its fence)
- split one flow diagram into several (one per stage or queue hop)
- a Mermaid parse error on such a file
- add a missing entry point or call site to one
- convert an existing PlantUML/other-format flow diagram to Mermaid
- convert an older `.mmd` + `.md` pair into the single-file form: fold the `.mmd` body into the fence, then ask before deleting the `.mmd`

## Focus — ALWAYS ask first

Before tracing anything, ask the user with `AskUserQuestion` which focus they want. Never assume. The two modes produce different diagrams from the same source, and guessing wrong wastes the whole trace.

| | **Code focus** | **Flow focus** |
|---|---|---|
| Granularity | ~1 element per call, guard, or logical block | ~1 element per business step |
| Element label | the call named, plus what it does, plus `file:line` — never the source line pasted in | what the step accomplishes in domain terms |
| Grouping | one `subgraph` per function, `file:line` in its title | one `subgraph`/`participant` per service or actor |
| Shows | branches, loops, exceptions, local variables, guard clauses | business rules, decision outcomes, service-to-service calls, queues, external APIs |
| Skips | nothing on the live path | logging, plumbing, framework glue, internal helpers with no business meaning |
| Reader | someone about to edit this code | someone who needs to understand the behaviour |

**Code focus** — explain each call or block. Every call and guard that does something distinct gets its own element, labelled `<call> — <what it does><br/>file:line`. **A reference, not a transcription:** do not paste the source expression into the label — the citation is how a reader reaches the code, and the argument lists, keyword arguments and receiver chains belong in the `## Steps` prose. `file:line` on every subgraph title. See **Structure — code focus only** in `authoring-rules.md`.

**Flow focus** — explain the business logic. Each element is a step a domain expert would recognise ("validate payment method", not "call `_get_or_404`"). Draw every service boundary crossing explicitly: which service calls which, over what transport (HTTP / gRPC / queue / DB), with the payload shape where it matters. Collapse a whole function into one element when its business meaning is one step.

Neither focus draws imports. An `import` is not behaviour — see **Structure — runtime order, never imports** in `authoring-rules.md`.

If the user asks for both, write two files: `<name>-code.md` and `<name>-flow.md`.

The focus governs the prose too. A **code-focus** file explains each block's mechanics — what the guard rejects, what the local holds, why the loop terminates. A **flow-focus** file explains the business rule behind each step and what the domain loses if it is skipped. The glossary follows the same split: code focus defines identifiers, flow focus defines domain terms and status values.

## Scenario router — pick the Mermaid kind and the checklist

Choose the question before the diagram kind. Match the user's request to a row; the **must include** column is a completeness checklist to satisfy before writing (check `E-CHECKLIST`). If nothing matches, use `call-chain`.

| scenario | Mermaid kind | use when | avoid when | must include |
|---|---|---|---|---|
| `api-request` | `sequenceDiagram` | the reader needs exact call order across components | there is only one component | calling actor, callees, request + return messages, error path via `alt`, async side effects via `-)` |
| `async-roundtrip` | `sequenceDiagram` | work is acked then continued in background | everything is synchronous | initial ack, queue participant, background work, callback + retry + timeout |
| `pipeline / lineage` | `flowchart LR` with subgraphs | data moves through custody or transform stages | call order matters more than data shape | sources, transform stages, classification/consent, stores, consumers |
| `state-lifecycle` | `stateDiagram-v2` | an object moves between statuses | the flow is linear with no revisits | `[*] -->` start, event-labelled transitions, wait/retry states, **every** `--> [*]` terminal |
| `runbook / CI` | `flowchart TD` | a process has gates and rollback | it is a pure call chain | trigger, blocking checks, approval, rollback, verification |
| `call-chain` (default) | `flowchart TD` | none of the above; tracing code paths | — | entry, every branch, every exception, every terminal |
| `structure / service map` | `flowchart LR` with subgraphs, or `sequenceDiagram` when call order is the whole point | the question is "what exists, what calls what, and in what order" | the reader needs per-line detail | 6–12 nodes, ownership boundaries via subgraphs, external dependencies, transports, **every edge a runtime call or message numbered in execution order**, **the async mechanism named on every edge that does not block**, **no import edges**, no orphans, no unintended cycles, timeouts on external calls |
| `deployment` | `flowchart LR` with nested subgraphs | the question is "where does this run and what crosses a boundary" | the reader wants application logic, not placement | regions/networks/clusters as subgraphs, which workload runs where, stateful services, named boundary crossings |

A **structure diagram is a flow**, not a dependency graph. It answers "what happens, in what order, and what waits for what" across modules or services, so it carries an entry, numbered steps, and terminals like any other flow. It never draws an `import`, a re-export, or a type-only reference as an edge — where a shape or type is owned is prose, not an arrow. The rules are in **Structure — runtime order, never imports** in `authoring-rules.md`.

**Audience shifts the abstraction level, not the scenario.** If the user names one, honour it: a newcomer wants the happy path and no error branches; an engineer joining the team wants every branch and `file:line`; a client wants business outcomes with no internal service names; **on-call wants where it breaks — timeouts, retries, and observability touchpoints** (that reading of a flow is the `runbook` row, not `call-chain`). Ask only if the request is ambiguous about it.

## Steps

1. **Ask the focus** — `AskUserQuestion`: code focus (line-by-line) or flow focus (business logic, steps, service communication)? Then pick the scenario row. Do this before reading source; it decides how deep you need to read. Skip only if the user already said which they want.
2. Read every function to be diagrammed **in full** — not excerpts, not from memory or a prior summary. Check `git status`, the current branch, and `git diff` on those files: uncommitted refactors and a branch switch since the last diagram are both common, and the diagram must match disk. When updating an existing diagram, diff it against current source first.
3. Confirm each path still exists before trusting a remembered line number. A `grep`/`wc` reporting "No such file or directory" three times is not a cwd problem — the module was probably split into a package. Re-derive the line map with one `grep -n '^def \|^class '` per file rather than reusing stale numbers. **`grep -n` and `sed -n` are the authority for a line number, not the `Read` tool's reported numbering and not memory** — and re-read any file whose content shifts between two reads, because someone is editing it while you trace. When a traced file is modified in the working tree, say so in the intro: the citations are working-tree lines, not committed ones. See **Working-tree drift** in `references/validation.md`.
4. Trace from entry point (route, queue consumer, cron) to every terminal. For a structure diagram, trace the same way — the call order, and every `await`, concurrent gather, and background task — not the import graph.
5. Number the steps in execution order along the traced path **before** drawing, so numbering is consistent rather than patched in per element.
6. Read `references/mermaid-kinds.md`, then copy the matching `templates/*.mmd` body and fill it in per `references/taxonomy.md` and `references/authoring-rules.md`: main path first, short side branches, sparse labels, ≤12 primary elements — collapse a thin vendor wrapper into the third party it wraps rather than spending a participant on it, per **Size envelope** in `references/artifact-anatomy.md`. Add colour only when a validation failure calls for it.
7. **Write the file** — `docs_dir/diagrams/<name>.md` (create the directory if absent), from `templates/diagram-doc.md`: title, intro, then the diagram body inside one ```` ```mermaid ```` fence, per `references/artifact-anatomy.md`. Both focuses → `<name>-code.md` and `<name>-flow.md`.
8. **Write the sections below the fence** — one section per diagram element explaining why it exists, the term glossary, and what the diagram omits. Write them from the trace you already did — never from the diagram alone, which cannot tell you why. If a step's *why* is not recoverable from source, say so in `## Open questions` rather than inventing a rationale.
9. Validate per `references/validation.md`. Re-validate after every edit and immediately before handoff; an edit inside the fence desynchronises the sections that mirror it.
10. Report per **Report** below. The findings, the drift, and the five claims go in your **reply to the user** — never into the file. The file carries per-step explanation and terms only; it is not a second copy of the report.

## When this is the wrong skill

Hand off rather than forcing the flow into the wrong shape:

- The reader wants **an editable canvas** to rearrange themselves → a drawio-style tool, not diagrams-as-code.
- The reader wants **an interactive, animated walkthrough** → an HTML diagram skill (`archify`), not this one.
- The question is **"what does this class look like"**, not "what happens when" → a `classDiagram`; there is no flow to trace.
- The question is **"what depends on what"** and the answer genuinely is the import graph → that is a dependency report, not a diagram this skill writes; a structure diagram here draws calls, not imports.
- The answer is **prose or a table**, not a diagram — a two-step flow does not need a picture.
- The user wants **PlantUML/UML stereotype fidelity** (`boundary`, `control`, `«stereotype»`, mxgraph vendor stencils) → the `uml` skill. Mermaid has no such vocabulary and faking it in label text is worse than using the right tool.
- You could not establish the real code path → stop and ask for it. A diagram that lies about reality is worse than none.

## Report

Everything below goes in the reply, not the file:

- Focus and scenario used, and whether the user chose them
- File paths written/updated
- Must-include checklist: each item present, or listed as unresolved with the reason
- What went into the prose sections rather than the diagram (step rationale, glossary, omissions list, which package owns which type), and anything a reader still would not get from the file
- Source drift found (branch change, module became a package, function superseded, stale line numbers, response shapes the old diagram missed) and how reconciled
- Defects found while tracing, as Expected / Found / Impact / Proposed
- Validation: findings by code, which checks were skipped and why, correction rounds used, and each of the five claims stated separately
- Whether a diagram the new file supersedes — including the leftover `.mmd` half of an older pair — should be deleted; ask, never delete unprompted

---

Layout, granularity, and validation heuristics adapted from two MIT-licensed skills: `Agents365-ai/drawio-skill` (coded findings, mechanical legend, diagram-contract rules) and `konraddzbik/architecture-diagram-skill` (MIT © 2026 Konrad Dzbik — participant ordering, size envelope, merge/split and round-trip step rules, audience abstraction levels).
