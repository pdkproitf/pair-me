---
name: find-patterns
description: Find existing code patterns, conventions, and copy-ready examples in the codebase for a given feature or concept
input: feature, pattern, or concept to find examples of
output: code snippets, naming conventions, file organization patterns, and recommended approach based on what exists
phase: orient
---

# Find Patterns

Find existing implementations, conventions, and code examples to model after when building something new.

## Variables
topic: $ARGUMENTS — feature, pattern, or concept to find examples of

## Steps

### Step 1: Pattern Recognition
- Search for similar feature names and keywords
- Look for components that solve analogous problems
- Find files with comparable structure

### Step 2: Example Extraction
- Read located files to get actual code snippets
- Extract complete, working examples — not fragments
- Show usage in context

### Step 3: Convention Analysis
- Note naming patterns (classes, methods, files)
- Identify file organization conventions
- Document testing patterns in use

## Output Format

```
## Pattern Analysis: [topic]

### Similar Implementations Found

#### Example 1: [Name]
**Location**: `path/to/file.rb`
**Pattern**: [brief structural description]

**Code Example**:
[relevant snippet]

#### Example 2: [Name]
...

### Conventions Observed

#### Naming Patterns
- Models: ...
- Jobs: ...
- Lib classes: ...
- Specs: ...

#### File Organization
[directory tree showing pattern]

#### Testing Patterns
[example spec structure]

### Recommended Approach for [topic]
Based on existing patterns:
1. Create X in `path/`
2. Add Y following Z convention
3. ...

### Reusable Components
- `path/to/file.rb` — what can be reused and how
```

## Guidelines
- Provide complete, working code snippets — not fragments
- Show enough surrounding context to understand usage
- Include requires/imports when relevant
- Focus on patterns actually used in this codebase, not general advice
