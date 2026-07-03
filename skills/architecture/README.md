# architecture

> Map the overall system architecture from a full codebase scan.

---

## What it does

`architecture` scans the codebase as a whole — not a diff — and writes a structural overview into `docs/CONTEXT.md`: domain models, key workflows, layers, code patterns, and external dependencies. It writes into the same file `init` reads every session — not a separate architecture file — so there's one agent-context artifact per repo instead of two that can drift apart. Unlike `document`, which documents a single implemented feature, this skill maps the system broadly.

Re-running it is a reconciliation, not a rewrite: it reads the existing doc first, keeps what still matches reality, updates what's drifted, and adds what's new — including preserving any hand-written content that doesn't fit the template.

---

## When to use

- Bootstrapping architecture docs for a project that doesn't have any yet
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
docs/CONTEXT.md
```

Reports whether the file was freshly created or reconciled, and what changed.

---

## Dependencies

- Uses `locate-code` and `analyze-code` internally to map structure
- Read by `init` at the start of every session (if the file exists)
- Bootstrapped by `init`'s Research fallback when no documentation exists at all
- Shares `docs/CONTEXT.md` with `document`, which patches individual sections incrementally after each feature — see that skill's section-ownership rule
