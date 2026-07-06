---
name: architecture
description: Map the whole system into a `docs_context` documentation layer from a full codebase scan — creates or reconciles business / interface / implementation docs.
input: no arguments — scans the current codebase
output: the `docs_context` layer (business.md, interface.md, implementation.md), created or reconciled
phase: orient
---

# Map Architecture

Scan the codebase as a whole — not a git diff — and produce a **multi-file `docs_context` layer**
(default: `.docs/core`) that agents load selectively. Unlike `document`, which documents one
feature from its diff, this skill maps the system broadly and is meant to be re-run periodically
so the layer never drifts from reality.

Output is split by consumer, not one monolith, so an agent designing a feature and an agent
implementing one load only what they need:

| File | Answers | Read by |
|---|---|---|
| `docs_context`/business.md | What does it do? User journeys, domain concepts, owned capabilities. | anyone designing a feature or writing stories |
| `docs_context`/interface.md | What does it expose, call, and consume/produce? API surface, outbound dependencies, event contracts. | feature design and integration work |
| `docs_context`/implementation.md | How is it built? Layers, data flow, domain models, invariants, file index. | anyone touching code |

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
- **Unknown**: degrade gracefully — still produce `business.md` + `implementation.md`; skip `interface.md` if no HTTP/messaging/outbound surface is found.

**Layer state** — check for `docs_context` (default: `.context/`):
- **Absent → fresh generation.** Produce every file from the fact set (Step 2).
- **Present → reconcile.** Read each existing file fully. This is a reconcile, not a rewrite: keep sections that still match reality, update drifted ones, add sections for new structure, and **preserve hand-written prose** by folding it into the nearest matching section. Treat each template's line-cap and required sections as authoritative.

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
| `docs_context`/business.md | [templates/business.md](templates/business.md) |
| `docs_context`/interface.md | [templates/interface.md](templates/interface.md) |
| `docs_context`/implementation.md | [templates/implementation.md](templates/implementation.md) |

Rules that apply across all of them:
- Every file starts with frontmatter (line 1 = `---`) carrying
  `type / service / version / updated / tags`; set `updated:` to today. On reconcile, bump
  `updated:` only for files whose content actually changed.
- `interface.md` has three independently-skippable sections (API Surface, Dependencies,
  Events) — omit a section the service genuinely has none of, and skip the whole file only
  if all three are empty. See the template's authoring notes for the per-section rules.

---

## Step 4 — Self-verify (definition of done)

Inline checks — no external linter required:

- **Line caps**: `wc -l` per file ≤ its template's limit (implementation ≤150, business ≤100, interface ≤200).
- **Required headings**: grep each `##`/`###` heading the corresponding template requires.
- **Frontmatter**: line 1 is `---`; `type/service/version/updated/tags` all present; `updated` = today.
- **File Index paths** (`implementation.md` only): every `src/...` glob resolves on disk (`ls`/glob).
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
