---
name: notify-on-wait
description: Operate the desktop notifier that fires when a Claude Code session stops and waits for you — a permission prompt, a question, an MCP input request, or an idle session. Use it to test the notifier, to find out why no toast appeared, to silence the notifier, or to add or remove a waiting-state event. Do not use it for mobile push notifications (that is the inputNeededNotifEnabled setting), and do not use it to add a "turn finished" ping.
---

# Notify me when a session waits

A Claude Code session that waits for you gives no signal outside the terminal
window. If the window is behind another window, you do not know. This notifier
sends a Windows toast the moment a session starts to wait.

Three hook events fire the same script, `~/.claude/hooks/notify-waiting`. Each
passes its own fallback title as `$1`.

| Event | Fires when | Fallback title |
| --- | --- | --- |
| `PermissionRequest` | a tool needs your approval | `approve tool?` |
| `Notification` | permission prompt, or 60 s idle | `waiting` |
| `Elicitation` | an MCP server asks you for input | `input needed` |

The script prefers the `message` field from the hook payload. It falls back to
`$1` only when the payload carries no message — a `PermissionRequest` payload
carries no message, so approvals show the fallback.

## What a toast says

Three lines, because you run four or more sessions at once and a project name
alone does not tell you which window to switch to.

| Line | Holds | Source |
| --- | --- | --- |
| 1 | `Claude — <project>` | `basename` of the payload `cwd` |
| 2 | `<reason> · <tool>` | payload `message` (else `$1`) and `tool_name` |
| 3 | `<terminal> · <detail>` | terminal identity, and the argument being waited on |

Example:

```
Claude — service-rzmempalace
approve tool? · Bash
VS Code pts/18 · docker compose -f docker-compose.yaml up -d
```

**Terminal identity** is `TERM_PROGRAM` plus the tty device. The tty is the part
that matters: every session shows `VS Code`, but only one is `pts/18`. Find that
window with `ps -eo pid,tty,args | grep claude`. In tmux the pane replaces the
tty, as `tmux <session>:<window>.<pane>`.

**Detail** is the argument that identifies the call — the `command` for Bash, the
`file_path` for Edit and Write, then `path`, `url`, `pattern`, `prompt`,
`description`, `query`, in that order. It is cut to 110 characters.

Payloads are logged to `~/.claude/hooks/logs/notify-waiting.jsonl`, newest last,
capped at 200 lines. That log is the only way to learn an event's real field
names — read it before you add a field to the toast.

Two channels run together:

| Channel | Latency | Carries text | Set by |
| --- | --- | --- | --- |
| Terminal bell + tab flash | instant | no | `preferredNotifChannel` in settings |
| Windows toast | ~1.5 s | yes | the three hooks above |

The bell covers the wait while PowerShell starts. The toast tells you what and
where.

## When to call this skill

- a toast did not appear and you want to know which layer failed
- you want to test the notifier without waiting for a real prompt
- you want the notifier quiet, for one session or for good
- you want to add or drop a waiting-state event

Skip it when:

- you want a push notification on your phone — that is the
  `inputNeededNotifEnabled` setting, a different feature
- you want a ping when a turn *finishes* — see [Known traps](#known-traps)

## Files

| Path | Holds |
| --- | --- |
| `~/.claude/hooks/notify-waiting` | the notifier script |
| `~/.claude/settings.json` | the three hook entries and `preferredNotifChannel` |
| `~/.claude/hooks/logs/notify-waiting.jsonl` | the last 200 payloads, for field discovery |
| `~/.claude/settings.json.bak-*` | backups, newest last |

## Test the notifier

Run the steps in order. Each step tests one layer, so the first failure names the
broken layer.

### Step 1 — the script alone

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git push origin main --force"},"cwd":"~/projects/my-app"}' \
  | ~/.claude/hooks/notify-waiting "approve tool?"; echo "exit=$?"
```

Expect `exit=0` and a toast reading:

```
Claude — mempalace evaluation
approve tool? · Bash
VS Code pts/NN · git push origin main --force
```

No toast here means PowerShell or Windows is the problem, not Claude Code. Go to
[Known traps](#known-traps).

### Step 2 — an empty payload

```bash
echo '{}' | ~/.claude/hooks/notify-waiting "waiting"; echo "exit=$?"
```

Expect a toast titled `Claude — <cwd basename>`, body `waiting`, and `exit=0`. A
notifier must never fail on a payload it does not recognise.

### Step 2b — the field framing

This is the test that catches the worst failure, because that failure is silent:
every value shifts one line up and the toast still looks plausible.

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/a.py"},"cwd":"/tmp"}' \
  | ~/.claude/hooks/notify-waiting "approve tool?"
```

The payload has **no** `message` field, so the first field is empty. Line 1 must
read `Claude — tmp`, not `Claude — Edit`. If the tool name appears on line 1, the
delimiter has been changed back to a tab — see [Known traps](#known-traps).

### Step 3 — the settings wiring

`jq` is **not** installed on this machine. Use `python3`, which is, at
`/usr/bin/python3`.

```bash
/usr/bin/python3 - <<'PY'
import json
d = json.load(open('~/.claude/settings.json'))
print("JSON OK")
for e in ("PermissionRequest", "Notification", "Elicitation"):
    for b in d["hooks"].get(e) or [{"hooks": []}]:
        for h in b["hooks"]:
            print(f"{e}: async={h.get('async')} cmd={h['command']}")
    if not d["hooks"].get(e):
        print(f"{e}: NOT WIRED")
print("channel =", d.get("preferredNotifChannel"))
print("bedrock =", d["env"].get("CLAUDE_CODE_USE_BEDROCK"))
PY
```

Expect `JSON OK`, all three events with `async=True`, `channel = terminal_bell`,
and `bedrock = 1`.

A `JSONDecodeError` instead of `JSON OK` is the worst case, and you fix it before
anything else. A malformed `settings.json` silently disables **every** setting in
that file, including the Bedrock `env` block, so the session loses its model
provider as well as its notifier. Restore from the newest
`~/.claude/settings.json.bak-*`.

### Step 4 — a live prompt

Start a new session and trigger a real permission prompt. If steps 1 to 3 passed
but nothing appears, the settings watcher has not reloaded — see
[Known traps](#known-traps).

## Silence the notifier

Three levels, least drastic first.

| Goal | Do this |
| --- | --- |
| turn one event off, keep the others | `/hooks`, then disable that event |
| quiet for this session only | `/hooks`, then disable all three |
| quiet for good | delete the three hook blocks from `~/.claude/settings.json` |

Do **not** set `disableAllHooks` to silence this notifier. That switch also kills
the `cbm-*` reminder hooks, the `caveman-proxy` hooks, and the status line.

## Known traps

**Never separate the extracted fields with a tab.** A tab is an IFS whitespace
character, so `read` collapses runs of it and drops leading empties. A payload
with no `message` field then shifts every value one slot left: the project name
lands in the reason, the tool name lands in the title. The toast still looks
plausible, which is what makes it dangerous. The script uses `\x1f` (unit
separator) instead, and `clean()` strips `\x1f` out of every value so no payload
can inject a field break. Step 2b tests exactly this.

**The tty comes from an ancestor walk, not from `$PPID`.** The hook's own stdin is
a pipe, and the `claude` process sits several levels up, behind the `caveman`
wrapper and the shell. The script walks up to six levels for the first ancestor
that owns a tty. Also note the `case` pattern for "no tty" is `'?'` **quoted** —
unquoted, `?` is a glob that matches any single-character tty name and throws away
a real answer.

**`jq` is not installed.** The script parses the payload with `/usr/bin/python3`.
Do not switch it to `jq`, and do not switch it to `node` — `node` here comes from
nvm, so its path moves with the Node version and a hook must not break on an
unrelated version bump.

**`notify-send` is not installed, and neither is `paplay`.** An earlier version of
this hook called both. The hook ran, the command failed, and no notification ever
appeared — a silent hook is worse than no hook. Never reintroduce them. WSLg ships
no notification daemon, so `sudo apt install libnotify-bin` may still show nothing.

**The hooks must stay `async: true`.** PowerShell takes about 1.5 s to start. A
synchronous hook adds that 1.5 s to every permission prompt.

**BurntToast is not installed.** The script builds the toast XML itself and posts
it through the default-registered AUMID
`{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe`.
Do not add a `Install-Module BurntToast` dependency.

**The settings watcher only watches directories that already held a settings file
when the session started.** A hook added mid-session may not load. Open `/hooks`
once to reload the config, or restart the session. Claude cannot open `/hooks` for
you — it is a user menu, and opening it ends the turn.

**No hook exists for "turn finished".** The `Stop` event is the closest, and it
fires after every single turn. That is constant noise, not a notification, so it
is left out on purpose. Ask before adding it.

**Windows Focus Assist suppresses toasts.** If step 1 exits 0 but you see nothing,
check Focus Assist and the Action Center before you debug the script.
