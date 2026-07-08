---
name: architecture
description: Map the whole system into a `docs_context` documentation layer from a full codebase scan — creates or reconciles the business and system docs.
input: no arguments — scans the current codebase
output: the `docs_context` file (business content, default `.docs/CONTEXT.md`) plus its companion `system.md` in the same directory, created or reconciled
phase: orient
---

# Map Architecture

Scan the codebase as a whole — not a git diff — and produce a **two-file `docs_context` layer**
that agents load at session init. Unlike `document`, which documents one feature from its diff,
this skill maps the system broadly and is meant to be re-run periodically so the layer never
drifts from reality.

The layer is two plain files, not a subdirectory:

| File | Answers | Read by |
|---|---|---|
| `docs_context` (default: `.docs/CONTEXT.md`) | What does it do? Business flows, user journeys, domain concepts, owned capabilities. | anyone designing a feature or writing stories — PM-readable |
| `system.md` (same directory as `docs_context`, e.g. `.docs/system.md`) | How is it built and what does it expose? Layers, data flow, domain models, invariants, file index, plus API surface, outbound dependencies, and event contracts. | developers, engineers, and AI agents touching code or integrating with it |

`docs_context` is the config key and its target file *is* the business file — a short link at
the top of it points to `system.md`. There is no directory to create.

The exact markdown for each of these lives in its own template file under [templates/](templates/)
— see Step 3.

## When to trigger

Use this skill when the user:
- asks to map, document, or refresh the overall system architecture
- wants the `docs_context` layer created or reconciled with the current codebase
- asks for a broad structural overview spanning the whole codebase, not a single feature's diff

---

## Step 1 — Detect framework, source root, and layer state

**Framework** (check project root):
- **Spring Boot** (Java): `pom.xml`/`build.gradle` contains `spring-boot-starter` → source root = deepest common package (e.g. `src/main/java/com/example/service/`)
- **Rails** (Ruby): `Gemfile` contains `rails` → source root = `app/`
- **Nuxt 3** (JS/TS): `nuxt.config.ts`/`.js` → source root = `server/` (BFF) or `pages/` (frontend)
- **Unknown**: degrade gracefully — still produce both files; omit `system.md`'s interface sections (API Surface, External Dependencies, Events) if no HTTP/messaging/outbound surface is found.

**Layer state** — check for `docs_context` (default: `.docs/CONTEXT.md`) and its sibling `system.md`:
- **Absent → fresh generation.** Produce both files from the fact set (Step 2).
- **Present → reconcile.** Read each existing file fully. This is a reconcile, not a rewrite: keep sections that still match reality, update drifted ones, add sections for new structure, and **preserve hand-written prose** by folding it into the nearest matching section. Treat each template's line-cap and required sections as authoritative.
- **Legacy directory layer** (`.context/business.md` + `.context/system.md`, or the older `.context/business.md` + `interface.md` + `implementation.md`): migrate — write the merged content to the current `docs_context` file and its sibling `system.md`, then delete the old `.context/` directory. Report the migration explicitly.
- **Legacy monolithic file** (an existing `.docs/CONTEXT.md` or `.docs/ARCHITECTURE.md` with everything in one file, no companion `system.md`): migrate — split its content into the business sections (→ `docs_context`) and technical/interface sections (→ new `system.md`), per each template. Report the migration explicitly.

Determine the `service` name (kebab-case) from the build file / directory name — used in every file's frontmatter.

---

## Step 2 — Mine the codebase once

Do this once and reuse the fact set for every file. Each row is a concrete search, not a guess:

| Signal to gather | How |
|---|---|
| Layers + File Index | list top-level dirs under the source root — one becomes one Architecture Map row / File Index glob |
| Tech stack + entry points | build file deps; `gradlew`/`rake`/`package.json` scripts |
| Domain models | `entity/**` (Spring), `app/models/**` (Rails) + their relations |
| Data flow | trace 2–3 representative chains: controller → service → repo/producer |
| Endpoints | `@GetMapping`/`@PostMapping`/… + `@RequestMapping` prefixes (Spring); `routes.rb` (Rails); `server/api/**` (Nuxt) |
| Outbound deps | `*Client`/`*Service` with `@*Exchange` or `WebClient`/HTTP; resolve URL constants; group by target system + base-URL env var |
| Events | `@RabbitListener`/`@KafkaListener` + queues/routing-keys from `application.yml`; producers; Avro schemas in `src/main/avro/**` |
| Journeys (business) | endpoint groups + listener classes + integration-test method names (`whenX_thenY`) → `[inferred]` bullets |
| Purpose + concepts (business) | `README` intro, `docs/`, OpenAPI `info.description`; entity names → concept glossary |

Prefer `locate-code` / `analyze-code` for the traversal rather than ad-hoc grepping.

---

## Step 3 — Render (or reconcile) each file

Each output file has a dedicated template under [templates/](templates/). Open the template
for the file you're about to write — it has the exact markdown skeleton plus any
authoring notes specific to that file (what needs judgment, what to skip, what naming must
stay consistent across a reconcile). Templates use `[docs_context]` as a placeholder to
resolve to the actual configured path when writing the file.

| Output file | Template |
|---|---|
| `docs_context` (CONTEXT.md) | [templates/context.md](templates/context.md) |
| `system.md` (sibling of `docs_context`) | [templates/system.md](templates/system.md) |

Rules that apply across both:
- Every file starts with frontmatter (line 1 = `---`) carrying
  `type / service / version / updated / tags`; set `updated:` to today. On reconcile, bump
  `updated:` only for files whose content actually changed.
- `system.md` has three independently-skippable interface sections (API Surface, External
  Dependencies, Events) — omit a section the service genuinely has none of; the rest of the
  file is always produced. See the template's authoring notes for the per-section rules.

---

## Step 4 — Self-verify (definition of done)

Inline checks — no external linter required:

- **Line caps**: `wc -l` per file ≤ its template's limit (`docs_context` ≤100, system ≤250).
- **Required headings**: grep each `##`/`###` heading the corresponding template requires.
- **Frontmatter**: line 1 is `---`; `type/service/version/updated/tags` all present; `updated` = today.
- **File Index paths** (`system.md` only): every `src/...` glob resolves on disk (`ls`/glob).
- **No legacy leftovers**: no `.context/` directory remains; no monolithic file without a `system.md` sibling.
- **No leftovers**: `grep -n 'TODO\|FIXME\|<!-- fill in'` returns nothing.

Fix and re-check until all pass. Only then report done.

---

## Step 5 — Check README accuracy (flag only)

Compare `README.md`'s claims against what the scan found:
- capabilities/integrations it mentions that no longer exist
- significant capabilities the scan found that it omits

List mismatches under a `README.md may be stale:` heading as suggestions. **Never edit `README.md`** — it's human-voiced prose.

---

## Report

State fresh-generation vs reconcile. List each file as **created / reconciled (what changed) / unchanged / skipped (why)**. Confirm Step 4 self-verification passed. Append the `README.md may be stale:` list if Step 5 found anything.
