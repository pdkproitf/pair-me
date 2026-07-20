# Domain notes: Academic / Research

For scientific claims, studies, empirical questions, or topics where "what does the
research actually say" is the point. Layer this on top of the universal criteria in
SKILL.md.

## What "authoritative" means here

Ranked roughly highest to lowest trust:

1. **Systematic reviews and meta-analyses** in peer-reviewed journals — they
   synthesize many studies and are the closest thing to a field's consensus view.
2. **Peer-reviewed original research** in recognized journals — check the journal's
   actual reputation (impact factor is a weak proxy; whether it's indexed in
   PubMed/Scopus/Web of Science and whether the field's experts cite it matters
   more than the number itself).
3. **Preprints** (arXiv, bioRxiv, SSRN) — valuable for cutting-edge or fast-moving
   fields, but explicitly *not yet peer-reviewed* — flag this every time you include
   one, and prefer a peer-reviewed version if one has since appeared.
4. **Government and institutional bodies** — NIH, WHO, national academies, official
   statistical agencies — for consensus positions and data.
5. **University press releases / EurekAlert-style summaries** — useful for finding
   studies but tend to overstate findings; always trace back to the actual paper
   rather than trusting the summary's framing.
6. **Science journalism from outlets with a science desk and named science
   reporters** — good for accessible explanation, but treat as secondary; check
   whether they link the actual paper.
7. **Popular science blogs / YouTube / Medium** — huge variance; only include if
   the author has real domain credentials and shows their work (cites the papers).

## What to search for

- `site:scholar.google.com "[topic]"` or the plain topic + "meta-analysis" /
  "systematic review" / "review article"
- `"[topic]" site:arxiv.org` or the field's dedicated preprint server
- The specific claim/statistic + "replication" or "reproduc" to check if it's held up
- The original study's authors' names, to check their other work and any retractions
- `"[topic]" retraction` to rule out retracted or heavily disputed papers
- For consensus questions: the relevant national academy or professional society's
  official position statement

## Domain-specific red flags

- **Single small study treated as settled science.** One study, especially with a
  small sample or that hasn't been replicated, is evidence — not proof. Note this
  explicitly rather than presenting it as consensus.
- **Predatory journals.** Pay-to-publish venues with minimal real peer review. If
  unsure, note that the journal's rigor is unverified rather than assuming quality.
- **Retracted or disputed papers** still being cited by secondary sources unaware of
  the retraction — always check retraction status for anything contested or older.
- **Conflict of interest undisclosed** — industry-funded research on that same
  industry's product, without independent replication.
- **Overstated press coverage** of a modest or preliminary finding ("scientists
  discover cure for X" from a cell-culture study).
- **P-hacking / cherry-picked framing** — a study technically real but whose
  headline claim isn't well-supported by its actual data; flag if you can tell.

## What to weigh more heavily than usual

- Sample size, study design (RCT > observational > case study > anecdote), and
  whether findings have been independently replicated.
- Whether the paper is cited approvingly by later peer-reviewed work, not just cited
  (citations can be critical, not endorsing).
- Recency matters less for foundational/theoretical work, more for anything with
  fast-evolving empirical data (medicine, ML, epidemiology).
