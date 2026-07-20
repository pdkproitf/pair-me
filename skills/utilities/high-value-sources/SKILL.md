---
name: high-value-sources
description: >-
  Find and rank the highest-value web sources on ANY topic — technical, business,
  academic, or current-events. Use whenever the user wants to research a topic,
  tool, company, market, claim, or concept and get a vetted, ranked list of the
  best places to read — "find the best resources on X", "what should I read to
  learn X", "research this company/market for me", "where's the authoritative
  source for X", or when they paste a topic, prompt, or link and want more like it.
  Trigger even without the word "sources" — if they're asking where to learn
  something or which source is credible, use this. Produces a ranked shortlist
  with a transparent score and reason per source, adapting criteria to the topic's
  domain (dev: GitHub/specs/docs; business: filings/analyst research; academic:
  citations/peer review; news: outlet track record/corroboration).
---

# High-Value Sources

Your job is to act as an expert research librarian: take a topic, prompt, or link
and return a **ranked shortlist of 10–15 genuinely high-value sources** — the ones
a knowledgeable practitioner in that field would actually send a colleague, not the
top of a generic search page. This works for any domain — a software library, a
company's financials, a scientific claim, a breaking news story, a historical
question.

The value you add is *judgment*. Anyone can paste a search query. What matters is
separating authoritative, current, well-supported material from SEO filler, stale
content, PR dressed as journalism, and AI-generated content mills — and being
transparent about *why* each source earned its rank.

## The workflow

Run these four steps in order. Don't skip step 1, and don't pad the list in step 3
just to hit a number — a tight list of 8 excellent sources beats 15 padded with
mediocrity.

### Step 1 — Confirm intent (only when it's genuinely unclear)

The user gives you one of three input shapes:

- **A topic** — e.g., "Raft consensus algorithm"
- **A prompt / question** — e.g., "how do I do zero-downtime Postgres migrations"
- **A link** — e.g., a GitHub repo or blog post, meaning "find sources like/about this"

Before searching, decide whether you actually understand what they want. If the
request is clear, **skip straight to searching** — don't manufacture friction. Ask a
brief clarifying question only when a real fork exists that would change which
sources you return. Good reasons to ask:

- **Ambiguous scope** — "Rust async" could mean the language feature, a specific
  runtime (Tokio/async-std), or the theory. Which layer?
- **Audience/level unknown and it matters** — beginner tutorials vs. deep internals
  are almost disjoint sets of sources.
- **Intent behind a link is unclear** — do they want sources *about* this project,
  *alternatives* to it, or *prerequisite* concepts to understand it?
- **A term is overloaded** — "Prometheus" (monitoring vs. the ML tool vs. the myth).

When you ask, ask *one* focused question and offer your best guess as the default so
they can just say "yes." Never ask more than necessary. If you can infer the answer
confidently from context, state your assumption in one line and proceed.

### Step 2 — Identify the domain, and load its signal notes

What counts as "authoritative" differs by field — a GitHub star count means nothing
for a market-sizing question, and a citation count means nothing for a JS framework.
Classify the topic into one (or a blend) of these domains and, if it's not the
technical/dev default, read the matching reference file before searching — it lists
the domain's specific high-value source types, what to search for, and domain-
specific red flags on top of the universal ones below:

- **Technical / dev** (software, tools, protocols, infra) — the default; the
  criteria in this file already cover it (GitHub signals, docs, specs).
- **Business** (companies, markets, industries, deals, strategy) — read
  `references/business.md`.
- **Academic / research** (papers, studies, scientific or empirical claims) — read
  `references/academic.md`.
- **News / current events** (breaking stories, ongoing situations, public figures) —
  read `references/news.md`.

If a topic spans domains (e.g., "is this AI startup's technology actually novel" is
both business and technical), read both relevant references and blend the source
types — don't force it into one bucket.

### Step 3 — Search broadly, then verify the top candidates

Cast a wide net first, then narrow. Aim to *find* ~20–30 candidates so you can
*keep* the best 10–15.

**Search tactics** (use several — different queries surface different corners; swap
in the domain-specific query patterns from the reference file you loaded in step 2):

- Run multiple `WebSearch` queries with varied phrasing: the plain topic, plus
  qualifiers suited to the domain (technical: + "documentation", "RFC"/"spec",
  "github", "postmortem"; business: + "10-K", "earnings call", "market size",
  "competitors"; academic: + "meta-analysis", "systematic review", site:scholar
  patterns; news: + the specific date/event, "primary source", the named
  officials/agencies involved), and the exact question if one was given.
- Go where the relevant field's practitioners actually vet things — see the
  domain reference for the specific list (official docs and standards bodies for
  technical; regulatory filings and analyst research for business; peer-reviewed
  journals and preprint servers for academic; wire services and named-reporter
  bylines for news).
- If given a **link**, fetch it first to understand it, then search for its author/
  organization, the subject's name, "alternatives to X" or "criticism of X", and
  the concepts or claims it depends on.

**Verify the top candidates — don't rank on search snippets alone.** For your
leading contenders (roughly the top 8–10), open the page with `mcp__workspace__web_fetch`
(or the Chrome tools if it's JS-heavy and returns an empty shell) to confirm:

- It actually exists and loads (no 404 / parked domain / paywall-only stub).
- The content genuinely matches the topic — not a keyword-stuffed near-miss.
- It's current enough to trust (check dates; see the recency signal below).
- Check the domain's specific corroborating signal: for a **GitHub repo**, stars,
  last commit date, and whether it's archived (40k stars but dead since 2019 is a
  different recommendation than 3k stars shipping weekly); for a **paper**,
  citation count and venue; for a **company claim**, whether it's corroborated in
  a filing or independent report; for a **news claim**, whether other outlets have
  independently confirmed it or are all citing the same single source.

Verification is what makes this skill trustworthy. A ranked list built only on
snippets is just a prettier search page.

Two failure modes to watch for even after you've "verified" a page loads:

- **A page loading isn't the same as a page being worth including.** If a fetch
  succeeds but the thread has near-zero engagement (a handful of points, one
  unanswered comment, no real discussion), that's a weak source even though it's a
  real URL — score it accordingly rather than treating "it loaded" as a stamp of
  quality. Conversely, if a link fails to fetch, don't keep it in the list on the
  strength of a search snippet alone — either find a working alternative (the
  original primary document is often more reliable than a news writeup about it)
  or drop it.
- **A WebSearch summary is not verification.** Search results sometimes editorialize
  or state things confidently that aren't true (e.g. calling a look-alike domain
  "official"). Treat the search summary as a lead to check, not a fact to repeat —
  the only thing that counts as verified is what you actually saw when you opened
  the page yourself.
- **Check status, not just content, for issues/threads/tickets.** A GitHub issue,
  forum thread, or ticket can read as substantive but be closed, "not planned,"
  locked, or superseded — and that status is real information (a maintainer
  formally declining to act on something is a different fact than an open,
  unresolved question). Plain-text fetching tools often strip this status out of
  the rendered content, so don't assume open/unresolved by default — actively look
  for it, and if you can't confirm the status, say so explicitly rather than
  presenting the thread as if it's still live.

### Step 4 — Score, rank, and present

Score each surviving source against the universal criteria below, layered with the
domain-specific notes from step 2, sort best → weakest, and present the ranked list
in chat using the output format at the end.

## What makes a source high-value

These signals apply across domains — they're what "authoritative and trustworthy"
cashes out to no matter the field, just with different concrete examples per domain
(see the reference files). Use judgment: a stellar score on relevance and authority
can outweigh a weak one on popularity, and vice versa. No single signal is decisive.

1. **Relevance / intent-match.** Does it answer *what was actually asked*, at the
   right depth and level? A brilliant article on the wrong sub-topic is worthless
   here. This is the first filter — off-topic sources don't make the list at all.

2. **Authority of the publisher/author.** Who's behind it? Ranked highest to lowest:
   the official project/vendor docs and the maintainers themselves → standards
   bodies and primary specs → recognized domain experts with a track record →
   reputable engineering orgs → competent independent practitioners → anonymous or
   unverifiable authors. Check whether the author has real standing (their other
   work, their role, whether the community cites them).

3. **Primary over secondary.** Prefer the original source — the spec, the source
   code, the paper, the maintainer's own writeup — over a blog that summarizes it.
   Secondary sources are valuable when they *add* something (a clear explanation, a
   worked example, benchmarks) rather than just rephrasing the primary.

4. **Community endorsement / social proof.** Real signals that knowledgeable people
   trust it: GitHub stars **and** forks **and** recent activity (not stars alone —
   a maintained 2k-star repo often beats an abandoned 30k-star one); citation count
   for papers; substantive HN/Reddit/Lobsters discussion; being referenced *by other
   authoritative sources*. Cross-corroboration matters: if three independent trusted
   sources point to the same reference, that's a strong signal.

5. **Recency & maintenance.** Is it current for the topic's pace? Fast-moving areas
   (JS frameworks, LLM tooling, cloud APIs) demand recent material — a 2021 tutorial
   may describe a deprecated API. Stable topics (TCP, sorting algorithms, SQL
   fundamentals) tolerate older sources fine. Always check the publish/update date
   and, for repos, the last-commit date.

6. **Authenticity & independence.** Is this real, first-hand material — or a content
   farm, an SEO "best 10 X" affiliate page, undisclosed AI slop, or scraped/
   plagiarized text? Prefer independent, vendor-neutral analysis over marketing
   dressed as documentation. Note (don't necessarily disqualify) commercial conflicts
   of interest — a vendor's own benchmark showing they win deserves a raised eyebrow.

7. **Depth, rigor & evidence.** Does it show its work — cite sources, include runnable
   code, real benchmarks, reproducible steps — or just assert? Comprehensive,
   well-reasoned material outranks shallow overviews.

8. **Clarity & usability.** Well-structured, readable, and actually accessible.
   Paywalls, login walls, and heavy region-locking lower practical value even when
   the content is good — flag these so the user isn't surprised.

### Red flags that should sink or exclude a source

- Content farms and SEO listicles ("Top 15 Best X in 2026") with thin, generic text.
- Undisclosed AI-generated filler — vague, repetitive, confidently wrong, no author.
- Affiliate-/ad-driven "reviews" whose real goal is the referral click.
- Outdated tutorials for deprecated versions presented as current.
- Scraped or plagiarized content (often a reworded copy of a better primary source).
- Abandoned projects — repos archived or dead for years — unless the topic is
  explicitly historical.
- Engagement-bait and unverifiable claims with no citations, code, or evidence.

## Scoring

Give each source a score out of 100 so the ranking is transparent and the user can
see *why* one beat another. Use this weighting as a guide (adjust with judgment, and
tell the user if you deviate for a good reason):

- Relevance / intent-match — 25
- Authority (publisher/author + primary-source bonus) — 25
- Community endorsement / social proof — 20
- Recency & maintenance — 15
- Authenticity, independence, depth & evidence — 15

Don't present these as false precision — a source is "92, tier A" not "92.4". Group
into rough tiers so the shape is clear at a glance: **A (must-read, ~85+)**,
**B (solid, ~70–84)**, **C (situational / niche, ~55–69)**. Anything below ~55
usually shouldn't make the list — mention it only if the user needs volume or the
topic is thin.

## Output format

Present the ranked list directly in chat, best first. Lead with a one-line read on
the topic and how many strong sources you found, then the ranked entries, then a
short closing note.

For each source use this shape:

```
**N. [Title](URL)** — Score/100 · Tier X
Type: <official docs / repo / spec / paper / blog / discussion>  ·  <key signal, e.g. "24k★, active">
Why: <one or two sentences — what it is and why it earned this rank>
```

Keep "Why" concrete and comparative — say what this source gives that others don't,
not generic praise. After the list, add a brief note covering: any strong caveats
(paywalls, staleness, bias), what to read *first* if they only have time for one or
two, and — if the topic split into sub-areas — a one-line pointer to which sources
cover which.

**Example entry:**

```
**1. [Raft paper — "In Search of an Understandable Consensus Algorithm"](https://raft.github.io/raft.pdf)** — 96/100 · Tier A
Type: primary paper (Ongaro & Ousterhout, Stanford)  ·  the canonical source, cited everywhere
Why: The original Raft paper — every other resource derives from this. Readable by design, and the definitive reference for the algorithm's guarantees and edge cases.
```

**Always close with a plain link block** — every URL from the ranked list, one per
line, no markdown, no numbering, no titles. This is what makes the list actually
usable: the user can select-all and paste it straight into NotebookLM, a reading-
list app, or anywhere else that wants raw URLs rather than formatted markdown.

```
https://example.com/first-source
https://example.com/second-source
```

## Notes on doing this well

- **Diversity beats redundancy.** Ten blog posts all rephrasing the same doc is a
  worse list than one doc + one deep dive + one repo + one discussion thread. Aim to
  cover the topic from complementary angles (reference, tutorial, real-world use,
  critique).
- **Be honest about thin topics — this matters more than hitting a number.** If you
  couldn't verify a good spread of high-value sources, it's completely fine to
  return 5, 8, or 10 instead of 15. Never invent, guess at, or include a source you
  couldn't actually verify just to pad the count — a shorter, fully-real list is
  strictly better than a longer one with a made-up or unverifiable entry in it.
- **Show your reasoning, not just your verdict.** The user should be able to disagree
  with a ranking because they can see the basis for it. That transparency is the
  whole point.
- **Cite what you used.** Every entry is a real URL you found (and ideally verified),
  so the list doubles as its own sources section.
- **Reference files:** `references/business.md`, `references/academic.md`, and
  `references/news.md` hold domain-specific source types, search patterns, and red
  flags — read whichever applies in step 2 before you start searching. The
  technical/dev domain's specifics already live in this file, so no separate
  reference is needed for it.
