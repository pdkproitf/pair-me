# implement

> Execute an approved spec — phase by phase, with verification and commits after each phase.

---

## What it does

`implement` reads a spec file produced by `feature` and executes it end to end. It follows the plan exactly, adapts only when the codebase has evolved since the spec was written, and surfaces mismatches rather than silently deviating.

For each phase it:
1. Implements every step in the phase
2. Runs the spec's validation commands and fixes failures
3. Updates checkboxes in the spec (`- [ ]` → `- [x]`)
4. Reports what was done and waits for confirmation before moving on
5. Commits the phase using the `commit` skill

If the spec has checkmarks from a prior session, it picks up from the first unchecked step.

---

## When to use

- Executing a plan created by `feature`
- Resuming interrupted implementation (works from checkboxes)
- When `resume_work` identifies the next unchecked spec step

---

## Install

```bash
npx skills add pdkproitf/skills@implement
```

---

## Usage

**Claude Code:**
```
/implement docs/specs/1711234567-feature-add-retry-logic.md
```

**Other tools:**
```
@implement <path to spec file>
```

If no path is provided, the skill will ask for one before proceeding.

---

## Output

After all phases complete:
- One bullet per phase summarising what was implemented
- Files created or modified
- Verification results (commands run and their outcomes)
- Output of `git diff --stat`

---

## Dependencies

- Reads spec files written by `feature`
- Invokes `commit` for each completed phase
- Optionally invokes `8_test` for a full suite run at the end
