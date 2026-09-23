---
name: reply-pr-comment
description: Investigate pull-request review comments and draft replies — finds the PR for the current branch (or takes one), reads every thread, maps each comment to the code at the PR head commit, validates the claim against source, then reports each as needs-code / reply-only / needs-a-decision with paste-ready reply text
argument-hint: "[PR url or number]"
metadata:
  phase: "review"
  input: "PR url or number, or nothing (the PR is found from the current branch); repo checked out locally"
  output: "per-comment report (comment / understood as / verdict / action / reply) plus commits for the comments that needed code"
  dependencies: "git; gh CLI for GitHub; BITBUCKET_AUTH and curl for Bitbucket"
---

# Reply to PR Review Comments

Answer a reviewer properly: read what they wrote, check it against the code they
wrote it about, fix what is real, and reply with something they can act on.

The expensive failure this skill exists to prevent is a confident reply to a
comment that was never read against the right revision.

## When to trigger

Use this skill when the user:
- asks to review, check, or go through a PR's review comments
- asks what to reply to a reviewer, or asks for reply text for a comment
- asks to address, action, or resolve review feedback

The PR may be given as a URL or number. If it is not, find it from the current
branch (Step 0) — do not ask before looking.

## Do not

- **Do not post anything** — replies, resolutions, approvals — unless the user
  explicitly asks. The deliverable is draft text (Step 7).
- **Do not push, rebase, or amend a pushed commit.** Amending an unpushed commit
  to correct a false statement in its message is fine and expected.
- **Do not claim evidence you did not gather.** If a reply or a commit message
  wants to say "based on the p99" or "measured", either query the metric or say
  plainly that it is reasoning. A commit message that credits data that was
  never collected is worse than a vague one.
- **Do not answer a nearby improvement instead of the comment.** Scope creep in a
  review reply reads as evasion.

---

## Step 0 — Resolve the PR

Parse the host, owner and repo from the remote. Both URL forms occur, and the
trailing `.git` must be stripped:

```bash
git remote get-url origin
```

| Form | Example | Parsed |
|---|---|---|
| SSH | `git@bitbucket.org:your-org/your-repo.git` | `your-org` / `your-repo` |
| HTTPS | `https://github.com/owner/repo.git` | `owner` / `repo` |

`github.com` → GitHub path. `bitbucket.org` → Bitbucket path. Anything else:
stop and report the unrecognised host.

If the user gave a PR URL or number, use it. Otherwise find the open PR whose
source branch is the current branch:

```bash
git rev-parse --abbrev-ref HEAD

# GitHub
gh pr list --head "$BRANCH" --state open --json number,title,headRefName

# Bitbucket
curl -sS -u "$BITBUCKET_AUTH" \
  "https://api.bitbucket.org/2.0/repositories/$WS/$SLUG/pullrequests?q=source.branch.name=%22$BRANCH%22&state=OPEN"
```

- No match → stop. Say the branch has no open PR; do not guess at a number.
- More than one → list them with title and target branch, and ask which.

Then read the PR itself and **record its head commit**. Every later step depends
on it, because that is the revision the comments were written against.

```bash
# Bitbucket
curl -sS -u "$BITBUCKET_AUTH" \
  "https://api.bitbucket.org/2.0/repositories/$WS/$SLUG/pullrequests/$ID"
# -> .source.commit.hash, .source.branch.name, .destination.branch.name, .state

# GitHub
gh pr view "$ID" --json number,title,headRefOid,headRefName,baseRefName,state
```

State the PR title, state, source → target branch, and head commit before
continuing.

---

## Step 1 — Fetch the threads

One paginated call, not one per comment.

```bash
# Bitbucket
curl -sS -u "$BITBUCKET_AUTH" \
  "https://api.bitbucket.org/2.0/repositories/$WS/$SLUG/pullrequests/$ID/comments?pagelen=50"

# GitHub — review comments (inline) and issue comments (top level) are separate
gh api "repos/$OWNER/$REPO/pulls/$ID/comments" --paginate
gh api "repos/$OWNER/$REPO/issues/$ID/comments" --paginate
```

For each comment keep: id, author, created date, file path, line, the raw body,
the parent id, whether it is deleted, and its resolution state. Reconstruct
threads from the parent links — a reply changes what the top comment means, and
often already contains the answer.

Bitbucket puts the file and line under `inline` (`path`, `to`, `from`); a comment
with no `inline` is a PR-level comment. Keep both.

Do not summarise yet.

---

## Step 2 — Check local state before judging anything

Comments anchor to the PR head commit. The local branch has usually moved since.

```bash
git status --short
git log --oneline "$HEAD_COMMIT..HEAD"   # what landed after the review
git log --oneline "HEAD..$HEAD_COMMIT"   # review is ahead of local
```

Report: working tree clean or dirty, and whether local is at, ahead of, or behind
the PR head. If the branch has no relation to the PR head, stop — validating
against the wrong tree produces confident nonsense.

Ahead of the head commit is the normal case and is fine. It means some comments
are already answered by later commits, which Step 3 catches.

---

## Step 3 — Triage cheaply

One pass to remove what needs no investigation. Report each as skipped, with the
reason, so the count reconciles:

- deleted comments
- already-resolved threads
- approvals, "LGTM", and other comments carrying no request
- the author's own replies where the thread already ends in agreement

Everything else enters the loop.

---

## Step 4 — Per-comment loop

Run these four steps on one comment at a time. Finish one before starting the
next: half-validated comments produce mixed-up replies.

### 4.1 Read

Quote the comment verbatim, with author, file and line. No paraphrase at this
stage — a reviewer's exact wording is often the evidence for what they meant.

### 4.2 Understand

Read the code the comment was written against, **at the PR head commit**:

```bash
git show "$HEAD_COMMIT:$PATH" | sed -n "$((LINE-15)),$((LINE+15))p"
```

Not the working file. The line numbers are diff positions on that revision; on a
branch that has moved, the same number points at unrelated code, and answering
that is answering a comment nobody made.

If the comment predates the head commit (an older push), find the revision that
was current when it was written and read that instead:

```bash
git log --format="%h %ad" --date=iso --until="$COMMENT_CREATED_AT" -3 -- "$PATH"
```

Then state the claim in one sentence, in your own words. If you cannot, you have
not understood it — read the thread and the surrounding code again.

### 4.3 Validate

Prove or disprove it from source before writing a single word of reply. Read the
actual call sites, the library signature in `.venv`/`node_modules`, the config
default, the test. Reach one of three verdicts, each with its evidence:

| Verdict | Means | Must carry |
|---|---|---|
| `correct` | the problem is real | the file:line that shows it |
| `stale` | real once, already fixed | the commit that fixed it |
| `incorrect` | the premise does not hold | the file:line that contradicts it |

Cite what you read. "Looks fine" is not a verdict. If the claim needs data you do
not have — latency, error rates, traffic — either query it or record that the
answer is reasoning rather than measurement, and say so in the reply too.

### 4.4 Action

Classify, and do the smallest thing that answers the comment:

- **needs code** — make the change, plus a test that fails without it. Keep it to
  the comment's scope.
- **reply only** — nothing to change: the design is deliberate, or the comment is
  already fixed, or the premise is wrong. The explanation is the whole
  deliverable.
- **needs a decision** — the answer is a product, ownership, security, cost, or
  data call. Write the question, do not guess. These are the items that get lost;
  they must appear again in the report's Open questions block.

---

## Step 5 — Apply, in priority order

Order the "needs code" items by what they cost the user, not by what is quick:

1. wrong behaviour, latency the user feels, data or security risk
2. duplicated or wasted work — redundant prompt text, dead fields, double calls
3. wording, comments, naming

Then run the full test suite once, after the batch — not once per edit. Report the
count. If something fails, fix it before Step 6; never commit a red suite.

---

## Step 6 — Commit

One commit per comment concern, through the `commit` skill. Rules that matter
here:

- Never squash unrelated fixes into one commit. A reviewer reading the branch
  should see their comment answered by one commit.
- If two fixes touch the same files and cannot be separated cleanly, fold them
  and **say so in the report** rather than writing a message that implies one
  concern.
- The message states what the diff does. It must not credit evidence that was
  never collected.

---

## Step 7 — Report

One count header, then one block per comment, then the open questions. Draft text
only — nothing is posted.

```
7 comments: 4 code, 2 reply-only, 1 needs your call, 2 skipped
```

Per comment:

**`<file>:<line>` — <author>: "<verbatim quote>"**
- **Understood as:** one sentence, the claim in your words.
- **Verdict:** `correct` / `stale (fixed in <sha>)` / `incorrect (<file:line>)` — with the evidence read.
- **Action:** `code: <what changed> (<sha>, <tests> passing)` / `reply only` / `needs your call: <question>`.
- **Reply:** paste-ready prose. Normal English, whatever style the session is in — this text goes to another person. Lead with agree or disagree, cite the file:line or sha, no apology padding, no restating their comment back at them.

Close with:

```
Open questions
- <comment ref>: <the decision needed, and the options>
```

Skipped comments get one line each with their reason.

---

## Step 8 — Post, only if asked

Not part of the default run. If the user explicitly says to post, send exactly
the approved text. Confirm the target thread id first — a reply on the wrong
thread is visible to the whole team and cannot be quietly undone.

```bash
# Bitbucket reply into a thread
curl -sS -u "$BITBUCKET_AUTH" -X POST \
  -H "Content-Type: application/json" \
  "https://api.bitbucket.org/2.0/repositories/$WS/$SLUG/pullrequests/$ID/comments" \
  -d '{"content":{"raw":"<text>"},"parent":{"id":<PARENT_ID>}}'

# GitHub reply to a review comment
gh api --method POST \
  "repos/$OWNER/$REPO/pulls/$ID/comments/$COMMENT_ID/replies" \
  -f body='<text>'
```

These two POST shapes are from the vendors' API docs and have not been exercised
by this skill's author — echo the request and check the response id before
declaring a reply posted. Thread resolution is left to the reviewer in the UI:
the author marking their own thread resolved reads as closing the reviewer's
question for them.
