# create-pr

Open a GitHub pull request for the current branch using whichever creation method is available, preferring the most token-efficient one: **`gh` CLI → GitHub MCP → git push + compare URL**. It detects what's installed, shows a cost/capability comparison, and — because MCP is the most token-expensive path — pauses to ask for confirmation before creating a PR via MCP. The PR title and body are sourced from an existing spec/plan (from the `feature` or `implement` skills) instead of re-analyzing the full diff. Title is formatted as a Conventional Commit; the body template and a worked example live in [`templates/pr-body.md`](templates/pr-body.md).

**Based on:** [NVIDIA/OpenShell](https://github.com/NVIDIA/OpenShell/blob/main/.agents/skills/create-github-pr/SKILL.md), generalized to this repo's tool-agnostic `# WORKSPACE` conventions and extended with method fallback + plan-context sourcing.
