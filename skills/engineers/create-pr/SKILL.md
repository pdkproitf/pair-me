---
name: create-pr
description: Create pull requests on GitHub or Bitbucket — detects the remote host, then picks the most token-efficient available method (gh CLI / GitHub MCP for GitHub, Bitbucket REST 2.0 for Bitbucket), and sources the PR body from an existing spec/plan instead of re-analyzing the diff
metadata:
  phase: "commit"
  input: "branch with commits pushed to remote; optionally a spec/plan path"
  output: "created PR URL (or a create-PR URL to finish in the browser)"
  dependencies: "git; and for GitHub one of gh CLI / GitHub MCP; for Bitbucket, BITBUCKET_AUTH and curl"
---

# Create Pull Request (GitHub or Bitbucket)

Open a pull request for the current branch, using whichever creation method is
available for the detected remote host — preferring the cheapest, most automated one.

## When to trigger

Use this skill when the user:
- asks to create a new PR, open a pull request, or submit code for review
- says "create PR", "new PR", or "submit for review" after work is committed and pushed

## Prerequisites

- Commits on a branch that is pushed to the remote
- The branch follows the `branch` convention from `# WORKSPACE` (default: `feat-{short-description}` or `feat-{adw_id}-{short-description}`)
- At least one creation method available for the detected host (see Step 1)

---

## Step 0 — Detect the remote host

The method ladder differs per host, so resolve the host **before** choosing a method.

```bash
git remote get-url origin
```

- URL contains `github.com` → **GitHub path** (Step 1A)
- URL contains `bitbucket.org` → **Bitbucket path** (Step 1B)
- Neither → **stop** and report the unrecognised host. Do not guess a host or a method.

Parse the owner and repository from the URL and keep them for later steps. Both
forms must be handled, and the trailing `.git` stripped:

| Form | Example | Parsed |
|---|---|---|
| SSH | `git@bitbucket.org:your-org/your-repo.git` | `your-org` / `your-repo` |
| HTTPS | `https://bitbucket.org/your-org/your-repo.git` | `your-org` / `your-repo` |

On GitHub these are `OWNER`/`REPO`; on Bitbucket they are `WORKSPACE`/`REPO_SLUG`.

State the detected host and the parsed owner/repo before continuing.

---

## Step 1A — Choose the PR method (GitHub)

Detect what's available and pick the **first** method that works, in this order.
Each later method exists only as a fallback for when the earlier one is missing.

1. **`gh` CLI** — check `command -v gh` and `gh auth status`. Preferred: cheapest and fully automated.
2. **GitHub MCP** — a configured GitHub MCP server exposing a create-pull-request tool. Use only if `gh` is unavailable. **Gated — see below.**
3. **git push + compare URL** — always available if there's a GitHub remote. Pushes the branch and gives the user a link to finish in the browser. Not fully automated.

`gh` speaks only to GitHub. Never reach for it on a Bitbucket remote, even though
it may be installed.

### Cost / capability comparison

| Method | Token cost | Automated? | Notes |
|---|---|---|---|
| `gh` CLI | **lowest** (~1 line back: the PR URL) | ✅ fully | Filters the response for you. Preferred. |
| GitHub MCP | **highest** (tool schemas loaded into context + full PR JSON returned) | ✅ fully | Only cheap if the server is already loaded for other work *and* the response is field-filtered. |
| git push + compare URL | lowest raw, but **incomplete** | ❌ user clicks the link | No API object returned; the PR isn't actually opened until the human confirms in the browser. |

State which method you selected and why (e.g. "gh not found → falling back to MCP").

### MCP gate — pause and ask

If the selected method is **GitHub MCP**, do **not** invoke it silently. MCP is the
most token-expensive path (schema overhead plus full API-object responses). Pause,
tell the user MCP is the only automated option available, and **ask for confirmation
before creating the PR**. If they decline, fall back to git push + compare URL.

This gate applies to the GitHub path only. There is no Bitbucket MCP tier.

---

## Step 1B — Choose the PR method (Bitbucket)

Bitbucket has no `gh` equivalent and no configured MCP server. Pick the **first**
method that works:

1. **`curl` + Bitbucket REST 2.0** — preferred. Fully automated, nothing to install.
   Requires `BITBUCKET_AUTH` (format `email:api-token`).
2. **`git push` + create-PR URL** — fallback. The user finishes in the browser.

| Method | Token cost | Automated? | Notes |
|---|---|---|---|
| `curl` + REST 2.0 | **low**, if you filter the response | ✅ fully | Preferred. Filter to `id` and `links.html.href`; the raw PR object is large. |
| `git push` + create-PR URL | lowest raw, but **incomplete** | ❌ user clicks the link | The PR isn't open until the human confirms in the browser. |

### Auth preflight

```bash
[[ -n "$BITBUCKET_AUTH" ]] && echo "auth present" || echo "auth missing"
```

- **Unset** — tell the user to run the `bb-auth-setup` skill, then use the
  create-PR URL fallback. Do not fail the whole skill over it.
- **Set** — confirm the token actually carries PR write scope before building a body:
  ```bash
  curl -s -o /dev/null -w "%{http_code}\n" -u "$BITBUCKET_AUTH" \
    "https://api.bitbucket.org/2.0/repositories/$WS/$REPO/pullrequests?pagelen=1"
  ```
  `200` → proceed. `401`/`403` → the token is expired or missing scopes; point at
  `bb-auth-setup` and drop to the fallback.

A 403 from `GET /2.0/user` is **not** a blocker — that endpoint needs
`read:account:bitbucket`, which PR creation does not use.

---

## Step 2 — Source the PR content

Before analyzing the diff, get the PR's substance from work that already exists —
reading a plan is far cheaper than re-analyzing a full diff. Use this precedence:

1. **Conversation context** — if this session already ran `feature` or `implement`, the spec path and a description of the work are already in context. Use them; skip the rest.
2. **Spec/plan file in `specs_dir`** — resolve `specs_dir` from `# WORKSPACE` (default: `docs/specs/`). Find the spec for this branch:
   - Match the branch's `adw_id` (from `feat-{adw_id}-{name}`) against the spec filename (`{timestamp}-feature-{adw_id}-{name}.md`).
   - If there's no `adw_id`, use the most recently modified spec in `specs_dir`.
   - Derive: **title** (feature name → conventional-commit format), **What** (the change itself, plainly, plus a short example if one exists), **Why** (the problem/root cause and any measurement or incident behind it — the spec's "Context" or rationale), **Approaches** (alternatives the spec considered or rejected — omit if the spec names none), **Changes** (its completed phases / checked boxes), **Related Issue** (`adw_id` or issue number).
3. **Fallback** — only if there's no context and no spec: analyze `git log` and `git diff`.

Checked-off boxes in the spec map directly to the PR's **Changes** and **Tests** sections.

**Section discipline.** `What` states the change with no rationale; `Why` carries the rationale and evidence, not restated code. `Approaches` only appears when there was a real alternative that was rejected or seriously considered — invented alternatives to fill the section are worse than omitting it. `Known limitations` only appears when this change leaves a real, named gap.

The PR body structure and a complete example live in
[`templates/pr-body.md`](templates/pr-body.md). If the project has its own
`.github/PULL_REQUEST_TEMPLATE.md` — or, on Bitbucket, a `PULL_REQUEST_TEMPLATE.md`
in the repo root or `.bitbucket/` — follow that instead.

---

## Step 3 — Pre-flight checks

### Run pre-commit checks
If the project defines a pre-commit / lint / format command in `# WORKSPACE`
(e.g. a `pre_commit_cmd` key or an equivalent task runner), run it now. Skip if none.

### Verify branch state
1. **Not on the main/default branch** — never open a PR from it:
   ```bash
   git branch --show-current   # should NOT be the default branch
   ```
2. **Branch follows the naming convention** — the `branch` rule from `# WORKSPACE`.
3. **Consider squashing** related commits for cleaner history:
   ```bash
   git reset --soft HEAD~N && git commit -m "feat(component): description"
   ```

### Push the branch
```bash
git push -u origin HEAD
```

---

## Step 4 — Create the PR

Build the title in conventional-commit format (see below) and the body from Step 2,
then create the PR using the method chosen in Step 1A (GitHub) or Step 1B (Bitbucket).
The title and body text are identical across hosts — only the transport differs.

### PR title format

```
<type>(<scope>): <description>
```

**Types:** `feat` · `fix` · `docs` · `refactor` · `test` · `chore` · `perf`
**Scope** is typically the component name (e.g. `cli`, `sdk`, `api`, `models`).

**Examples:**
- `feat(cli): add support for custom output formats`
- `fix(api): handle timeout errors gracefully`
- `docs(sdk): update authentication examples`

### Method A — `gh` CLI (GitHub, preferred)

```bash
gh pr create --title "<title>" --body "<body>"
```

Common variants:
```bash
gh pr create --draft --title "WIP: <title>"          # draft / work-in-progress
gh pr create --label "area:cli" --label "topic:security"   # labels
gh pr create --base "release-1.0"                    # target a non-default branch
```

Use `Closes #<issue-number>` in the body to auto-close the linked issue on merge.
This auto-close syntax is GitHub-only — see Method D for how Bitbucket links a ticket.

### Method B — GitHub MCP (only after the Step 1A gate)

After the user confirms, call the server's create-pull-request tool with
`head` = current branch, `base` = default branch, plus the title and body.
**Filter the response** to just the PR URL/number — do not echo the full API object.

### Method C — git push + compare URL (GitHub fallback)

`git` alone cannot open a PR, but it can hand the user a link:
```bash
git push -u origin HEAD
# Then give the user the compare URL to finish in the browser:
# https://github.com/OWNER/REPO/compare/<branch>?expand=1
```
The push output usually already prints a "Create a pull request" link — surface it,
along with the PR body (built per Step 2/templates/pr-body.md) in Markdown, so the
user can paste it into the browser form.

### Method D — Bitbucket REST 2.0 (Bitbucket, preferred)

```bash
WS=<workspace>; REPO=<repo-slug>            # parsed in Step 0
SRC=$(git branch --show-current)
DEST=<default-branch>                        # confirm with the user, don't assume
```

**First, check for an existing open PR** — Bitbucket happily creates a second PR for
the same branch pair, so a missing check produces duplicates:

```bash
curl -s -u "$BITBUCKET_AUTH" \
  "https://api.bitbucket.org/2.0/repositories/$WS/$REPO/pullrequests?state=OPEN&q=source.branch.name=%22$SRC%22"
```

If one exists, report it and stop — do not create another.

**Then create the PR.** Build the JSON payload with a tool, never by interpolating a
multi-line Markdown body into a `-d '...'` string:

```bash
# Preferred when jq is available:
curl -s -u "$BITBUCKET_AUTH" \
  -X POST -H 'Content-Type: application/json' \
  "https://api.bitbucket.org/2.0/repositories/$WS/$REPO/pullrequests" \
  -d "$(jq -n --arg t "$TITLE" --arg b "$BODY" --arg s "$SRC" --arg d "$DEST" \
        '{title:$t, description:$b,
          source:{branch:{name:$s}}, destination:{branch:{name:$d}},
          close_source_branch:false}')"
```

`jq` is often **not** installed. Check with `command -v jq`; when it is missing, write
the body to a file and encode with Python, then post the file:

```bash
cat > /tmp/pr-body.md <<'BODY'
<the Markdown body from Step 2, verbatim>
BODY

python3 - "$TITLE" "$SRC" "$DEST" > /tmp/pr.json <<'PY'
import json, sys
title, src, dest = sys.argv[1:4]
body = open("/tmp/pr-body.md").read()
json.dump({"title": title, "description": body,
           "source": {"branch": {"name": src}},
           "destination": {"branch": {"name": dest}},
           "close_source_branch": False}, sys.stdout)
PY

curl -s -u "$BITBUCKET_AUTH" \
  -X POST -H 'Content-Type: application/json' \
  "https://api.bitbucket.org/2.0/repositories/$WS/$REPO/pullrequests" \
  --data-binary @/tmp/pr.json
```

Rules for this method:

- **The body field is `description`, not `body`.** Bitbucket renders it as Markdown,
  so the template from `templates/pr-body.md` works unchanged.
- **Quote every URL containing `?` or `&`.** Under zsh an unquoted `?` fails with
  `no matches found` before curl ever runs.
- **Never echo `$BITBUCKET_AUTH`**, or any slice of it. Pass it only as
  `-u "$BITBUCKET_AUTH"`. Do not write it into a file or a log.
- **Filter the response.** Report only `id` and `links.html.href` as a markdown link.
  Do not paste the raw PR object into context — it is large and mostly noise.
- **Ticket linking.** Bitbucket has no `Closes #NNN` auto-close. The JIRA key in the
  title and description is what links the ticket, per the `commit` convention in
  `# WORKSPACE`.
- A `400` with a `fields` map means the payload was accepted and validated — read the
  named field and fix it. A `401`/`403` means auth, not payload.

### Method E — git push + create-PR URL (Bitbucket fallback)

```bash
git push -u origin HEAD
# Then give the user the link to finish in the browser:
# https://bitbucket.org/<WS>/<REPO>/pull-requests/new?source=<branch>&dest=<default-branch>
```

---

## After creating

Methods A, B, and D return the PR URL and number. **Display it as a markdown link** so it's clickable:

```
Created PR [#123](https://github.com/OWNER/REPO/pull/123)
Created PR [#123](https://bitbucket.org/WS/REPO/pull-requests/123)
Output the PR URL in the session context so follow-up skills can reference it. and the PR description in markdown format so the user can copy it into the PR body if needed.
```

### Monitor CI (optional)
If the user wants to wait for green CI before requesting review.

GitHub:
```bash
gh run watch                                          # latest run for the branch
# or:
RUN_ID=$(gh run list --branch "$(git branch --show-current)" --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID"
```

Bitbucket — there is no watch command, so poll the pipelines endpoint only if the user
asks. This is optional, never a required step:
```bash
curl -s -u "$BITBUCKET_AUTH" \
  "https://api.bitbucket.org/2.0/repositories/$WS/$REPO/pipelines/?sort=-created_on&pagelen=1"
```

## Useful `gh pr create` options (GitHub only)

| Option | Description |
|---|---|
| `--title, -t` | PR title (conventional commit format) |
| `--body, -b` | PR description |
| `--reviewer, -r` | Request review from user |
| `--draft` | Create as draft (WIP) |
| `--label, -l` | Add label (repeatable) |
| `--base, -B` | Target branch (default: repo default) |
| `--head, -H` | Source branch (default: current) |
| `--web` | Open in browser after creation |
