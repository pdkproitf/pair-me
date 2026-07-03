# save_progress

> Checkpoint your work — commit WIP, update the plan, and write a session summary you can resume from later.

---

## What it does

`save_progress` creates a complete handoff artifact when you need to pause work. It captures everything the next session needs to pick up exactly where you left off — no reconstructing context from scratch.

It runs four steps:
1. **Assess state** — reviews conversation history, git status, active plan, and todo list
2. **Commit code** — stages and commits meaningful changes as a WIP commit
3. **Update the plan** — appends a progress checkpoint to the active spec file with completed tasks, current state, blockers, and next steps
4. **Write a session summary** — saves a numbered `NNN_feature.md` file to `docs/sessions/` with duration, accomplishments, decisions, open questions, and resume instructions

---

## When to use

- Stopping mid-implementation
- Switching to another task or feature
- End of a work session
- Before any context switch where work must be resumed later

---

## Install

```bash
npx skills add pdkproitf/skills@save_progress
```

---

## Usage

**Claude Code:**
```
/save_progress
```

**Other tools:**
```
@save_progress
```

No arguments needed. The skill reads everything it needs from the current session and git state.

---

## Output

```
✅ Progress saved successfully!

📁 Session summary: docs/sessions/001_feature-name.md
📋 Plan updated: docs/specs/1711234567-feature-name.md
💾 Commits created: [list]

To resume: invoke the resume_work skill with docs/sessions/001_feature-name.md
```

---

## Dependencies

- Invokes `commit` to generate and confirm commit messages
- Pairs with `resume_work` to restore session context
