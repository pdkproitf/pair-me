# 0_prime

> Load project context before starting any task.

Prime your AI with the full picture of the codebase — docs, domain models, active work, and core conventions — so every task starts from a complete mental model.

---

## What it does

`0_prime` reads the project's documentation layer in a fixed order:

1. `README.md` — what the app is and who uses it
2. `docs/CONTEXT.md` — runtime context and domain overview
3. `docs/core/*.md` — core domain documentation
4. `docs/TODO.md` — active work areas

If the documentation layer is missing, it falls back to code exploration: it runs `1_locate-code` to map where key concepts live, then `1_analyze-code` to understand how they fit together.

After reading, it reports a summary covering domain models, key workflows, and active work areas.

---

## When to use

- At the start of any new session before implementing or planning
- After switching to an unfamiliar part of the codebase
- As a dependency — other skills (`2_feature`, `3_implement`) invoke it automatically

---

## Install

```bash
npx skills add pdkproitf/skills@0_prime
```

---

## Usage

**Claude Code:**
```
/0_prime
```

**Other tools:**
```
@0_prime
```

No arguments needed. The skill reads project context and reports automatically.

---

## Output

A structured summary covering:
- What the app does and who uses it
- Key domain models and their relationships
- Main workflows (e.g. how a feature flows end-to-end)
- Active work areas from `docs/TODO.md`
