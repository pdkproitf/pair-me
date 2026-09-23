# Artifact anatomy — one file per diagram

One diagram is one file: `docs_dir/diagrams/<name>.md`. It holds the diagram inside a single
fenced ```` ```mermaid ```` block, then the sections that explain it. This file governs both
halves of that document — the fence and the prose. There is never a sibling `.mmd`.

````markdown
# <Name> — <code|flow> focus

Traced at <sha> on <branch>, <YYYY-MM-DD>. Entry point: `<file>:<line>`.

## Diagram

```mermaid
%% <name> — <entry point>. Exits: <list>.
%% Traced at <sha> on <branch>, <YYYY-MM-DD>.
%% Sources: path/a.py:10-90 · path/b.py:31-77
%% Siblings: <other>.md (the consumer of the queue below)
sequenceDiagram
    autonumber
    ...
```

## Steps
...
````

## The fence contract

Everything in this section applies **inside** the ```` ```mermaid ```` block.

- **Exactly one mermaid fence per file.** More than one is two diagrams in one document — split them into two files. A second fenced block of any other language inside the diagram section is also a defect.
- **Nothing but Mermaid inside it.** No front-matter, no headings, no prose, no legend, no step table. All of that lives after the closing fence, or in the reply.
- **The first line inside the fence is the diagram kind, or a `%%` comment.** Nothing else parses.
- **The `%%` header is capped at 5 lines** and carries only: purpose + entry + exits, `traced_at` (sha, branch, date), `Sources:` (repo-relative `path:line` ranges), and `Siblings:` when the flow is split. Renderers ignore `%%` lines, so the picture stays diagram-only.
- **`%%` only at the start of a line.** A trailing `%%` after content is not a comment in Mermaid and will end up in the label.
- **No `%%` commentary in the body.** If a step needs explaining, it needs a `note` (sequence, state), a better label, or its `## Steps` section — see **Annotations** in `authoring-rules.md`.
- **The fence is closed with its own ```` ``` ```` line.** An unclosed fence swallows the rest of the document; every renderer then shows one broken code block and no prose.
- **The `%%` header does not link to the prose below it.** The header is reserved for provenance, and the sections below are in the same file anyway.

The diagram must still stand alone as a picture — `file:line` on labels, a `note` for a caveat,
honest node names. A reader who exports the rendered SVG has none of the prose in front of them.

## Required sections

Sections in this order. Omit an optional section rather than emitting an empty heading.

| section | required | holds |
|---|---|---|
| `# <Name> — <focus> focus` | yes | title only, one H1 per file |
| intro paragraph | yes | the traced commit, branch and date, then the entry point with its `file:line` |
| `## Diagram` | yes | exactly one ```` ```mermaid ```` fence and nothing else |
| `## Steps` | yes | one `###` per diagram element, in diagram order, ids matching the diagram's numbering |
| `## Terms` | yes | the glossary — see below |
| `## What the diagram deliberately omits` | yes | the plumbing skipped by the focus, so a reader never mistakes absence for non-existence |
| `## Open questions` | when any exist | anything you could not resolve from source, and what would resolve it |
| `## Related` | when siblings exist | each sibling file and what it covers |

A structure diagram whose elements are parts rather than ordered steps may title that section
`## Parts` instead of `## Steps` — but only when the diagram genuinely has no execution order,
which after the **Structure — runtime order, never imports** rules in `authoring-rules.md` is
rare. Default to `## Steps`.

Cap the whole file at 250 lines. Longer means the diagram is too big — split it per **Splitting**
below and write one file per part.

## Per-step sections

One `###` per element the diagram draws, including terminals and decisions, using the diagram's
own step number and label so the picture and the prose can be read together:

```markdown
### 3 — Did the extractor return any claim?

`if not extraction.claims: return []` at `pipeline.py:76`.

Most conversational turns hold no durable fact, so the early return is the normal
case, not an error case. Aliases from step 2 are already persisted at this point and
survive the empty return.
```

Each section carries, in this order:

1. **The code** — the deciding expression, call, or guard, with its `file:line`. **The prose is the
   only place source may be quoted**: the argument list, the keyword arguments, the exact condition
   belong here, because the label carries a reference instead (see **Structure — code focus only**
   in `authoring-rules.md`). Quote the expression when it is short; name it when it is not.
2. **Why the step exists** — the invariant, business rule, or failure mode it protects. This is
   the paragraph that cannot be recovered from the diagram, so it is the one that earns the prose.
3. **Consequences a reader would otherwise get wrong** — ordering guarantees, what survives a
   partial failure, what is skipped when a dependency is unconfigured, which over-fetch multiplier
   feeds which cut.

Rules:

- **Explain, never restate.** "Step 4 embeds the claim" is the label again. Why the embed is
  skipped when no vector index is configured, and what recall loses then, is the explanation.
- **Every claim about behaviour carries a `file:line`** — same standard as the diagram's arrows,
  checked by `E-SOURCE`.
- **Source comments that state a reason are worth quoting**, with their line range. A comment
  explaining an ordering choice is the author's own answer to "why"; paraphrasing it loses
  authority.
- **Mark inferred behaviour as inferred**, inline. A call resolved through dynamic dispatch, DI, a
  decorator, or config is inferred; say so in the step that depends on it rather than only in the
  reply.
- **Defects found while tracing go in the step that owns them**, as a short
  `**Defect worth knowing:**` note — expected, found, impact. The Expected / Found / Impact /
  Proposed form still goes in the reply; the file carries enough for a reader of the doc alone to
  not be misled.

## `## Terms`

The glossary is what lets someone outside the team read the diagram at all. Define every term that
appears in a node label, an arrow label, or a step section and is not plain English:

- domain nouns (`claim`, `tenant`, `alias`, `supersede`)
- status values and enum members (`active`, `superseded`, `CURRENT`, `HISTORICAL`)
- named scores, weights, and thresholds (`semantic_weight`, `graph_distance`, IDF)
- infrastructure names a reader may not know is a store versus a service
- identifiers that look self-explanatory but are not (`observed_at` versus `valid_from`)

One row per term:

```markdown
| term | means | defined at |
|---|---|---|
| claim | one subject-predicate-object fact with provenance and a validity window | `models.py:34` |
| superseded | status of a claim replaced by a newer one; the row is kept, never deleted | `store.py:140-172` |
| observed_at | when the system heard the fact — **not** an assertion about when it was true | `models.py:41` |
```

Rules:

- **Definitions come from source, not from the name.** A term whose meaning you could only guess is
  an open question, not a glossary row.
- **Contrast the pairs a reader will conflate** — `observed_at` versus `valid_from`, `superseded`
  versus deleted, `limit` versus the over-fetch multiplier. The contrast is the definition.
- **Cite where each term is defined**, not where it is used.
- 5–20 rows. Fewer means the diagram used plain English throughout, which is fine — keep the
  section and say so in one line. More means the diagram is too big.
- No term that appears nowhere in the diagram or the steps. The glossary documents this flow, not
  the domain at large.

## Naming and ids

- Files: `docs_dir/diagrams/<kebab-name>.md`. Both focuses → `<name>-code.md` and `<name>-flow.md`. Split flows → `<name>-<stage>.md`, one file per stage.
- Node/participant ids: `^[A-Za-z][A-Za-z0-9_]*$`, unique, semantic and stable so a later update diffs cleanly. Prefix by role: `SVC_`, `Q_`, `DB_`, `EXT_`.
- **`end` is a reserved word and breaks a flowchart if used as a node id or bare label.** Same for `graph`, `subgraph`, `class`, `click`, `style`, `direction`, `default`. Quote the label (`X["end of stream"]`) and never name a node `end`.
- Quote any label containing `(`, `)`, `:`, `,`, `#`, `{`, `}`, `|`, or a leading digit: `A["order.total > limit?"]`. In a `sequenceDiagram` message the text after `:` runs to end of line and needs no quoting, but a literal `;` or `#` there is still safest avoided.
- Multi-line labels use `<br/>`. Never a raw newline, never `\n` — Mermaid renders `\n` literally.
- **Never write a triple-backtick inside the fence.** It closes the diagram early. A label needing a code voice uses plain text or single backticks.

## Size envelope

Enforce as a check, not a preference.

| bound | value | remedy when exceeded |
|---|---|---|
| primary elements per diagram | ≤12 nodes or participants (6–12 for a structure / service map) | split on a process boundary |
| steps on one traced path | 3–9 | fewer than 3 is not a flow, it's one call — fold it into the caller's diagram. More than 9 means implementation detail crept into a flow-focus diagram, or the flow spans a process boundary and should split. For a `sequenceDiagram`, count a request+return pair as **one** step, not two |
| distinct colours | ≤6 | two stores stay one colour and are distinguished by label and node shape, never by inventing a seventh colour |
| whole file | ≤250 lines | split the diagram; do not thin the explanations to fit |

**Collapse a thin vendor wrapper into the vendor it wraps.** A class whose whole job is to hold a
client and forward one call — a transcriber, a responder, a planner, an embedder, an index adapter —
is not a participant worth a lifeline. Draw the third party (`xAI Grok API — third party`) and cite
the wrapper's call site on the arrow; name the wrapper class in the `###` section and the glossary.
This is what keeps a multi-vendor flow inside 12 participants without hiding a boundary crossing:
the vendor legs all stay drawn, the forwarding layers do not.

**A flow crossing several vendors legitimately exceeds `3–9` steps.** One chat turn touching five
third parties cannot be nine messages. Do not thin it to fit and do not split a single request into
files that no longer match a deploy unit: report `W-SIZE` as **failed, declared**, with the real
counts and why the flow is one story. A declared deviation is honest; a diagram trimmed to satisfy
the check is not.

## Splitting one flow into several files

Split on process boundaries — a queue hop, a request/worker handoff, a cron entry —
never mid-function. Each file is then independently readable and covers one deploy
unit's behaviour.

**Is it its own diagram?** It is, only if you can name it after a goal ("checkout an
order") and it has its own trigger and its own outcomes. If it is a sub-step of a
bigger story, it is a step inside that diagram. If it is the same shape as an
existing diagram with one parameter different, it is the same diagram — note the
variant in the reply instead of duplicating.

- Every file gets its own start and its own full set of terminals.
- The `%%` header's `Siblings:` line names the files on either side; its first line names this file's entry and exits.
- A function fully expanded in a sibling file appears here as ONE element plus a `note` giving its `file:line` and "fully expanded in `<sibling>.md`". Expanding it twice guarantees the two copies drift.
- Cross-boundary publishes point at the queue element and name the consuming file.
- A diagram never ends by flowing into another file.
- `## Related` lists sibling files by basename, one line each, saying what that file covers so a reader can pick without opening it.

## Style

The prose sections are normal prose, full sentences, no telegraphese — they are read by humans who
did not watch the trace. Present tense, active voice. Follow the project's writing conventions
where the workspace defines them.
