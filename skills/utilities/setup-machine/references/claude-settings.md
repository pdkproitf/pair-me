---
tool: claude-settings
verified: 2026-09-09
source: the old machine — this file is local configuration
upstream: none
wave: 3
depends_on: [hooks, caveman, statusline, codebase-memory, node]
writes_settings: true
run_by: the caller only, never an installer agent
---

# claude-settings

Merges every agent's returned fragment into `~/.claude/settings.json`.

**No installer agent runs this.** The caller does it, once, after the whole
wave-2 fan-out reports. `tool-installer` has no `Edit` tool for exactly this
reason.

## Why this cannot be parallel

Two or more agents editing one JSON file is a read-modify-write race. Each reads
the file, changes its own part, and writes the whole thing back. The last writer
wins and the others vanish, with no error.

The second failure is worse. A malformed `settings.json` disables **every** setting
in that file, not just the broken key. That includes the `env` block that sets
`CLAUDE_CODE_USE_BEDROCK`, so the session loses its model provider and the cause
looks unrelated to anything you just did.

## Probe

```bash
f="$HOME/.claude/settings.json"
if [ ! -e "$f" ]; then echo "settings.json MISSING"; else
  /usr/bin/python3 - "$f" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("settings.json MALFORMED:", e); raise SystemExit
want = ["env", "permissions", "hooks", "statusLine", "enabledPlugins",
        "extraKnownMarketplaces", "effortLevel", "modelSettings",
        "autoCompactWindow", "tui", "theme", "preferredNotifChannel"]
for k in want:
    print("%-24s %s" % (k, "present" if k in d else "MISSING"))
h = d.get("hooks") or {}
print("hook events              %d" % len(h))
PY
fi
```

The reference machine has all twelve keys and 14 hook events.

## Validate

The only source is the old machine's file, so Validate proves it parses before you
copy anything out of it.

```bash
# replace <source> with the path the user gave you
/usr/bin/python3 -c 'import json,sys;json.load(open(sys.argv[1]));print("source JSON OK")' <source>/settings.json
```

Pass: `source JSON OK`. Anything else means the source file is broken, and copying
from it would break this machine too.

## The twelve keys

Merge every one. A key you skip is a setting you lose.

| Key | Holds | Comes from |
| --- | --- | --- |
| `env` | `CLAUDE_CODE_USE_BEDROCK`, `AWS_REGION`, `AWS_PROFILE`, `ENABLE_TOOL_SEARCH` | the old machine |
| `permissions.allow` | the MCP and path allow rules | old machine, plus `codebase-memory` and `skills` |
| `hooks` | 14 events | `hooks.md` and `caveman.md` fragments |
| `statusLine` | `cship` command | `statusline.md` fragment |
| `enabledPlugins` | `caveman@caveman` | `caveman.md` fragment |
| `extraKnownMarketplaces` | the caveman GitHub source | `caveman.md` fragment |
| `effortLevel` | `high` | the old machine |
| `modelSettings` | the per-model effort override | the old machine |
| `autoCompactWindow` | `200000` | the old machine |
| `tui` | `fullscreen` | the old machine |
| `theme` | `auto` | the old machine |
| `preferredNotifChannel` | `terminal_bell` | `hooks.md` fragment |

`env` carries an `AWS_PROFILE` name. A profile name is not a secret and can be
copied. A key, a token, or a password must never be written here — put those in
the AWS credential store, where `aws sso login` keeps them.

## Install — merge, step by step

1. Back up. Do this first, every time:
   ```bash
   cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak-$(date +%Y%m%d-%H%M%S)"
   ```
   No `settings.json` yet? Start from `{}`:
   ```bash
   mkdir -p "$HOME/.claude" && echo '{}' > "$HOME/.claude/settings.json"
   ```
2. Collect the `settings_fragment` from every agent report. Drop the `null` ones.
   Drop every `_mcp_user_scope` and `_hook_paths` block — those are messages for
   you, not `settings.json` keys. `mcp-servers.md` uses them.
3. Resolve the Node version in the caveman hook paths. The `node` agent reported
   it, in the form `node_version: v24.19.0`. Every caveman hook command holds it:
   ```
   $HOME/.nvm/versions/node/<NODE_VERSION>/lib/node_modules/@caveman-ai/cli/dist/native-hook-fast.js
   $HOME/.nvm/versions/node/<NODE_VERSION>/bin/caveman
   ```
   A wrong version here gives a hook that runs, fails, and says nothing.
4. Merge with these three rules, in this order:
   - a key absent from `settings.json` is added
   - an **array** is appended to, never replaced. This matters most for
     `hooks.PreToolUse`, `hooks.PostToolUse`, `hooks.SessionStart`,
     `hooks.SubagentStart`, and `permissions.allow`, where `hooks.md` and
     `caveman.md` both contribute entries
   - a **scalar** already set keeps its value. Report the conflict; do not decide
     it silently
5. Validate at once, before anything else:
   ```bash
   /usr/bin/python3 -c 'import json,sys;json.load(open(sys.argv[1]));print("JSON OK")' \
     "$HOME/.claude/settings.json"
   ```
   Anything but `JSON OK`: restore the backup from step 1 and merge again. Do not
   continue with a broken file.
6. Check the hook events survived:
   ```bash
   /usr/bin/python3 - <<'PY'
import json, os
d = json.load(open(os.path.expanduser("~/.claude/settings.json")))
for e, blocks in (d.get("hooks") or {}).items():
    n = sum(len(b.get("hooks") or []) for b in blocks)
    print("%-20s %d block(s), %d command(s)" % (e, len(blocks), n))
PY
   ```
   `PreToolUse` must show 3 commands, `PostToolUse` 2, `SessionStart` 5,
   `SubagentStart` 2. A count of 1 where 3 belong means an array was replaced
   instead of appended.

## Return

Not applicable. This is the merge target, not an install.

## Verify

```bash
/usr/bin/python3 - <<'PY'
import json, os
p = os.path.expanduser("~/.claude/settings.json")
d = json.load(open(p))
print("JSON OK")
for e in ("PermissionRequest", "Notification", "Elicitation"):
    hs = [h for b in (d["hooks"].get(e) or []) for h in b.get("hooks", [])]
    print("%-18s %s" % (e, [(h.get("async"), h["command"][:48]) for h in hs] or "NOT WIRED"))
print("channel  =", d.get("preferredNotifChannel"))
print("bedrock  =", (d.get("env") or {}).get("CLAUDE_CODE_USE_BEDROCK"))
print("plugins  =", d.get("enabledPlugins"))
print("statusln =", bool(d.get("statusLine")))
PY
```

Expect `JSON OK`, all three notifier events with `async` true,
`channel = terminal_bell`, `bedrock = 1`, the caveman plugin enabled, and
`statusln = True`.

Then tell the user to open `/hooks` once, or restart the session. The settings
watcher only watches directories that held a settings file when the session
started, so hooks added now may not load. Claude cannot open `/hooks` — it is a
user menu, and opening it ends the turn.
