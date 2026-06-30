# 1_find-patterns

> Find copy-ready examples and conventions in the codebase before building something new.

---

## What it does

`1_find-patterns` searches the codebase for existing implementations that match a concept or feature, then extracts complete, working code snippets you can model after. It goes beyond file paths — it reads the code and shows you naming conventions, file organization patterns, and testing structures in use.

The output covers:
- **Similar implementations** — real code snippets with location context
- **Naming conventions** — how models, jobs, services, and specs are named
- **File organization** — directory structure for the pattern
- **Testing patterns** — how analogous specs are structured
- **Recommended approach** — concrete steps based on what already exists
- **Reusable components** — existing code you can call directly

---

## When to use

- Before implementing a new feature — find the pattern to follow
- When unsure of naming conventions in an unfamiliar area
- To discover existing utilities before writing new ones
- As a research step within `2_feature` planning

---

## Install

```bash
npx skills add pdkproitf/skills@1_find-patterns
```

---

## Usage

**Claude Code:**
```
/1_find-patterns background job with retry logic
/1_find-patterns API client with authentication
/1_find-patterns pagination
```

**Other tools:**
```
@1_find-patterns <feature, pattern, or concept>
```

---

## Output

```
## Pattern Analysis: [topic]

### Similar Implementations Found

#### Example 1: [Name]
**Location**: `path/to/file.rb`
**Pattern**: [structural description]

**Code Example**:
[complete, working snippet]

### Conventions Observed

#### Naming Patterns
- Models: ...
- Jobs: ...

#### File Organization
[directory tree]

#### Testing Patterns
[example spec structure]

### Recommended Approach for [topic]
1. Create X in `path/`
2. Add Y following Z convention

### Reusable Components
- `path/to/file.rb` — what can be reused and how
```
