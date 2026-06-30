# 1_analyze-code

> Trace how a feature or component actually works — data flow, logic, and dependencies with file paths and line numbers.

---

## What it does

`1_analyze-code` performs a deep-read of a target file, class, or feature and produces a structured analysis. It doesn't stop at the surface — it follows the full call chain to map data transformations, business rules, side effects, and integration points.

The analysis covers:
- **Entry points** — routes, jobs, initializers, configuration loading
- **Core logic flow** — step-by-step with file paths and line numbers
- **Key methods** — what each method does and where it lives
- **Data flow** — input through transformations to output
- **Dependencies** — external services, internal classes, gems/packages
- **Error handling** — what raises, what rescues, what gets logged

---

## When to use

- Understanding an unfamiliar component before modifying it
- Tracing a bug through the call chain
- Onboarding to a new area of the codebase
- As a research step before running `2_feature`

---

## Install

```bash
npx skills install 1_analyze-code
```

---

## Usage

**Claude Code:**
```
/1_analyze-code app/services/payment_processor.rb
/1_analyze-code VideoPublisher
/1_analyze-code user authentication flow
```

**Other tools:**
```
@1_analyze-code <file path, class name, or feature name>
```

---

## Output

```
## Analysis: [Component/Feature Name]

### Overview
High-level description of what this component does and its role in the system.

### Entry Points
- `path/to/file.rb:45` — description

### Core Logic Flow
1. Step one at `file.rb:12`
2. Step two at `file.rb:34`

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
