---
name: find-patterns
description: Find existing code patterns, conventions, and copy-ready examples in the codebase for a given feature or concept
metadata:
  phase: "orient"
  input: "feature, pattern, or concept to find examples of"
  output: "code snippets, naming conventions, file organization patterns, and recommended approach based on what exists"
  dependencies: "graphify, codebase-memory-mcp"
---

# Find Patterns

Find existing implementations, conventions, and code examples to model after when building something new.

## When to trigger

Use this skill when the user:
- asks "how do we usually do X" or "is there an existing pattern for Y"
- wants copy-ready code examples and conventions before building something new
- asks to find similar implementations already in the codebase

## Variables
topic: $ARGUMENTS — feature, pattern, or concept to find examples of

## Steps

### Step 0: Documentation Lookup (Always First)
- Load context per `# WORKSPACE` → **Context Loading**, matching Tier 1 on `Keywords` against `topic`
- Read any matching `core_docs_dir` files — they may already document the convention you're looking for
- If found, use as context for the graph search below

### Step 1: Decide Which Tool to Use (read-only)

This skill only **reads** indexes — it never builds them. Building is the `codebase-indexing`
skill's job. If an index is missing, fall back immediately; don't block on a build.

**Try graphify first (semantic pattern clustering):**
1. Check if `.docs/indexing/graphify/` exists and try a graph query
2. **If succeeds**: Proceed to Step 2a (graphify-based pattern discovery via community detection)
3. **If unavailable**: Try Step 1b

**Step 1b: Try codebase-memory-mcp:**
1. Call `index_status`, then `search_graph()`
2. **If indexed and fresh**: Proceed to Step 2b (MCP pattern discovery)
3. **If not indexed / both unavailable**: Proceed to Step 3 (manual search; optionally suggest running `codebase-indexing`)

### Step 2a: Pattern Discovery via graphify (Preferred)
- Use graphify's community detection to find clusters of semantically similar implementations
- Query for nodes related to `topic` (e.g., "all components handling payments")
- Identify common patterns across the cluster (naming, file organization, dependencies)
- Extract representative examples from each pattern cluster
- Use `get_code_snippet(qualified_name, range)` if available to pull exact code
- List code patterns with cluster relationships

### Step 2b: Pattern Discovery via codebase-memory-mcp
- Use `search_graph(label_pattern, qn_pattern)` to find similar classes, functions, and patterns
- Use `query_graph(query)` for structural pattern queries (e.g., "all classes matching X pattern")
- Use `search_code(pattern)` to find text patterns across codebase
- Use `get_code_snippet(qualified_name, range)` to extract complete examples with precise line ranges

### Step 3: Manual Pattern Search (Last Resort)
- Manually search for similar feature names and keywords using grep and find
- Look for components that solve analogous problems
- Read located files to get actual code snippets
- Extract complete, working examples — not fragments
- Show usage in context

### Step 4: Convention Analysis & Recommendations
- Note naming patterns (classes, methods, files) from discovered examples
- Identify file organization conventions
- Document testing patterns in use
- Extract recommendations based on identified patterns
- Highlight which patterns appear most frequently (indicates team consensus)

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
