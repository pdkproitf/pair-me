---
name: document
description: Generate feature documentation by analyzing code changes and specifications — creates markdown docs in docs/core/ with conditional context
input: "[adw_id] [spec_path] [screenshots_dir] — all optional; generates docs based on git diff analysis"
output: path to created documentation file; updates context_dictionary.md registry
phase: document
dependencies: [.claude/workspace.md] # this is just a note but it doesn't actually load or search for this file
---

# Document Feature

Generate concise markdown documentation for implemented features by analyzing code changes and specifications.

## When to trigger

Use this skill when the user:
- asks to document a feature that was just implemented
- wants markdown docs generated from a git diff, spec, or screenshots
- asks to update `docs/core/` or the context dictionary after finishing a feature

## Variables

- `adw_id`: Identifier like `adw-42` (optional)
- `spec_path`: Path to specification file (optional)
- `screenshots_dir`: Directory containing screenshot files (optional)

Parse arguments in order: if first arg looks like `adw-*`, treat as adw_id; next arg is spec_path; next is screenshots_dir.

---

## Step 1 — Ensure Conditional Context Registry

Check if `docs_dictionary_dir` exists. If not, create it with this template:

```markdown
# Conditional Documentation Context

Auto-generated registry of feature documentation and when to load it.

## Features

<!-- Auto-generated entries below -->

```

Read `docs_dictionary_dir` to understand existing conditional documentation structure.

---

## Step 2 — Analyze Changes

1. Run `git diff origin/main --stat` to see files changed and lines modified
2. Run `git diff origin/main --name-only` to get the list of changed files
3. For significant changes (>50 lines), run `git diff origin/main <file>` on specific files to understand implementation details

---

## Step 3 — Read Specification (if provided)

If `spec_path` is provided:
- Read the specification file to understand original requirements, goals, and success criteria
- Use this to frame documentation around what was requested vs what was built

---

## Step 4 — Analyze and Copy Screenshots (if provided)

If `screenshots_dir` is provided:
1. List and examine screenshot files
2. Create `docs/assets/` subdirectory if it doesn't exist
3. Copy all `*.png` files from `screenshots_dir` to `docs/assets/`
4. Reference screenshots in documentation using relative paths (e.g., `assets/screenshot-name.png`)

---

## Step 5 — Generate Documentation

Create a new documentation file in `docs/core/` following this format:

### Filename

```
feature-{descriptive-name}.md
feature-{adw_id}-{descriptive-name}.md  (if adw_id provided)
```

### Content Template

```markdown
# <Feature Title>

**ADW ID:** <adw_id or omit>
**Date:** <current date>
**Specification:** <spec_path or "N/A">

## Overview

<2-3 sentence summary of what was built and why>

## Screenshots

<If screenshots provided>
![<Description>](assets/<screenshot-filename.png>)

## What Was Built

- <Component/feature 1>
- <Component/feature 2>

## Technical Implementation
- <Brief description of how the feature was implemented, key classes, methods, and workflows>
- <Any important design decisions or trade-offs>
- <Any relevant diagrams in Mermaid format if applicable>
- <Any relevant code patterns, algorithms, or data structures used>
### Files Modified

- `<file_path>`: <what was changed/added>

### Key Changes

<Describe the most important technical changes in 3-5 bullet points>

## How to Use

1. <Step 1>
2. <Step 2>

## Configuration

<Any configuration options, environment variables, or settings>

## Testing

<Brief description of how to test the feature>

## Notes

<Any additional context, limitations, or future considerations>
```

---

## Step 6 — Patch Context Doc (if relevant)

Check `docs_context` (default: `docs/CONTEXT.md`).

- If it doesn't exist, skip this step. Creating it from a single feature's diff would give a biased, incomplete picture — that's what the `architecture` skill's full codebase scan is for.
- If it exists, check whether this feature changed something structural: a new layer, module, or service boundary; a new domain model; a changed workflow between existing components; a new external dependency or integration point; a new code convention. Most features don't — they add to an existing layer, not restructure it. If none of these apply, skip this step.
- If something structural did change, patch only the matching section (**Layers**, **Domain Models**, **Key Workflows**, **External Dependencies**, or **Code Patterns & Conventions**) — do not regenerate the file or touch unrelated sections. Update the "Last updated" date.
- **Never touch the Overview section.** It's a holistic summary of the whole system — a single feature's diff isn't enough context to update it accurately. Leave it for `architecture`'s full-scan runs, or a human edit.

---

## Step 7 — Update Conditional Documentation Registry

1. Read `docs_dictionary_dir`
2. Add an entry for the new documentation file with appropriate conditions
3. Entry format:

```markdown
### <Feature Name>

**File:** `docs/core/feature-{name}.md`
**When to load:** <condition description>
**Keywords:** <comma-separated keywords for matching>
**Files:** <comma-separated paths or globs this feature touches, from Step 2's changed-file list>
```

`Files` lets file-path-driven skills (e.g. analyzing a specific file) match this entry without needing keyword overlap.

---

## Step 8 — Update Core References

1. If `docs/TODO.md` exists, check if any tasks reference this feature and mark them complete
2. Check whether this feature is significant enough that a human-facing `README.md` should mention it — a new top-level capability or user-visible behavior, not an internal refactor or implementation detail. If so, note a suggested one-line addition in the Output below. **Never edit `README.md` directly** — it's human-voiced prose; only `README.md`'s author should decide wording, ordering, and whether it's worth mentioning at all.

---

## Output

Return exclusively the path to the documentation file created.

If documentation includes diagrams, represent them in Mermaid format.

If Step 8.2 found something README-worthy, append it after the path:
```
Suggested README.md addition: <one-line summary of the new capability>
```

Example output:
```
docs/core/feature-adw-42-cover-photo-improvements.md
```
