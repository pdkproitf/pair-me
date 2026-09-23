---
tool: caveman
verified: 2026-09-09
source: https://github.com/JuliusBrussee/caveman
upstream: npm @caveman-ai/cli
wave: 2
depends_on: [node]
writes_settings: true
---

# caveman

Installs the caveman CLI and its plugin. Caveman compresses the session prefix and
supplies the response style, through a hook on eleven events.

Two parts, and they are separate things:

| Part | Where | Registered as |
| --- | --- | --- |
| the plugin | `settings.json` `enabledPlugins` + `extraKnownMarketplaces` | a Claude Code plugin from a GitHub marketplace |
| the MCP server | `~/.claude.json` | `caveman` at `~/.caveman/bin/caveman-mcp` |

## Probe

```bash
printf '%-16s %s\n' caveman      "$(command -v caveman >/dev/null 2>&1 && caveman --version 2>/dev/null || echo MISSING)"
printf '%-16s %s\n' caveman-home "$([ -d "$HOME/.caveman" ] && echo present || echo MISSING)"
printf '%-16s %s\n' caveman-mcp  "$([ -x "$HOME/.caveman/bin/caveman-mcp" ] && echo present || echo MISSING)"
```

## Validate

```bash
curl -fsSLI -o /dev/null -w 'repo %{http_code}\n' https://github.com/JuliusBrussee/caveman
npm view @caveman-ai/cli version
```

Pass: the first line reads `200`, and the second prints a version such as `1.3.3`.

Use `curl`, **not** `gh api`. `gh api` needs `gh auth login`, which a new machine
has not run, so it would report a false `STALE-SOURCE` on every fresh run.

A `404` from `npm view` means the package was renamed or unpublished. Stop and
report `STALE-SOURCE`. Do not search npm for a similar name — installing a
different publisher's package under the same idea is exactly the mistake this
check prevents.

## Install

No `sudo`. `nvm` puts the global `node_modules` inside your home directory.

1. Source `nvm` first. It is a shell function, not a binary, so a fresh
   non-interactive shell does not have it:
   ```bash
   export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
   ```
2. Install the CLI globally:
   ```bash
   npm install -g @caveman-ai/cli
   ```
3. Let the CLI create its own home. It writes `~/.caveman/` with `bin/`, the
   SQLite databases, and the runtime directories:
   ```bash
   caveman --version
   ```
4. Record the resolved paths. The hook commands need them absolute:
   ```bash
   command -v caveman
   ls -l "$HOME/.caveman/bin/caveman-proxy" "$HOME/.caveman/bin/caveman-mcp" 2>/dev/null
   ls -d "$HOME/.nvm/versions/node/"v*/lib/node_modules/@caveman-ai/cli/dist/native-hook-fast.js
   ```

## Return

```json
{
  "enabledPlugins": { "caveman@caveman": true },
  "extraKnownMarketplaces": {
    "caveman": { "source": { "source": "github", "repo": "JuliusBrussee/caveman" } }
  },
  "_mcp_user_scope": {
    "caveman": { "command": "$HOME/.caveman/bin/caveman-mcp" }
  },
  "_hook_paths": {
    "proxy": "$HOME/.caveman/bin/caveman-proxy",
    "adapter": "$HOME/.nvm/versions/node/<NODE_VERSION>/lib/node_modules/@caveman-ai/cli/dist/native-hook-fast.js",
    "caveman_bin": "$HOME/.nvm/versions/node/<NODE_VERSION>/bin/caveman"
  }
}
```

`_mcp_user_scope` and `_hook_paths` are messages to the caller, not real
`settings.json` keys. Do not write them into `settings.json`.

Report the real Node version in place of `<NODE_VERSION>`, taken from step 4.
`claude-settings.md` writes the eleven hook entries, and it needs these three
paths resolved. A wrong version in one of them gives a hook that fails silently.

## Verify

```bash
export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
caveman --version
[ -x "$HOME/.caveman/bin/caveman-proxy" ] && echo "proxy OK"  || echo "proxy FAIL"
[ -x "$HOME/.caveman/bin/caveman-mcp" ]   && echo "mcp OK"    || echo "mcp FAIL"
ls "$HOME/.nvm/versions/node/"v*/lib/node_modules/@caveman-ai/cli/dist/native-hook-fast.js
```

Expect a version line, `proxy OK`, `mcp OK`, and the adapter path.

An `mcp FAIL` while `proxy` is `OK` still counts as `FAILED`. Report it — the
plugin would work and the MCP tools would not, which looks like a caveman bug
later.
