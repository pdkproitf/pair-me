---
name: analyze-code
description: Analyze and explain how a specific file, class, or feature works — trace data flow, logic, and dependencies with file paths and line numbers
metadata:
  phase: "orient"
  input: "file path, class name, or feature name"
  output: "structured analysis covering entry points, core logic flow, key methods, data flow, dependencies, and error handling"
  dependencies: "codebase-memory-mcp, graphify"
---

# Analyze Code

Analyze HOW a component or feature works — trace data flow, explain logic, and map dependencies. Read code thoroughly before explaining.

## When to trigger

Use this skill when the user:
- asks how a specific file, class, or feature works
- asks to trace data flow, logic, or dependencies through existing code
- asks to "explain this component" or "walk me through this implementation"

## Variables
target: $ARGUMENTS — file path, class name, or feature name

## Steps

### Step 0: Check Existing Documentation
Load context per `# WORKSPACE` → **Context Loading**, matching Tier 1 on `Files` if `target` is a path, or on `Keywords` if it's a class/feature name. Existing docs may already answer part of the analysis and save re-deriving it from scratch.

### Step 0.5: Decide Which Tools to Use (read-only)

This skill only **reads** indexes — it never builds them. Building is the `codebase-indexing`
skill's job. If an index is missing, fall back immediately; don't block on a build.

**Try codebase-memory-mcp first (structural analysis):**
1. Call `index_status`, then `search_graph()` / `trace_path()`
2. **If indexed and fresh**: Use MCP for Steps 1–2 (structural tracing)
3. **If not indexed / unavailable**: Try Step 0.5b (do not trigger `index_repository`)

**Step 0.5b: Try graphify (semantic context):**
1. Check if `.docs/indexing/graphify/` exists and try a graph query
2. **If succeeds**: Use graphify for Step 3b (business context)
3. **If both fail**: Proceed to Step 5 (manual analysis; optionally suggest running `codebase-indexing`)

### Step 1: Locate Entry Points via codebase-memory-mcp (Preferred)
- Use `search_graph(name_pattern, qn_pattern)` to find the target function/class
- Use `get_architecture()` to understand how it fits in the system layers
- Use `trace_path(function_name, mode=calls)` to find who calls this component

### Step 2: Trace Call Chain & Data Flow via codebase-memory-mcp (Preferred)
- Use `trace_path(function_name, mode=calls)` to map the full call chain
- Use `trace_path(function_name, mode=data_flow)` to trace data transformations through the call stack
- Use `get_code_snippet(qualified_name, range)` to extract exact code with line numbers

### Step 3a: Analyze Integration Points (Structural)
- Look for external service calls in traced paths
- Identify database interactions (queries, writes)
- Find job enqueuing and async operations
- Map API endpoints and HTTP calls

### Step 3b: Add Business Context via graphify (If Available)
- Query graphify to understand the semantic purpose (WHY does this component exist?)
- Identify domain entities this component operates on
- Find related components in the same business flow
- Note invariants and constraints from the domain model
- Add this context to the structural analysis for richer understanding

### Step 4: Document Error & Edge Cases
- Use code snippets to identify error handling patterns
- Note validation logic and constraints
- Document fallback mechanisms and retry patterns

### Step 5: Fallback to Manual Analysis (If Both Tools Unavailable)
- Read implementation files thoroughly
- Manually follow function call chains using grep to find callers
- Use grep to find dependencies and external service calls
- Extract code snippets for error handling and edge cases
- Read any existing comments or tests for business context

## Output Format

```
## Analysis: [Component/Feature Name]

### Overview
High-level description of what this component does and its role in the system.

### Entry Points
- `path/to/file.rb:45` — description

### Core Logic Flow
1. Step one at `file.rb:12`
2. Step two at `file.rb:34`
3. ...

### Key Methods
- `method_name` (`file.rb:56`) — what it does

### Data Flow
Input → Step → Step → Output

### Dependencies
- External: gem names, APIs
- Internal: other lib/app classes

### Error Handling
- What raises, what rescues, what gets logged
```

## Guidelines
- Include file paths and line numbers for every reference
- Follow data through the full call chain — don't stop at the surface
- Note side effects (DB writes, job enqueues, HTTP calls)
- Be specific — avoid vague descriptions
