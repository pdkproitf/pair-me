---
tool: codebase-memory
verified: 2026-09-09
source: https://github.com/DeusData/codebase-memory-mcp
upstream: https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh
wave: 2
depends_on: []
writes_settings: true
---

# codebase-memory

Installs the `codebase-memory-mcp` binary into `~/.local/bin`. It serves the code
graph that `search_graph`, `trace_path`, and `get_code_snippet` read.

The MCP **entry** is not installed here. It goes in `~/.claude.json`, which the
caller writes in wave 3. See `mcp-servers.md`.

## Probe

```bash
printf '%-22s %s\n' codebase-memory-mcp \
  "$(command -v codebase-memory-mcp >/dev/null 2>&1 && codebase-memory-mcp --version 2>/dev/null || echo MISSING)"
```

## Validate

```bash
curl -fsSLI -o /dev/null -w 'installer %{http_code}\n' \
  https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh
curl -fsSLI -o /dev/null -w 'repo      %{http_code}\n' \
  https://github.com/DeusData/codebase-memory-mcp
```

Pass: both lines read `200`.

Use `curl`, **not** `gh api`. `gh api` needs `gh auth login`, which a new machine
has not run, so it would report a false `STALE-SOURCE` on every fresh run.

The installer lives on the `main` branch, not on a tag, so its content can change
between runs. A `200` proves it still exists; it does not prove the procedure is
unchanged. That is why `verified:` has a 90-day limit.

## Install

No `sudo`. The installer writes into `~/.local/bin` only.

1. Run it:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash
   ```
   The installer takes `--dir` if you need another location:
   ```bash
   curl -fsSL <same url> | bash -s -- --dir "$HOME/.local/bin"
   ```
2. Confirm the binary landed where the MCP entry will point:
   ```bash
   ls -l "$HOME/.local/bin/codebase-memory-mcp"
   ```
   The MCP entry uses this **absolute** path. A binary reachable only through
   `PATH` fails, because the MCP server starts without your shell's `PATH`.

## Return

The path for wave 3 to register. The caller runs the `claude mcp add` itself.

```json
{
  "_mcp_user_scope": {
    "codebase-memory-mcp": { "command": "$HOME/.local/bin/codebase-memory-mcp" }
  }
}
```

The `_mcp_user_scope` key is a message to the caller, not a real `settings.json`
key. Do not write it into `settings.json`.

`settings.json` also carries a permission that belongs to this tool:

```json
{
  "permissions": { "allow": [ "mcp__codebase-memory-mcp__*" ] }
}
```

Without it every graph query asks for approval, which makes the graph slower than
the `Grep` it replaces.

## Verify

```bash
"$HOME/.local/bin/codebase-memory-mcp" --version
```

Expect a version line and exit 0.

A live check needs the MCP entry, so it cannot run here. After wave 3 the caller
proves it with `claude mcp list`, which must show `codebase-memory-mcp` connected.
