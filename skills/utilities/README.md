# Utility Skills

> Portable AI skills for managing the tool itself — not tied to any one profession.

Unlike `engineers/`, which groups skills by the audience using them, these skills are cross-cutting: they manage the AI session or account, regardless of what you're working on.

---

## Skills

### [token-wake](token-wake/)

> Stop losing Claude Pro tokens while you sleep.

Claude Pro's 5-hour window only starts when you send your first message after a reset. `token-wake` sends that message automatically — 1 minute after each reset — so your window starts the moment it's available, whether you're at your desk or not.

```bash
npx skills add pdkproitf/skills@token-wake --global
```

---

### [high-value-sources](high-value-sources/)

> A vetted, ranked reading list on any topic — technical, business, academic, or current events.

Finds the sources actually worth reading on a topic, tool, company, market, claim, or concept, and ranks them by authority and signal instead of dumping search results.

```bash
npx skills add pdkproitf/skills@high-value-sources
```

---

### [notify-on-wait](notify-on-wait/)

> A desktop toast when your session stops and waits for you.

Operates the notifier that fires on a permission prompt, a question, an MCP input request, or an idle session: tests it end to end, diagnoses a missing toast, silences it, and adds or removes a waiting-state event.

```bash
npx skills add pdkproitf/skills@notify-on-wait --global
```

---

### [setup-machine](setup-machine/)

> A fresh machine has the CLI and nothing else — this reproduces the rest.

Probes what's missing from the global tooling layer (hooks, MCP servers, plugins, status line, global agents and skills, base binaries), shows the list, waits for confirmation, then fans out one installer per tool and merges settings serially before verifying each one.

```bash
npx skills add pdkproitf/skills@setup-machine --global
```

---

### [bb-auth-setup](bb-auth-setup/)

> Get Bitbucket API auth working for the `bb-pr-*` scripts, once a year.

Detects existing or deprecated credentials, walks through Atlassian API token creation with the required scopes, writes the credential to your shell config, and verifies it with a live API call. Re-run it for the 365-day rotation.

```bash
npx skills add pdkproitf/skills@bb-auth-setup --global
```

---

## Install skills

Install a specific skill:
```bash
npx skills add pdkproitf/skills@<skill-name>
```

Browse everything available in the repo:
```bash
npx skills add pdkproitf/skills --list
```
