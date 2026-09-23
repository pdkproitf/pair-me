---
tool: node
verified: 2026-09-09
source: https://github.com/nvm-sh/nvm
upstream: https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh
wave: 1
depends_on: []
writes_settings: false
version_on_reference_machine: v24.19.0
nvm_version_on_reference_machine: 0.40.6
writes_settings_indirectly: true
---

# node

Installs `nvm`, then one Node version. The caveman plugin needs Node, so this
tool runs in wave 1 and `caveman` runs in wave 2.

**The version you install changes `settings.json`.** Ten hook commands in
`settings.json` hold an absolute path that contains the Node version, for example
`/home/<user>/.nvm/versions/node/v24.19.0/bin/caveman`. A different version makes
every one of those paths wrong, and a hook with a wrong path fails silently. So
this reference has no `Return` fragment of its own, but it **must** report the
version it installed, and `claude-settings.md` uses that version to rewrite the
paths.

The reference machine runs `v24.19.0` under `nvm` `0.40.6`.

## Probe

```bash
printf '%-6s %s\n' node "$(command -v node >/dev/null 2>&1 && node --version || echo MISSING)"
printf '%-6s %s\n' nvm  "$([ -s "$HOME/.nvm/nvm.sh" ] && echo present || echo MISSING)"
```

Both lines answering means this tool is done. Report the `node` version in
`notes`, even on a `PRESENT` result — `claude-settings.md` needs it either way.

## Validate

```bash
curl -fsSLI -o /dev/null -w 'installer %{http_code}\n' \
  https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh
curl -fsSLI -o /dev/null -w 'repo      %{http_code}\n' https://github.com/nvm-sh/nvm
```

Pass: both lines read `200`.

Use `curl`, **not** `gh api`. `gh api` needs `gh auth login`, and a new machine has
not run it yet. A Validate that needs a login turns every fresh run into a false
`STALE-SOURCE`, which is worse than no check at all.

Report `STALE-SOURCE` if either fails. A missing `v0.40.6` tag means the pin was
withdrawn, and that is a decision for the user, not a reason to switch to
`master` — a moving installer URL is exactly what this check exists to catch.

## Install

No `sudo`.

1. Run the pinned installer:
   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
   ```
2. `nvm` is a shell function, not a binary. It is not on `PATH`, so every later
   command must source it first:
   ```bash
   export NVM_DIR="$HOME/.nvm"
   . "$NVM_DIR/nvm.sh"
   ```
3. Install the version the reference machine runs, and make it the default:
   ```bash
   nvm install 24.19.0
   nvm alias default 24.19.0
   ```
   Install a different version only if the user's prompt names one. Then report
   that version, because `claude-settings.md` writes it into ten hook paths.

## Return

None directly. The version goes in the report `notes` line, in this exact form so
the caller can read it without guessing:

```
node_version: v24.19.0
```

```
null
```

## Verify

```bash
export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
nvm --version && node --version && npm --version
ls -d "$HOME/.nvm/versions/node/"v*
```

Expect three version lines, then the version directory path. That directory path
is what `claude-settings.md` needs, so include it in `verify_output`.
