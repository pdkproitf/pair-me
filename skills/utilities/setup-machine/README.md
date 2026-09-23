# setup-machine

> A fresh machine has the CLI and nothing else. This reproduces the rest.

---

## What it does

`setup-machine` rebuilds the global tooling layer around your AI CLI: hook scripts, the codebase-memory MCP server, plugins, the status line, the global agents and skills, and the base binaries they depend on. It probes what's already present, shows you the missing list, **waits for your confirmation**, then fans out one installer agent per tool — waves 1 and 2 in parallel, wave 3 serial — and merges the resulting settings fragments serially so concurrent writers can't clobber the settings file. It finishes by verifying each tool actually runs.

It's for the machine, not the repo: wiring a single project is `onboard-project`, and testing or silencing the toast notifier is `notify-on-wait`.

---

## When to use

- A new or rebuilt machine, where only the CLI is installed
- Repairing one tool after an OS reinstall or a broken upgrade
- Auditing which parts of the global setup are missing right now

---

## Install

```bash
npx skills add pdkproitf/skills@setup-machine --global
```

---

## Usage

**Claude Code:**
```
/setup-machine
/setup-machine just the MCP server
```

**Other tools:**
```
@setup-machine [specific tool]
```

---

## Output

```
## Missing
- <tool> — why it's needed, how it will be installed

[waits for confirmation]

## Installed
- <tool> — version, verification result

## Settings merged
- <keys added>
```
