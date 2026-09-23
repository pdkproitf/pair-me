# create-pr

Open a pull request for the current branch on either **GitHub** or **Bitbucket**. The skill first detects the remote host from `git remote get-url origin`, then walks that host's method ladder, preferring the most token-efficient option:

- **GitHub:** `gh` CLI → GitHub MCP → git push + compare URL. Because MCP is the most token-expensive path, the skill pauses to ask for confirmation before creating a PR through it.
- **Bitbucket:** `curl` against Bitbucket REST 2.0 (using `BITBUCKET_AUTH`, set up by the `bb-auth-setup` skill) → git push + create-PR URL. It checks for an existing open PR first, since Bitbucket will otherwise create duplicates for the same branch pair.

The PR title and body are sourced from an existing spec/plan (from the `feature` or `implement` skills) instead of re-analyzing the full diff. Title is formatted as a Conventional Commit; the body follows a What / Why / Approaches / Changes structure (`Approaches` and `Known limitations` only when there's something real to put in them) — the full template and a worked example live in [`templates/pr-body.md`](templates/pr-body.md). The same body text serves both hosts — GitHub calls the field `body`, Bitbucket calls it `description`.

**Based on:** [NVIDIA/OpenShell](https://github.com/NVIDIA/OpenShell/blob/main/.agents/skills/create-github-pr/SKILL.md), generalized to this repo's tool-agnostic `# WORKSPACE` conventions and extended with host detection, per-host method fallback, and plan-context sourcing.
