# document

> Generate feature documentation from code changes and specs — creates a markdown doc and registers it in the conditional context index.

---

## What it does

`document` analyzes `git diff origin/main` to understand what was built, optionally reads the original spec for requirements context, and writes a structured markdown doc to `docs/core/`. It also updates `context_dictionary.md` — a registry that tells the AI when to load each doc based on keywords, so documentation surfaces automatically when relevant.

The generated doc covers:
- Overview of what was built and why
- Screenshots (if provided, copied to `docs/assets/`)
- What was built (components, features)
- Technical implementation (files modified, key changes)
- How to use it
- Configuration options
- Testing guidance
- Notes and future considerations

---

## When to use

- After completing a feature — document what was built before closing the branch
- When a spec exists and you want the doc to reference original requirements
- To keep `docs/core/` current after significant changes

---

## Install

```bash
npx skills add pdkproitf/skills@document
```

---

## Usage

**Claude Code:**
```
/document
/document adw-42
/document adw-42 docs/specs/1711234567-feature-adw-42-add-retry.md
/document adw-42 docs/specs/feature.md ~/Desktop/screenshots
```

**Other tools:**
```
@document [adw_id] [spec_path] [screenshots_dir]
```

All arguments are optional. Without arguments, the skill derives everything from the current git diff.

---

## Output

Returns the path to the created documentation file:

```
docs/core/feature-add-retry-logic.md
docs/core/feature-adw-42-add-retry-logic.md
```

Also updates `context_dictionary.md` with an entry for the new doc, enabling automatic context loading in future sessions.
