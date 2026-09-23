---
tool: mcp-servers
verified: 2026-09-09
source: the `claude mcp add` command
upstream: none
wave: 3
depends_on: [codebase-memory, caveman]
writes_settings: false
writes_claude_json: true
run_by: the caller only, never an installer agent
---

# mcp-servers

Registers the three user-scope MCP servers. `claude mcp add` writes
`~/.claude.json`, not `settings.json`.

**No installer agent runs this.** Parallel writes to `~/.claude.json` race, and a
bad write breaks MCP for every project on the machine.

| Server | Kind | Points at |
| --- | --- | --- |
| `codebase-memory-mcp` | local binary | `$HOME/.local/bin/codebase-memory-mcp` |
| `caveman` | local binary | `$HOME/.caveman/bin/caveman-mcp` |
| `datadog` | remote HTTP | `https://mcp.datadoghq.com/api/unstable/mcp-server/mcp` |

## Credentials — the rule with no exception

Some MCP servers take a database connection string on the command line. A
connection string holds a password. **No file in this skill may contain one.**

The reference machine has two such servers, both **project**-scoped:
`postgres-rzmempalace` and `postgres-avatar-engine`. They are out of scope here for
two reasons: they belong to one repository, not to the machine, and their argument
is a credential.

If you must document that shape, document it as a placeholder and nothing else:

```
postgresql://USER:PASSWORD@localhost:PORT/DBNAME
```

The real value lives on the old machine in `~/.claude.json`, under that project's
`mcpServers`. Read it there when you need it. Do not copy it into a skill file, a
plan, a commit, or a chat message. Repository setup is `onboard-project`, not this.

## Probe

```bash
/usr/bin/python3 - <<'PY'
import json, os
p = os.path.expanduser("~/.claude.json")
try:
    d = json.load(open(p))
except FileNotFoundError:
    print("~/.claude.json MISSING"); raise SystemExit
except Exception as e:
    print("~/.claude.json MALFORMED:", e); raise SystemExit
have = d.get("mcpServers") or {}
for name in ("codebase-memory-mcp", "caveman", "datadog"):
    v = have.get(name)
    target = (v.get("command") or v.get("url", "")) if isinstance(v, dict) else None
    print("%-22s %s" % (name, target or "MISSING"))
PY
```

## Validate

```bash
claude mcp --help >/dev/null 2>&1 && echo "claude mcp OK" || echo "claude mcp FAIL"
[ -x "$HOME/.local/bin/codebase-memory-mcp" ] && echo "cbm binary OK"     || echo "cbm binary FAIL"
[ -x "$HOME/.caveman/bin/caveman-mcp" ]       && echo "caveman mcp OK"    || echo "caveman mcp FAIL"
getent hosts mcp.datadoghq.com >/dev/null && echo "datadog host OK" || echo "datadog host FAIL"
```

Pass: all four read `OK`.

**Do not probe the datadog endpoint with `curl`.** A streamable-HTTP MCP endpoint
answers `404` to a plain `HEAD` or `GET` even while it works — it only responds to
an MCP session handshake. A `curl` check there reports `STALE-SOURCE` on a server
that is running, which is a false stop. Resolving the host is the most a
pre-install check can honestly prove. The real proof is `claude mcp list` in
Verify.

A `FAIL` on either binary means wave 2 did not finish. Do not register a server
that points at a file which is not there. The entry would look correct and the
server would fail to start on every session.

## Install

Run these one at a time. Check each exit code before the next, because each one
rewrites `~/.claude.json`.

1. Back up first:
   ```bash
   cp "$HOME/.claude.json" "$HOME/.claude.json.bak-$(date +%Y%m%d-%H%M%S)"
   ```
2. `codebase-memory-mcp`:
   ```bash
   claude mcp add --scope user codebase-memory-mcp "$HOME/.local/bin/codebase-memory-mcp"
   ```
3. `caveman`:
   ```bash
   claude mcp add --scope user caveman "$HOME/.caveman/bin/caveman-mcp"
   ```
4. `datadog`, an HTTP transport:
   ```bash
   claude mcp add --scope user --transport http datadog \
     https://mcp.datadoghq.com/api/unstable/mcp-server/mcp
   ```
5. `datadog` needs OAuth in a browser. Claude cannot do this step. Tell the user to
   run `/mcp` in a session and complete the login, and say plainly that the
   `datadog` tools stay unavailable until they do.

`--scope user` matters. Without it the server is registered for the current
directory only, and it disappears the moment you work in another repository.

## Return

Not applicable. This is the register step, not an install.

## Verify

```bash
claude mcp list
```

Expect all three named. `codebase-memory-mcp` and `caveman` must show connected.
`datadog` stays unauthenticated until the user finishes the browser login, and that
is the expected state right after setup — not a failure.

Then confirm the file still parses, because every `claude mcp add` rewrote it:

```bash
/usr/bin/python3 -c 'import json,os;json.load(open(os.path.expanduser("~/.claude.json")));print("claude.json OK")'
```

Anything but `claude.json OK`: restore the backup from Install step 1.
