# init

> Load project context before starting any task.

Prime your AI with the full picture of the codebase — docs, domain models, active work, and core conventions — so every task starts from a complete mental model.

---

## What it does

`init` reads the project's documentation layer in a fixed order:

0. **[Optional] Index the codebase** — if `codebase-memory-mcp` is available and the project isn't indexed yet, it builds the code graph. This accelerates all downstream code search operations.
1. `README.md` — what the app is and who uses it
2. `docs/CONTEXT.md` — the single agent-context artifact: domain models, key workflows, layers, patterns, and external dependencies, maintained by `architecture` and `document`
3. `docs/core/*.md` — only the entries whose keywords match the current task, via `doc_dictionary.md`
4. `docs/TODO.md` — active work areas; created empty if missing (a trivial write, done unconditionally)

If there's no documentation at all yet, it falls back to code exploration: `locate-code` to map where key concepts live, `analyze-code` to understand how they fit together, and `architecture` to write `docs/CONTEXT.md` so future sessions don't redo this research. Both of these skills now use `codebase-memory-mcp` when available (see step 0 above). If only `CONTEXT.md` specifically is missing (other docs exist), it doesn't auto-generate it — that's a full codebase scan and too heavy to run on every session start. It just flags the gap and suggests running `architecture` directly.

After reading, it reports a compact orientation summary — not a restatement of every doc's contents — covering domain models, system structure, key workflows, and active work areas.

---

## When to use

- At the start of any new session before implementing or planning
- After switching to an unfamiliar part of the codebase
- As a dependency — other skills (`feature`, `implement`) invoke it automatically

---

## Install

```bash
npx skills add pdkproitf/skills@init
```

---

## Usage

**Claude Code:**
```
/init
```

**Other tools:**
```
@init
```

No arguments needed. The skill reads project context and reports automatically.

---

## Output

A structured summary covering:
- What the app does and who uses it
- System structure — key layers and modules
- Key domain models and their relationships
- Main workflows (e.g. how a feature flows end-to-end)
- Active work areas from `docs/TODO.md`
