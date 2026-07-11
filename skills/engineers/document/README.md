# document

Generate feature documentation from code changes and specs — creates markdown docs and registers them in the conditional context index.

---

## What it does

**Analyzes and documents:**
- Diffs against `origin/main` to understand what was built
- Original spec (optional) for requirements context
- Creates structured markdown doc in `docs/core/`
- Updates `doc_dictionary.md` registry for automatic context loading

**Patches existing docs:**
- Updates `docs/CONTEXT.md` sections if feature changed something structural (new layer, domain model, workflow, dependency, convention)
- Never patches Overview section (needs full-system view — use `architecture` skill instead)
- Never creates `CONTEXT.md` from scratch (too narrow a view)

**README suggestions:**
- Flags suggested one-line additions for human-facing `README.md`
- Never edits `README.md` directly (wording/voice is a human's call)

**Generated doc sections:**
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

- After completing a feature — document before closing the branch
- When a spec exists — reference original requirements
- After significant changes — keep `docs/core/` current

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

**All arguments optional:**
- Without arguments: derives everything from current git diff
- `adw_id`: optional identifier (e.g. `adw-42`)
- `spec_path`: optional path to spec file
- `screenshots_dir`: optional directory of screenshots

---

## Output

**Generated documentation file:**
```
docs/core/feature-add-retry-logic.md
docs/core/feature-adw-42-add-retry-logic.md
```

**Registry update:**
- Updates `doc_dictionary.md` with new entry
- Enables automatic context loading in future sessions

**README suggestions:**
- If feature is significant: suggests one-line addition for human review
