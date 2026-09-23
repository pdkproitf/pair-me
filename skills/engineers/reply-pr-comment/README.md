# reply-pr-comment

> Work through every review comment on a PR — validated against the code, with paste-ready replies.

---

## What it does

`reply-pr-comment` finds the PR for the current branch (or takes a URL/number), fetches every review thread — inline and top-level, on GitHub or Bitbucket — and maps each comment to the code **at the PR head commit**, so a comment isn't judged against a file that has since moved. It checks local state first, triages cheaply, then for each comment reads it, states how it understood it, validates the claim against the actual source, and assigns a verdict:

- **needs-code** — the comment is right, a change is required
- **reply-only** — the comment rests on a misreading; the reply explains why, with evidence
- **needs-a-decision** — the answer isn't the reviewer's or yours alone to make

Code changes are applied in priority order and committed. Replies are produced as text you paste — the skill doesn't post on your behalf.

---

## When to use

- A PR came back with review comments and you want each one answered accurately
- Comments span several files and some may already be stale
- You want the "this is actually wrong because…" replies backed by source, not vibes

---

## Install

```bash
npx skills add pdkproitf/skills@reply-pr-comment
```

---

## Usage

**Claude Code:**
```
/reply-pr-comment
/reply-pr-comment 482
/reply-pr-comment https://github.com/org/repo/pull/482
```

**Other tools:**
```
@reply-pr-comment [PR url or number]
```

---

## Output

```
### Comment 1 — <author>, `path/to/file.rb:41`
**Comment**: <verbatim>
**Understood as**: <restatement>
**Verdict**: needs-code | reply-only | needs-a-decision
**Action**: <what was changed, or why nothing was>
**Reply**: <paste-ready text>
```

Plus commits for the comments that needed code.
