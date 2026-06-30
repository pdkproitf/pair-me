---
name: 6_resume_work
description: Resume previously saved work — restores session context from sessions_dir, rebuilds mental model, and continues from the first unchecked plan step
input: optional path to a session summary file; if omitted, lists recent sessions to choose from
output: restored context summary and continuation of implementation from last checkpoint
phase: checkpoint
dependencies: [.claude/workspace.md] # this is just a note but it doesn't actually load or search for this file
---

# Resume Work

Resume previously saved work by restoring full context and continuing implementation.

## When to Use

- Returning to a previously paused feature
- Starting a new session on existing work
- Switching back to a saved task
- Recovering from an interrupted session

---

## Step 1 — Load Session Context

Use `sessions_dir` (default: `docs/sessions/`) from `# WORKSPACE`.

If a session file path was provided as an argument, read it directly.

If no path was provided, list recent sessions and ask the user to choose:

```bash
ls -la docs/sessions/   # or the discovered sessions_dir value
```

---

## Step 2 — Restore Full Context

Read in this order:
1. **Session summary** — understand where work left off
2. **Implementation plan** — see overall progress and unchecked steps
3. **Research document** — refresh technical context (path is in the session summary frontmatter)
4. **Recent commits** — review completed work

```bash
git status
git log --oneline -10
git stash list
```

---

## Step 3 — Rebuild Mental Model

Present a brief context summary to the user:

```markdown
## Resuming: [Feature Name]

### Where We Left Off
- Working on: [Specific task]
- Phase: [X of Y]
- Last action: [What was being done]

### Current State
- [ ] Tests passing: [status]
- [ ] Build successful: [status]
- [ ] Uncommitted changes: [list]

### Immediate Next Steps
1. [First action to take]
2. [Second action]
3. [Continue with plan phase X]
```

---

## Step 4 — Restore Working State

1. Apply any stashed changes if appropriate
2. Verify environment by running tests
3. Restore the todo list — update with current tasks based on the session summary

---

## Step 5 — Continue Implementation

Identify the first unchecked `- [ ]` item in the plan and continue from there. Invoke the `3_implement` skill with the plan file path if a full phase needs to be executed.

---

## Step 6 — Communicate Status

```markdown
✅ Context restored successfully!

📋 Resuming: [Feature Name]
📍 Current Phase: [X of Y]
🎯 Next Task: [Specific task]

Previous session:
- Duration: [X hours]
- Completed: [Y tasks]
- Remaining: [Z tasks]

Continuing with [specific next action]...
```

---

## Guidelines

- **Verify state before continuing** — don't assume the codebase matches the session summary
- **Run tests first** to confirm a clean slate before adding more changes
- **Update stale plans** if the codebase has evolved since the session was saved
- **Check for resolved blockers** — an open question from last session may already have an answer
- **Refresh context fully** — never rely on memory from a prior session
