---
name: commit
description: Group git changes by logical concern and generate a commit message for each group — follows Conventional Commits 1.0.0 and commitlint rules
input: git diff or description of changes; optionally "and commit" to also run the commits
output: grouped file changes with commit message for each group; commits if asked
phase: commit
---

# Git Commit Message Guide

## Prestep: Check Context

Before running `git diff`:
- Scan conversation context for an existing description of these changes
- If context already explains what/why, use that instead of re-analyzing the diff
- Only run `git diff` if context is missing or unclear

## Role and Purpose

Analyze the changes, group file changes by logical concern, and generate one Conventional Commits 1.0.0 message per group.

Output grouped changes with commit messages only — no fluff.

If the prompt asks to commit, commit each group after user confirmation.

## Grouping Strategy

Group file changes by logical concern, e.g.:

- **By file/skill**: all changes to `init.md` in one group, `implement.md` in another
- **By feature**: all changes for "add config dependency" together
- **By type**: docs changes together, code changes together
- **By layer**: app/config changes separate from lib/spec changes

**Key principle:** one commit per logical, independently shippable concern — not one per file.

## Message Format

**Header:** `<type>(<scope>): <subject>` (72 chars max)
- type: lowercase, see Type Reference below
- scope: optional, lowercase, describes what changed
- subject: lowercase, imperative, no period

**Body:** (if needed, blank line after header, 100 chars/line)
- Explains WHAT and WHY; use only facts from the diff
- Bullet points okay

**Footer:** (if needed, blank line after body)
- Breaking changes: `BREAKING CHANGE: <description>`
- Metadata: `Closes #123`

**Breaking change:** add `!` after scope, e.g. `feat(api)!: remove old endpoint`

## Type Reference

| Type     | Description |
|----------|-------------|
| feat     | New feature |
| fix      | Bug fix |
| chore    | Routine tasks, no src/test changes |
| docs     | Documentation only |
| refactor | Code change that neither fixes a bug nor adds a feature |
| test     | Adding or correcting tests |
| style    | Formatting, whitespace (no logic change) |
| perf     | Performance improvement |
| ci       | CI configuration changes |
| build    | Build system or dependency changes |
| revert   | Reverts a previous commit |
| i18n     | Internationalization / localization |

## Output Format

For each group:

```
## Group 1: <description>
- file1.md
- file2.md

<type>(<scope>): <subject>

[optional body]

[optional footer]

---

## Group 2: <description>
- file3.md
- file4.md

<type>(<scope>): <subject>
```

Separate groups with `---`.

## Quick Checklist

- [ ] Type is lowercase and present
- [ ] Subject is imperative mood, lowercase, no period
- [ ] Subject under 72 chars
- [ ] Body explains only what changed and why (fact-based, no fluff)
- [ ] Breaking changes marked with `!` or `BREAKING CHANGE:` footer
