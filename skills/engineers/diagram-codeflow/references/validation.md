# Validation

One diagram is one file. The Mermaid lives inside a ```` ```mermaid ```` fence, so the structural
checks run on an **extract** of that fence, and the prose checks run on the file itself:

```bash
c=docs_dir/diagrams/<name>.md                                   # the file
awk '/^```mermaid$/{f=1;next} f&&/^```$/{exit} f' "$c" > /tmp/diagram.mmd
d=/tmp/diagram.mmd                                              # the extracted diagram
```

If `$d` is empty, the fence is missing or misspelled — that is `E-FENCE`, and nothing else can be
judged until it is fixed. The extract is scratch: never write it back into the repository.

Report each finding as `[CODE] what is wrong (fix: <specific action>)`, so the
repair is mechanical and the report is greppable.

| code | check | fix when it fails |
|---|---|---|
| `E-FENCE` | exactly one ```` ```mermaid ```` fence in the file, closed by its own ```` ``` ```` line; the extract is non-empty | open or close the fence; split a second diagram into its own file |
| `E-ARTIFACT` | the extract contains only `%%` header + diagram; header ≤5 lines and carries purpose/entry/exits, `Traced at`, `Sources:`; no front-matter, headings, prose, legend or step table inside the fence; no sibling `.mmd` was written | move the non-diagram content below the closing fence, or into the reply; delete a stray `.mmd` |
| `E-PARSE` | first non-`%%` line of the extract is the diagram kind; every `subgraph`/`alt`/`opt`/`loop`/`par`/`critical`/`break`/`rect`/`box` has its own `end`; `activate`/`deactivate` balance | close the unpaired block; nothing else can be judged until it parses |
| `E-RESERVED` | no node id or bare label is `end`, `graph`, `subgraph`, `class`, `style`, `click`, `direction`, `default` | rename the id; quote the label |
| `E-LABEL` | labels containing `(` `)` `:` `,` `#` `{` `}` `|` are quoted; line breaks are `<br/>`, never `\n` or a raw newline; no triple-backtick inside the fence | quote the label; replace `\n` with `<br/>` |
| `W-CODE-LABEL` | no label transcribes a source expression — every label is `<call or condition> — <what it does><br/>file:line`, per **Structure — code focus only** in `authoring-rules.md` | rewrite the label as a reference to the call; move the expression, its arguments and its keyword arguments into that step's `###` section |
| `E-NO-START` | a start exists for the kind — stadium entry node / first message from the `actor` / `[*] -->` | add it, naming the concrete trigger |
| `E-DANGLING` | every branch reaches a terminal; every error response returns to the caller `actor` | add the terminal for that outcome, or the transition you failed to trace |
| `E-PUBLISH-END` | no path uses a `-.->`/`-)` publish as its only terminal | give the publishing path its own terminal; the consumer is a sibling file |
| `E-NUMBERING` | `sequenceDiagram` has `autonumber`; flowchart/state labels numbered with no gaps or reuse. **A structure diagram is numbered too** — its edges carry ordinals in execution order | renumber along the traced path |
| `E-IMPORT-EDGE` | no edge in a structure diagram is an import, a re-export, or a type-only reference; every edge is a runtime call, message, or read/write | replace it with the runtime call that actually happens, or delete the edge and put the ownership fact in the prose |
| `E-ASYNC` | every non-blocking edge names its mechanism (`await`, `asyncio.gather`, `create_task`, queue publish, thread/pool submit); fire-and-forget is drawn `-.->` / `-)`; concurrent steps share an ordinal or sit in a `par` | name the mechanism on the label; redraw a fire-and-forget as dotted |
| `E-CHECKLIST` | every must-include item for the scenario present | add it, or state it as unresolved in the reply with the reason |
| `E-ARROW-CITE` | every labelled arrow carries a `<br/>file:line`, or is declared inferred in the reply | add the emitting call site; never guess one to satisfy the check |
| `E-SOURCE` | every cited `path:line` exists at the traced commit — the ones on arrows, in the `%%` header, and in every prose section | re-derive the line map; never adjust a citation by guessing |
| `E-SECTIONS` | the file carries the required sections: one H1, intro with sha/branch/date and entry point, `## Diagram`, `## Steps` (or `## Parts`), `## Terms`, `## What the diagram deliberately omits` | write the missing section from the trace, per `artifact-anatomy.md`; never leave an empty heading |
| `E-STEPS` | one `###` per diagram element, in diagram order, numbered as the diagram numbers them — terminals and decisions included, none invented | add the missing step section; renumber to match the diagram rather than renumbering the diagram |
| `E-TERMS` | every non-plain-English term used in a node label, arrow label, or step section has a glossary row; every row cites where the term is **defined**; no row for a term the diagram never uses | add the row from source; delete the row that documents the domain at large instead of this flow |
| `W-ECHO` | step sections explain rather than restate — each one gives a reason, a consequence, or a failure mode the label does not already carry | rewrite the section around why the step exists; a section that only re-words its label is noise |
| `W-SIZE-DOC` | whole file ≤250 lines; glossary 5–20 rows | split the diagram on a process boundary and write one file per part |
| `E-NOTATION` | every construct appears in `taxonomy.md` or `mermaid-kinds.md`; no PlantUML leftovers (`@startuml`, `->>` on a `participant` line, `«...»`, `<size:`, `[->`) | replace with the documented Mermaid form |
| `W-BACKWARD-REQ` | no *request* arrow runs against participant order | reorder participants, or add the step that makes the direction real |
| `W-DEPTH` | sequence fragment bodies are indented one level per depth; ≤2 *phase* `rect` washes, wider one lighter; ≤3 depth levels. `rect` blocks wrapping the body of an `alt` / `else` branch are branch-outcome colouring per `taxonomy.md` and do not count against the phase-wash cap | re-indent; prefer sibling fragments to nested; split if 4 deep |
| `W-COLOUR` | colour via `classDef`/`:::` only, never `linkStyle`; ≤6 distinct colours; fixed meanings from `taxonomy.md` | convert to `classDef`; merge colours |
| `W-SIZE` | ≤12 nodes/participants, 3–9 steps (a request+return pair is one step), ≤6 colours | split on a process boundary; collapse a thin vendor wrapper into its third party. A flow crossing several vendors that genuinely will not fit is reported **failed, declared**, with the real counts — never trimmed to pass |
| `W-RENDER` | `mmdc` parsed the extract | see the renderer note below — report **skipped**, never passed |

## Fence check (`E-FENCE`)

```bash
echo "mermaid fences: $(grep -c '^```mermaid$' "$c")   (must be 1)"
echo "fence lines total: $(grep -c '^```' "$c")        (must be even)"
echo "extract lines: $(wc -l < "$d")                  (must be > 0)"
grep -n '^```' "$c"                                    # opener then closer, nothing interleaved
```

## Structural check (`E-PARSE`)

Run on the extract, never on the whole file — a Markdown table pipe or a heading outside the fence
is not a Mermaid construct.

```bash
echo "kind: $(grep -vE '^\s*%%' "$d" | head -1)"
echo "openers: $(grep -cE '^\s*(subgraph|alt|opt|loop|par|critical|break|rect|box)\b' "$d")  end: $(grep -cE '^\s*end\s*$' "$d")"
echo "activate: $(grep -cE '^\s*activate ' "$d")  deactivate: $(grep -cE '^\s*deactivate ' "$d")"
echo "literal backslash-n (must be 0): $(grep -c '\\n' "$d")"
echo "reserved ids (must be 0): $(grep -cE '(^|[^"[:alnum:]_])(end|graph|class|style|click|direction|default)(\[|\(|\{|-->)' "$d")"
```

`openers` and `end` must match exactly. `activate`/`deactivate` must match. Anything
non-zero on the last two lines is a finding.

## Diagram-only check (`E-ARTIFACT`)

```bash
grep -nE '^(---|#{1,6} |\| )' "$d"           # front-matter, headings, tables inside the fence — must be empty
echo "header lines: $(grep -cE '^\s*%%' "$d")   (must be <=5, all before the kind line)"
grep -nE '%%.+%%|[^ ]%%' "$d"                 # mid-line %% — not a comment in Mermaid
ls "${c%.md}.mmd" 2>/dev/null && echo "E-ARTIFACT: stray sibling .mmd"
```

## Import-edge check (`E-IMPORT-EDGE`) — structure diagrams

```bash
grep -nEi 'import|re-?export|TYPE_CHECKING|from [a-z_.]+ import|depends on|type-only' "$d"
```

Every hit is a finding on a structure diagram: the edge is describing the module graph, not
behaviour. Replace it with the runtime call, or move the ownership fact into the prose. A `%%`
header line or a `note` that mentions a `TYPE_CHECKING` guard as a *caveat* is not an edge and is
allowed — the check flags labels, so read each hit before repairing.

## Async check (`E-ASYNC`) — structure and flow diagrams

```bash
# non-blocking edges: dotted flowchart edges and sequence async arrows
grep -nE '(-\.->|-\)|--\))' "$d"
# each of those labels must name a mechanism
grep -nE '(-\.->|-\)|--\))' "$d" | grep -vEi 'await|gather|create_task|task|publish|enqueue|submit|background|fire-and-forget'
```

The second command's output is the finding list: a non-blocking edge whose label does not say
*how* it is non-blocking leaves the reader guessing whether the caller waits.

## Numbering check (`E-NUMBERING`)

```bash
grep -oE '"[0-9]+(\.[0-9]+)?\.' "$d" | tr -d '".' | sort -n | uniq -c
grep -c '^\s*autonumber' "$d"     # 1 for a sequenceDiagram
```

Gaps and reuse are findings. Two edges sharing an ordinal is **not** a finding when they run
concurrently — that is the documented way to draw a fan-out (see `taxonomy.md`), and the labels
must say so.

## Arrow citation check (`E-ARROW-CITE`)

```bash
# labelled arrows with no file:line — each hit is a finding unless the arrow is
# declared inferred in the reply
awk '$0 !~ /^[[:space:]]*%%/ \
  && ($0 ~ /\|"/ || $0 ~ /(->>|-->>|-\)|--\)|-->)[^|]*:[[:space:]]/) \
  && $0 !~ /<br\/>[A-Za-z0-9_\/.-]+:[0-9]+/ {print FNR": "$0}' "$d"
```

Two deliberate narrowings, both from real false positives:

- **Test the text *after* the arrow**, not the whole line. A node declaration inlined on an edge line (`S(["START: POST /v1/orders"]) --> N1`) contains a colon before the arrow and otherwise reports every unlabelled edge as uncited.
- **Only quoted pipe labels (`|"…"|`) count as flowchart labels.** Bare branch outcomes (`-->|yes|`, `-->|no|`) are exempt per `authoring-rules.md` — they name which way a decision went, not a call.

Anchor on `<br/>…:<digits>` rather than on the presence of a colon: a
`sequenceDiagram` message line always contains a colon, so a bare colon test passes
every uncited arrow.

## Prose check (`E-SECTIONS`, `E-STEPS`, `E-TERMS`, `W-ECHO`, `W-SIZE-DOC`)

```bash
echo "H1 count: $(grep -c '^# ' "$c")            (must be 1)"
grep -cE '^## (Diagram|Steps|Parts|Terms|What the diagram deliberately omits)$' "$c"   # must be 4
echo "step sections: $(grep -c '^### ' "$c")   diagram elements: <count from the diagram>"
grep -nE '^#{2,3} .*$' "$c" | tail -40                                  # section order and step numbering
awk '/^## Terms/{t=1;next} /^## /{t=0} t && /^\| /' "$c" | grep -vc '^| *term\|^|---'   # glossary rows: 5-20
grep -nE '^## [A-Za-z]' "$c" | awk -F: 'p&&$1-pl<3{print "empty section: "pt} {p=1;pl=$1;pt=$0}'
wc -l "$c"                                                              # <=250
```

Step count and numbering are compared against the diagram by reading both, not by a
regex — a `###` per element means per element as drawn, including terminals. Note the section
count is 4 because `## Diagram` is now one of them, and `## Steps` may legitimately be `## Parts`.

## Source check (`E-SOURCE`)

Verify citations mechanically, never by eye. One pass over the whole file covers the arrows, the
`%%` header, and every prose section at once:

Citations are usually written as `basename:line` (the subgraph or participant title carries the
directory), so the check has to search the directories the sources actually live in. Derive that
base list from the diagram's own `Sources:` header rather than hard-coding it:

```bash
# every directory that holds a cited file, plus the repo root — one per line, in a file
{ echo .; grep -ohE '[A-Za-z0-9_./-]+\.(py|ts|tsx|js|go|rb|java|kt|rs)' "$c" | xargs -n1 basename | sort -u \
  | while read f; do find . -name "$f" -not -path '*/.*' -printf '%h\n'; done; } | sort -u > /tmp/diagram-bases.txt

grep -ohE '[A-Za-z0-9_./-]+\.(py|ts|tsx|js|go|rb|java|kt|rs):[0-9]+' "$c" | sort -u | while IFS=: read p l; do
  for base in $(cat /tmp/diagram-bases.txt); do [ -f "$base/$p" ] && { printf '%-40s %s\n' "$p:$l" "$(sed -n "${l}p" "$base/$p" | cut -c1-70)"; found=1; break; }; done
  [ -z "$found" ] && echo "BAD  $p:$l — file not found"; found=
done
```

The base list goes through a **file**, iterated as `$(cat …)`, for two reasons: `IFS=:` on the outer
`read` would otherwise stop a shell variable from splitting on newlines, and `zsh` does not word-split
an unquoted variable at all. Both turn the whole list into one base and report every citation `BAD`.

A citation whose line is blank, a closing bracket, or an unrelated statement is a
finding even though the file exists: re-derive it.

**An ambiguous basename is a finding even when the check prints a line.** Two packages holding
`pipeline.py` means `pipeline.py:343` resolves to whichever the base list reaches first, and the
line it prints can look plausible while pointing at the wrong file. List the collisions before
trusting any output:

```bash
grep -ohE '[A-Za-z0-9_./-]+\.(py|ts|tsx|js|go|rb|java|kt|rs):[0-9]+' "$c" | cut -d: -f1 | sort -u | while read p; do
  n=0; for base in $(cat /tmp/diagram-bases.txt); do [ -f "$base/$p" ] && n=$((n+1)); done
  [ "$n" -gt 1 ] && echo "AMBIGUOUS  $p resolves under $n bases"
done
```

Test the **cited path**, not the basename: `recall/pipeline.py` is unambiguous even in a repo with
two `pipeline.py`, which is the point of qualifying it.

Every hit must be cited with enough path to be unique — `recall/pipeline.py:343`, not
`pipeline.py:343`. Fix the citations, not the check.

Two failure modes of the check itself, both seen in practice:

- **Every citation reported BAD means the base list is wrong, not that the diagram is wrong.** A package under `src/<pkg>/<subpkg>/` needs that directory in `$bases`. Fix the list and re-run before touching a single citation.
- **Never repair a citation from a remembered or `Read`-reported line number.** The `Read` tool's numbering can disagree with the file by one when the file changed since it was read. `grep -n '<the expression>' <file>` and `sed -n '<n>p' <file>` are the only authorities — the second confirms the line you are about to cite says what you claim.

## Working-tree drift

The line map is only valid for the bytes on disk at the moment you read them.

- Before citing, run `git status --short` on the traced files. When a file is **modified**, the citations are working-tree lines: say so in the intro (`src/<pkg>/ is modified in the working tree; the citations below are working-tree lines, not committed ones`) rather than implying the sha alone locates them.
- **Re-read any file whose mtime moves during the trace.** Two reads of the same file returning different content at the same line number is not a tool fault — someone is editing it. Re-derive that file's citations, and note the drift in the reply.
- A citation into a file that is modified now becomes wrong the moment the change is committed or reverted. That is expected; the provenance line is what tells the next reader to re-verify.

## Render (`W-RENDER`)

`mmdc -i /tmp/diagram.mmd -o /tmp/out.svg` (from `@mermaid-js/mermaid-cli`) is the
authoritative syntax check and exits non-zero on a parse error. Run it on the extract; `mmdc` also
accepts a Markdown file, but pointing it at the extract keeps the check aligned with what the other
structural checks read.

> **`mmdc` is usually not installed, and installing it pulls a headless Chromium.**
> When it is absent, report `W-RENDER` as **skipped**, not as passed. Do not
> silently claim a diagram renders.
>
> Do **not** work around this by pasting the diagram into `mermaid.live`, Kroki, or
> any hosted renderer — that publishes traced source code to a third party. Offer
> it only as an explicit choice, and only for code the user confirms is safe to
> send. Otherwise install a local renderer or leave `W-RENDER` skipped.

## Repair order

`E-FENCE` → `E-ARTIFACT` → `E-PARSE` → `E-RESERVED` / `E-LABEL` → `E-NOTATION` →
`E-NO-START` → `E-DANGLING` / `E-PUBLISH-END` → `E-IMPORT-EDGE` → `E-ASYNC` →
`E-NUMBERING` → `E-CHECKLIST` → `E-ARROW-CITE` → `E-SOURCE` → `E-SECTIONS` →
`E-STEPS` → `E-TERMS` → warnings (`W-BACKWARD-REQ` → `W-SIZE` → `W-DEPTH` →
`W-COLOUR` → `W-ECHO` → `W-SIZE-DOC`).

The prose is repaired after the diagram, never before: its step sections mirror the
diagram's elements and numbering, so fixing `E-IMPORT-EDGE`, `E-NUMBERING` or `W-SIZE` first avoids
rewriting the sections twice. `E-IMPORT-EDGE` comes before `E-NUMBERING` for the same reason —
deleting an import edge changes which steps exist to number.

A later failure is often a symptom of an earlier one, so never skip ahead. Re-extract the fence
after every edit inside it; a stale `/tmp/diagram.mmd` validates the previous draft.

## Stop rule

Keep correcting while the error count reaches a new minimum. If two consecutive
rounds do not improve on the best count, stop and report the unresolved items
truthfully. Never exceed two focused correction rounds without saying so.

## Five separate claims — never substitute one for another

1. **Parse-clean** — the fence extracts cleanly, the structural checks pass on the extract, and `mmdc` parsed it. If no renderer was available, say so instead of claiming this.
2. **Source-accurate** — every element was traced from code read in full at a known commit.
3. **Extracted vs inferred** — mark which elements you read directly and which you concluded. A call resolved through dynamic dispatch, a DI container, a decorator, or config is *inferred*; say so rather than presenting it as read. Never infer runtime causality from file proximity, an import, or naming alone. State it in **both** places: inline in the step section that depends on the inference, and as a list in the reply. A reader of the file alone must not mistake an inference for a read line.
4. **Explained** — the sections below the fence cover every diagram element, every term, and the omissions list, with each behavioural claim cited. A parse-clean diagram with stub sections is an incomplete deliverable; report it as such rather than claiming the file is done.
5. **Reviewed** — a human confirmed the diagram matches intent.

Report each independently. Passing one never implies the others. A diagram that
parses cleanly and looks good can still be wrong — and a diagram that lies about
reality has negative value, because it will be trusted. When you cannot establish
the real path, say so and ask for it; do not guess and draw.

Diagram-derived properties are claims about the *drawn model*, not proof about the
running system. "No cycles" or "every external call has a timeout" means the
diagram shows that, not that production does.
