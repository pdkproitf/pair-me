# PR body template & example

Referenced by `create-pr/SKILL.md`. Populate the sections from the spec/plan
resolved in the skill's "Source the PR content" step; only re-analyze the diff
if no plan exists.

---

## Template

If the project has its own PR template — `.github/PULL_REQUEST_TEMPLATE.md` on GitHub,
or `PULL_REQUEST_TEMPLATE.md` in the repo root or `.bitbucket/` on Bitbucket — follow
that instead. Otherwise use:

```markdown
## How
<!-- an instruction how to use it with all available env variables in table -->
## What
<!-- 1-3 sentences: the change itself, stated plainly, no rationale yet.
     If a short example (a code snippet, a before/after, a sample request/response)
     makes the change concrete, add it here as its own paragraph or a fenced block. -->

## Why
<!-- The problem this fixes and its root cause, not just the symptom.
     If there's a concrete measurement, reproduction, or incident behind it, name it
     ("measured over N cases, X rows regressed") — a claim with no evidence reads as
     an opinion. -->

## Approaches
<!-- Only include this section when there were real alternatives worth naming.
     For each: what it was, why it was rejected or accepted, and evidence if any.
     Skip this section entirely for a change with one obvious way to do it —
     don't invent alternatives to fill the section. -->

## Changes
<!-- Table: File | Change. One row per file that matters; skip mechanical/generated
     diffs. Call out anything non-obvious about the change (a dedup rule, an ordering
     guarantee, a scope decision) as a short paragraph under the table. -->

### Tests
<!-- What was tested and the result (e.g. "97 passed across test_a.py, test_b.py").
     Name any new test and what regression it guards, not just that "tests were added". -->

## Ticket / Issue Link
<!-- spec *.md file link if it exists -->

### Related
<!-- Optional: a sibling PR in another repo carrying the same fix, a linked ticket,
     prior art this builds on. Omit if there's nothing to link. -->

### Known limitations
<!-- Optional: a caveat introduced by this change that is deliberately not addressed
     here, so a reviewer doesn't have to find it themselves. Omit if there's none. -->

## Checklist
- [ ] Follows Conventional Commits
```

Check boxes only for steps that were actually completed. Omit `Approaches`,
`Related`, and `Known limitations` when there is nothing real to put in them —
an empty section reads worse than no section.

---

## Complete example

Based on a real PR (`fix(memory): surface the recalled atom without dropping its
context`) — a bug fix with a rejected alternative, a measured regression, and a
worked example.

```bash
WS=<workspace>; REPO=<repo-slug>
curl -s -u "$BITBUCKET_AUTH" -X POST -H 'Content-Type: application/json' \
  "https://api.bitbucket.org/2.0/repositories/$WS/$REPO/pullrequests" \
  --data-binary @/tmp/pr.json
```

where `/tmp/pr.json` was built (per Method D) with this `description`:

```markdown
## How
How to run / enable the feautre.
A list of env variables if have (represent in table)
Any script created, how to trigger it

## What

Recalled memory rows now reach the model as one line carrying both the fact
RZMempalace resolved and the note it came from:

    VERIFIED: has a cat named Mochi | context: talked about pets, mentioned a tabby named Mochi

Before this change the resolved fact was discarded and only the note was sent.
A row that carries no resolved fact still renders as bare content, exactly as
before.

## Why

RZMempalace returns two things per recalled row: `content`, the narrative
summary of what the user said, and `matched_fact`, the single winning atom
resolved out of that summary for the current query. The SDK client read only
`content`, so the resolved fact never reached the prompt and the model had to
re-derive it from prose that often states it only indirectly. When it could
not, it declined a question whose answer was sitting in its own context
window. This is the dominant recall failure mode — not retrieval, over-decline.

### Example

The user said, weeks ago: *"my sister Sofia moved to Lviv last spring"*. Asked
*"where does my sister live?"*, the row recalled is:

    { "content": "my sister Sofia moved to Lviv last spring",
      "matched_fact": "My sister is Sofia." }

|                      | Line sent to the model                                                                | Answer                  |
| -------------------- | ------------------------------------------------------------------------------------- | ----------------------- |
| Before               | `my sister Sofia moved to Lviv last spring`                                           | declines                |
| Atom only (rejected) | `VERIFIED: My sister is Sofia.`                                                       | declines — Lviv is gone |
| After                | `VERIFIED: My sister is Sofia. \| context: my sister Sofia moved to Lviv last spring` | "Lviv"                  |

## Approaches

**1. Keep sending only the summary (no change).** Rejected — the current bug.

**2. Replace the summary with the atom.** Rejected after measurement: the atom
is resolved for one query, so a different question of the same row often finds
its answer only in the summary. Measured over a 172-question eval, 45 rows had
the answer in the summary while the atom named something else; recall fell
from 68.6% to 53.5%.

**3. Send both, atom first, marked as certain.** Adopted — neither half
contains the other.

## Changes

| File                        | Change                                                                                                                                  |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `src/sdk/memory/client.py`  | `recall()` gained `text_of(item)`, combining `matched_fact` and `content` into the line above. `collect()` dedups on the combined text. |
| `src/memory/service.py`     | `render_memory_block()`'s header explains both halves.                                                                                  |
| `tests/test_sdk_clients.py` | Two new tests plus a `_recall_rows` helper.                                                                                             |

### Tests

97 passed across `test_sdk_clients.py`, `test_memory_service.py`,
`test_recall_query_anchoring.py`. `test_recall_keeps_the_fact_the_atom_omits`
is the regression guard for the 45-row loss in approach 2.

## Related Issue

AVA-2160

### Known limitations

`render_memory_block` truncates each item at 500 chars. A combined line is
longer than the summary alone, so a long row can now lose the tail of its
context half. `VERIFIED` leads the line, so it always survives; raising the
cap is a separate decision.

## Checklist

- [x] Follows Conventional Commits
```

The same body text works for any method and either host. Only the field name changes:

| Target                                                               | Field           |
| -------------------------------------------------------------------- | --------------- |
| `gh pr create`                                                       | `--body`        |
| GitHub MCP `create_pull_request`                                     | `body`          |
| `POST /repos/{owner}/{repo}/pulls`                                   | `"body"`        |
| `POST /2.0/repositories/{workspace}/{repo}/pullrequests` (Bitbucket) | `"description"` |

Bitbucket renders `description` as Markdown, so no reformatting is needed. Build that
JSON with `jq` or Python — interpolating this multi-line body into a shell string
breaks on the first quote or newline and returns an opaque `400`.
