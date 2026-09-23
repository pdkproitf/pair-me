# diagram-codeflow

> Turn a code flow into one Mermaid diagram plus the prose that explains every step and term.

---

## What it does

`diagram-codeflow` asks one question first — **code focus** (line-by-line control flow) or **flow focus** (business logic, steps, service communication) — then picks the Mermaid diagram kind that fits the scenario, with a must-include checklist for that kind. It writes a single markdown file holding the diagram in one ```mermaid fence (parse-clean, with a `%%` provenance header and nothing else in the fence), followed by a per-step explanation, a glossary defining every term used, and an explicit list of what was left out.

It also handles the maintenance cases: updating an existing diagram against current source, splitting one oversized diagram into per-stage diagrams, annotating the steps of a diagram someone else wrote, and fixing a Mermaid parse error.

---

## When to use

- Documenting a request path, pipeline, worker chain, call chain, or module structure
- An existing diagram has drifted from the code and needs to be re-derived
- One diagram has grown too large and should be split per stage
- A Mermaid block fails to parse and needs repair

---

## Install

```bash
npx skills add pdkproitf/skills@diagram-codeflow
```

---

## Usage

**Claude Code:**
```
/diagram-codeflow the checkout request path
/diagram-codeflow update docs/diagrams/ingest-pipeline.md
```

**Other tools:**
```
@diagram-codeflow <flow, file, or existing diagram to update>
```

---

## Output

One file per diagram at `docs_dir/diagrams/<name>.md`:

```
%% provenance header — source files and commit the diagram was derived from
<one mermaid fence, parse-clean>

## Steps
1. <step> — what happens, where in the code

## Terms
- <term> — definition

## Not covered
- <what was deliberately left out and why>
```
