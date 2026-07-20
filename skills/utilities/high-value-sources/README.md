# high-value-sources

## Problem

Search results are noisy. Asking "what should I read about X" usually returns a
generic top-10 list dominated by SEO filler, stale tutorials, and content-farm
listicles — not what a knowledgeable practitioner would actually recommend.

## Solution

`high-value-sources` acts as a research librarian: it searches broadly, verifies
the top candidates by actually opening them, scores each one transparently, and
returns a ranked shortlist of 10–15 genuinely high-value sources — best to
weakest — with a one-line reason per entry.

It adapts its criteria to the topic's domain automatically:

- **Software/dev** — official docs, specs, GitHub signals (stars, forks, recent activity)
- **Business** — filings, analyst research, trade press
- **Academic** — citations, peer review, primary papers
- **News/current-events** — outlet track record, primary reporting

## Install

```bash
npx skills add pdkproitf/skills@high-value-sources
```

## Usage

Give it a topic, a question, or a link:

```
/high-value-sources Raft consensus algorithm
/high-value-sources how do I do zero-downtime Postgres migrations
/high-value-sources https://github.com/some/repo
```

It searches, verifies the top candidates, scores them out of 100 against five
weighted criteria (relevance, authority, community endorsement, recency,
authenticity/depth), and returns a ranked list grouped into tiers (A/B/C) with
a short "why" for each source.
