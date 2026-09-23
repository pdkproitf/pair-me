---
name: setup-machine
description: Install the global Claude Code tooling on a new or rebuilt machine — the hook scripts, the codebase-memory MCP server, the caveman plugin, the status line, the global agents and skills, and the base binaries they need. It probes what is missing, shows you the list, waits for your confirmation, then fans out one installer agent per tool. Use it on a fresh machine, or to repair one tool after a reinstall. Do not use it to wire a single repository — that is onboard-project. Do not use it to test or silence the toast notifier — that is notify-on-wait.
---

# Set up Claude Code tooling on a new machine

A new machine has `claude` and nothing else. This skill reproduces the global
tooling around it. It never installs anything you did not confirm.

## The unit of work

One tool is one reference file is one agent. The three share a name, so there is
no mapping table to keep in step.

| Tool | Gives you | Wave | Needs |
| --- | --- | --- | --- |
| `system-packages` | `git`, `rg`, `gh`, `docker`, `python3` | 1 | — |
| `uv` | `uv`, `uvx` — the Python tool runner | 1 | — |
| `node` | `nvm` and one Node version | 1 | — |
| `cloud-cli` | `aws`, `kubectl` | 1 | — |
| `hooks` | the 4 scripts in `~/.claude/hooks/` | 2 | `system-packages` |
| `codebase-memory` | the `codebase-memory-mcp` binary | 2 | — |
| `caveman` | the caveman plugin and `~/.caveman/` | 2 | `node` |
| `statusline` | `cship` status line renderer and `~/.config/cship.toml` | 2 | — |
| `agents` | the 6 files in `~/.claude/agents/` | 2 | — |
| `skills` | the directories in `~/.claude/skills/` | 2 | — |
| `claude-settings` | the `~/.claude/settings.json` keys | 3 | every tool above |
| `mcp-servers` | the 3 user-scope MCP entries | 3 | `codebase-memory`, `caveman` |

Each reference lives at `references/<tool>.md`, beside this file.

A tool you do not confirm gets no agent, so its reference is never read. That is
the point of the split.

## Two shared files make waves 1 and 2 parallel, and wave 3 serial

| Shared file | Written by | If two agents write it at once |
| --- | --- | --- |
| `~/.claude/settings.json` | every tool that adds a hook or a key | read-modify-write race, so the last writer erases the others |
| `~/.claude.json` | `claude mcp add --scope user` | the same race, and a bad write breaks MCP for every project |

A lost write here is silent. Worse, a malformed `settings.json` disables **every**
setting in that file, including the Bedrock `env` block, so the session also loses
its model provider. The split that follows is not optional:

> An installer agent installs files and binaries only. It never edits
> `settings.json`, and it never runs `claude mcp add`. It **returns** its settings
> fragment as JSON in its report. You merge every fragment yourself, serially,
> once, after the whole fan-out finishes.

## Step A — Probe

Read-only. Nothing installs. Run it as one block.

```bash
probe() { printf '%-18s %s\n' "$1" "$(command -v "$2" >/dev/null 2>&1 && echo present || echo MISSING)"; }
pfile() { printf '%-18s %s\n' "$1" "$([ -e "$2" ] && echo present || echo MISSING)"; }

echo "== wave 1 =="
for b in git rg gh docker python3; do probe "$b" "$b"; done
probe uv uv; probe node node; probe aws aws; probe kubectl kubectl

echo "== wave 2 =="
for h in notify-waiting cbm-code-discovery-gate cbm-session-reminder cbm-subagent-reminder; do
  pfile "$h" "$HOME/.claude/hooks/$h"
done
probe codebase-memory-mcp codebase-memory-mcp
probe caveman caveman
pfile caveman-home "$HOME/.caveman"
probe cship cship
pfile cship-config "$HOME/.config/cship.toml"
printf '%-18s %s files\n' agents "$(ls -1 "$HOME/.claude/agents"/*.md 2>/dev/null | wc -l)"
printf '%-18s %s dirs\n'  skills "$(ls -1d "$HOME/.claude/skills"/*/ 2>/dev/null | wc -l)"

echo "== wave 3 =="
pfile settings.json "$HOME/.claude/settings.json"
/usr/bin/python3 - <<'PY' 2>/dev/null || echo "mcp-servers        MISSING"
import json, os
p = os.path.expanduser("~/.claude.json")
d = json.load(open(p))
have = set((d.get("mcpServers") or {}).keys())
want = {"codebase-memory-mcp", "caveman", "datadog"}
print("%-18s %s" % ("mcp-servers", "present" if want <= have else "MISSING: " + ", ".join(sorted(want - have))))
PY

echo "== must stay MISSING =="
for b in jq notify-send paplay pipx; do probe "$b" "$b"; done
```

The last block is not a gap to close. The notifier is written around those four
absences, so a `present` there is the finding, not a `MISSING`. See
`references/hooks.md`.

## Step B — Present the list, then wait

1. Show the missing tools as a numbered table: number, tool, what it gives you,
   wave.
2. Ask with `AskUserQuestion`, `multiSelect: true`. Offer each missing tool as one
   option, and offer "all missing" as one more.
3. Install nothing until the answer arrives. A partly-installed machine is harder
   to debug than an empty one.

## Step C — Fan out, one agent per tool

For each wave in order, launch one `tool-installer` agent per confirmed tool of
that wave. Put every agent of one wave in a **single message**, so they run at the
same time. Wait for the whole wave before you start the next.

Prompt each agent with exactly two facts, and nothing else:

```
tool: <tool name>
reference: /home/<user>/.claude/skills/setup-machine/references/<tool>.md
```

The agent reads that one reference and follows it. Do not paste install commands
into the prompt — the reference is the single source, and a pasted copy goes stale
the moment the reference is fixed.

Wave 3 has no agents. You do it, in Step D.

## Step D — Merge the settings, serially

Only after every wave-2 agent has reported.

1. Back up first:
   `cp ~/.claude/settings.json ~/.claude/settings.json.bak-$(date +%Y%m%d-%H%M%S)`
2. Collect the `settings_fragment` from every agent report. Ignore the `null` ones.
3. Read `references/claude-settings.md`. Merge every fragment into
   `settings.json` in **one** edit. A merge adds keys and appends to arrays. It
   never replaces a key that already holds something.
4. Validate immediately, before anything else:
   ```bash
   /usr/bin/python3 -c 'import json;json.load(open("'"$HOME"'/.claude/settings.json"));print("JSON OK")'
   ```
   Anything but `JSON OK` means you restore the backup from step 1 and start the
   merge again. Do not continue with a broken file.
5. Read `references/mcp-servers.md`. Run the `claude mcp add --scope user` calls
   one at a time, checking each for a non-zero exit before the next.

## Step E — Verify

1. Re-run Step A. Every confirmed tool must now read `present`.
2. For any tool that did not flip, report its agent's own error line. Do not
   re-run the agent until you know why it failed.
3. Tell the user to open `/hooks` once, or restart the session. New hook events
   do not load otherwise — see the traps below.

## Traps

**The settings merge is never a replace.** `settings.json` holds keys no agent
knows about: `env`, `permissions`, `effortLevel`, `modelSettings`,
`autoCompactWindow`, `tui`, `theme`. Overwriting the file loses them all.

**`nvm` paths carry a Node version.** The caveman hook commands in
`settings.json` hold an absolute path like
`.nvm/versions/node/v24.19.0/bin/caveman`. That path is wrong on a machine with a
different Node version, and the hook then fails silently. After the `node` agent
reports, read the version it installed and rewrite those paths. See
`references/claude-settings.md`.

**The settings watcher only watches directories that held a settings file when the
session started.** A hook added during this session may not load. Open `/hooks`
once to reload, or restart. Claude cannot open `/hooks` for you — it is a user
menu, and opening it ends the turn.

**A silent hook is worse than no hook.** A hook whose command is missing still
runs, still fails, and reports nothing. Every hook this skill installs must pass
its reference's Verify step before you call the tool done.

**Never put a credential in a reference file.** Two project-scope MCP servers pass
a database password on the command line. Those belong to a repository, not to this
skill. `references/mcp-servers.md` covers user-scope servers only, and shows the
placeholder form.
