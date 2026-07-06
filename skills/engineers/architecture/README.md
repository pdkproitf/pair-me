# architecture

> Map the overall system architecture from a full codebase scan into a `docs_context` documentation layer.

---

## What it does

`architecture` scans the codebase as a whole — not a diff — and writes a purpose-split
documentation layer, split by who reads it rather than into one growing monolith:
`docs_context`/business.md (journeys, concepts, owned capabilities — for anyone designing a
feature), `docs_context`/interface.md (API surface, outbound dependencies, event contracts — for
feature design and integration work), and `docs_context`/implementation.md (layers, data flow,
domain models, invariants, file index — for anyone touching code). `docs_context` defaults to
`.context/` — override it via `central-config`/`central-workspace` if you want it elsewhere.
Unlike `document`, which documents a single implemented feature, this skill maps the system
broadly.

Re-running it is a reconciliation, not a rewrite: it reads each existing file first, keeps what
still matches reality, updates what's drifted, and adds what's new — including preserving any
hand-written content that doesn't fit the template. Each file has its own template (under the
skill's `templates/` directory) with a line-cap and required sections, checked by a self-verify
pass before the skill reports done.

It also compares its findings against `README.md` and flags mismatches (stale claims,
undocumented capabilities) in its report — but never edits `README.md` directly. That file is
human-voiced prose; only its author decides wording and what's worth mentioning.

---

## When to use

- Bootstrapping the `docs_context` layer for a project that doesn't have any yet
- Periodically, to correct drift that `document`'s incremental per-feature patches don't catch
- Before a major refactor, to get an accurate picture of current structure

---

## Install

```bash
npx skills add pdkproitf/skills@architecture
```

---

## Usage

**Claude Code:**
```
/architecture
```

**Other tools:**
```
@architecture
```

No arguments needed. The skill scans the current codebase and reports automatically.

---

## Output

```
{docs_context}/business.md
{docs_context}/interface.md         (skipped if no API surface, outbound deps, or events at all)
{docs_context}/implementation.md
```

`{docs_context}` defaults to `.context/`.

Reports whether this was a fresh generation or a reconciliation, and for each file: created,
reconciled (with what changed), unchanged, or skipped (with why). If `README.md` looks stale
compared to the scan, lists those mismatches too — as suggestions, not changes already made.

---

## Dependencies

- Uses `locate-code` and `analyze-code` internally to map structure
- Each output file's exact markdown skeleton lives in this skill's `templates/` directory
- Reads `docs_context` from the project's `config.md`/`workspace.md` if `central-config`/`central-workspace` has been run; otherwise defaults to `.context/`
