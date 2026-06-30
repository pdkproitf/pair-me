# 6_resume_work

> Restore a saved session and continue implementation from the last checkpoint.

---

## What it does

`6_resume_work` reads a session summary created by `5_save_progress` and reconstructs full working context before continuing. It doesn't rely on memory from a prior conversation — it re-reads the session file, the implementation plan, the research document, and recent git history to rebuild an accurate mental model.

It runs five steps:
1. **Load session context** — reads the session file (or lists recent sessions to choose from)
2. **Restore full context** — reads the plan, research doc, and recent commits
3. **Rebuild mental model** — presents a concise status summary: where we left off, current state, immediate next steps
4. **Restore working state** — applies any stashed changes, verifies the environment
5. **Continue implementation** — picks up from the first unchecked `- [ ]` in the plan

---

## When to use

- Returning to a previously paused feature
- Starting a new session on existing in-progress work
- Recovering from an interrupted session
- After switching branches back to a saved task

---

## Install

```bash
npx skills add pdkproitf/skills@6_resume_work
```

---

## Usage

**Claude Code:**
```
/6_resume_work docs/sessions/001_feature-name.md
/6_resume_work
```

**Other tools:**
```
@6_resume_work [path to session summary]
```

If no path is provided, the skill lists recent sessions in `docs/sessions/` and asks you to choose.

---

## Output

```
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

## Dependencies

- Reads session files written by `5_save_progress`
- Invokes `3_implement` when a full plan phase needs to be executed
