---
name: 9_commit
description: Group git changes by logical concern and generate a commit message for each group — follows Conventional Commits 1.0.0 and commitlint rules
input: git diff or description of changes; optionally "and commit" to also run the commits
output: grouped file changes with commit message for each group; commits if asked
phase: commit
---

# Git Commit Message Guide

## Role and Purpose

Analyze a git diff, group file changes by logical concern (feature, file, component), and generate a Conventional Commits 1.0.0 formatted message for each group.

Output grouped changes with commit messages only — no explanations, no questions beyond confirmation to commit.

Commits must follow the Conventional Commits 1.0.0 specification and the commitlint rules below.

If the prompt asks to commit, commit each group sequentially after user confirmation.

## Grouping Strategy

Group file changes by logical concern. Examples:

- **By file/skill**: all changes to `0_prime.md` in one group, all changes to `3_implement.md` in another
- **By feature**: all changes related to "add config dependency" together
- **By type**: all documentation changes together, all code changes together
- **By layer**: app/config changes separate from lib/spec changes

**Key principle:** Each group should represent one logical, shippable unit of work.

Output format:
```
## Group 1: <description>
- file1.md
- file2.md

<commit message>

---

## Group 2: <description>
- file3.md
- file4.md

<commit message>

---
```

## Conventional Commits & commitlint Rules

1. The commit message must start with a type (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`, `ci`, `build`, `revert`, `i18n`, etc.), all lower-case.
2. The type may be followed by an optional lower-case scope in parentheses, e.g. `fix(parser)`. No empty type or scope.
3. An optional `!` may be added after type/scope to indicate a breaking change.
4. The type/scope/! must be followed by a colon and a space.
5. The subject (description) must:
   - Start in lower-case (not sentence, start, pascal, or upper case)
   - Not end with a period or exclamation mark
   - Not be empty
   - Be at most 72 characters
   - Be imperative, concise, and have no trailing whitespace
6. A blank line must separate the subject from the body (if present).
7. The body (optional):
   - Each line at most 100 characters
   - Begins with a blank line
   - Explains what and why, using only info from the diff
8. A blank line must separate the body from the footer (if present).
9. The footer (optional):
   - Each line at most 100 characters
   - Used for metadata (e.g. `BREAKING CHANGE:`, `Closes #123`)
10. Breaking changes must be indicated by `!` in the header and/or a `BREAKING CHANGE:` footer.
11. For dependency updates, the body must list all updated direct dependencies with old → new versions.

## Output Format

### Grouped Changes with Commit Messages

For each logical group of file changes:

```
## Group 1: <description of what changed>
- file1.md
- file2.md
- file3.md

<type>(<scope>): <short description>

[optional body]

[optional footer(s)]

---

## Group 2: <description of what changed>
- file4.md
- file5.md

<type>(<scope>): <short description>

[optional body]
```

**Grouping logic:**
- One commit per logical concern (not one per file)
- Group related file changes that address the same purpose
- Each group should be independently meaningful and shippable
- Separate groups with `---` for clarity

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

## Writing Rules

### Subject Line
- Imperative mood, lower-case only
- No period or exclamation mark at the end
- Maximum 72 characters
- No trailing whitespace
- Include scope when it adds clarity

### Body
- Bullet points with `-` (optional)
- Maximum 100 characters per line
- Explain WHAT and WHY using only factual information from the diff
- Omit if the subject line is self-explanatory

### Footer
- Format: `<token>: <value>`
- Maximum 100 characters per line
- Use for metadata (e.g. `BREAKING CHANGE:`, `Closes #123`)
