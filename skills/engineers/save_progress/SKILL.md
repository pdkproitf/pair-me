---
name: save_progress
description: Save progress checkpoint — commits work in progress, updates the active plan's checkboxes, and writes a numbered session summary to sessions_dir
input: no arguments — reads session context, git state, and active plan automatically
output: WIP commit, updated plan file, session summary saved to sessions_dir as NNN_feature.md
phase: checkpoint
dependencies: [.claude/workspace.md] # this is just a note but it doesn't actually load or search for this file
---

# Save Progress

Create a comprehensive progress checkpoint when pausing work on a feature.

## When to trigger

- Stopping mid-implementation
- Switching to another task or feature
- End of a work session
- Before a break or context switch

---

## Step 1 — Assess Current State

1. Review the conversation history to understand what was being worked on
2. Run `git status` to check for uncommitted changes
3. Identify the active plan file if one exists
4. Review the todo list for current tasks

---

## Step 2 — Save Code Progress

Commit meaningful work:

```bash
git status
git diff
git add [specific files]
git commit -m "WIP: [Feature] - [Current state]"
```

If changes are not commit-ready, note:
- Files with unsaved changes
- Why they weren't committed
- What needs to be done before they can be committed

---

## Step 3 — Update Plan Document

If working from a plan, append a progress checkpoint to it:

```markdown
## Progress Checkpoint - [Date Time]

### Work Completed This Session
- [x] Specific task completed
- [x] Another completed item
- [ ] Partially complete task (50% done)

### Current State
- **Active File**: `path/to/file:123`
- **Current Task**: [What you were doing]
- **Blockers**: [Any issues encountered]

### Local Changes
- Modified: `file1` - Added validation logic
- Modified: `file2` - Partial refactor
- Untracked: `test.tmp` - Temporary test file

### Next Steps
1. [Immediate next action]
2. [Following task]
3. [Subsequent work]

### Context Notes
- [Important discovery or decision]
- [Gotcha to remember]
- [Dependency to check]

### Commands to Resume
```bash
# To continue exactly where we left off:
git status
# invoke implement skill with the plan file path
```
```

---

## Step 4 — Create Session Summary

Use `sessions_dir` (default: `docs/sessions/`) and `research_dir` (default: `docs/research/`) from `# WORKSPACE`.

Check existing files in `sessions_dir` to determine the next sequential number (001, 002, …).

Save as `NNN_feature.md` with this structure:

```markdown
---
date: [ISO timestamp]
feature: [Feature name]
plan: [path to plan file]
research: [path to research file if exists]
status: in_progress
last_commit: [git hash]
---

# Session Summary: [Feature Name]

## Session Duration
- Started: [timestamp]
- Ended: [timestamp]
- Duration: [X hours Y minutes]

## Objectives
- [What we set out to do]

## Accomplishments
- [What was actually completed]

## Discoveries
- [Important findings]

## Decisions Made
- [Architecture choices]
- [Trade-offs accepted]

## Open Questions
- [Unresolved issues]

## File Changes
```bash
git diff --stat HEAD~N..HEAD
```

## Test Status
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing completed

## Ready to Resume
To continue this work:
1. Read this session summary
2. Check plan: `[plan path]`
3. Review research: `[research path if exists]`
4. Continue with: [specific next action]
```

---

## Step 5 — Clean Up

1. Commit all meaningful changes using the `commit` skill
2. Update the todo list to reflect the saved state
3. Present summary to the user:

```
✅ Progress saved successfully!

📁 Session summary: [sessions_dir][NNN_feature.md]
📋 Plan updated: [plan path]
💾 Commits created: [list]

To resume: invoke the resume_work skill with [sessions_dir][NNN_feature.md]
```

---

## Guidelines

- **Always commit meaningful work** — don't leave important changes uncommitted
- **Be specific in notes** — future sessions need clear context, not summaries
- **Include commands** — make resuming as close to copy-paste as possible
- **Document blockers** — explain why work stopped, not just that it stopped
