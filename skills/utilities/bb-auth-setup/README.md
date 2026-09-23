# bb-auth-setup

> Get Bitbucket API auth working for the `bb-pr-*` scripts, once a year.

---

## What it does

`bb-auth-setup` configures the Atlassian API token that the `bb-pr-*` scripts (`bb-pr-create`, `bb-pr-merge`, `bb-pr-list`, …) need to talk to the Bitbucket API. It checks whether auth is already configured and detects the deprecated app-password format, opens the Atlassian token page, tells you exactly which scopes to select, takes the token you created, writes the credential as an environment variable in your shell config, and verifies it by making a real API call.

Tokens expire after 365 days, and Bitbucket app passwords are deprecated — re-running the skill handles both the yearly rotation and the one-time upgrade to an API token.

Credentials are never committed: the token lives in your shell config only, and the skill's own instructions carry placeholders, not values.

---

## When to use

- First-time setup of the `bb-pr-*` scripts on a machine
- `401`/`403` from a `bb-pr-*` command — the token expired
- Upgrading from a deprecated Bitbucket app password to an Atlassian API token

---

## Install

```bash
npx skills add pdkproitf/skills@bb-auth-setup --global
```

---

## Usage

**Claude Code:**
```
/bb-auth-setup
```

**Other tools:**
```
@bb-auth-setup
```

---

## Output

The credential exported from your shell config, plus a verification result from a live API call — and, when the old format was found, a note that the app password was replaced by an API token.
