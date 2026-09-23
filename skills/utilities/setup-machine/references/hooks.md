---
tool: hooks
verified: 2026-09-09
source: the old machine — these are local scripts with no upstream
upstream: none
wave: 2
depends_on: [system-packages]
writes_settings: true
---

# hooks

Installs the four scripts in `~/.claude/hooks/`, then returns the `settings.json`
fragment that wires them.

| Script | What it does |
| --- | --- |
| `notify-waiting` | Windows toast when a session waits for you |
| `cbm-code-discovery-gate` | reminds you to use the code graph before `Grep` |
| `cbm-session-reminder` | injects the code-graph session context |
| `cbm-subagent-reminder` | the same, for a subagent |

`upstream: none`. These are local scripts. Copy them from the old machine. Ask the
user for the copy source if the prompt did not name one; do not write a
replacement from memory.

## The four binaries that must stay missing

`notify-waiting` is written around four absences. Installing any of them does not
break the script, but *assuming* them does, and a later edit made under that
assumption breaks the notifier for good.

| Absent | Why it stays absent |
| --- | --- |
| `jq` | the script parses its payload with `/usr/bin/python3`. `node` is also wrong here, because `node` comes from `nvm` and its path moves with the Node version |
| `notify-send` | an earlier version of this hook called it. It was missing, the hook ran, the command failed, and no notification ever appeared. A silent hook is worse than no hook |
| `paplay` | same history, same reason |
| BurntToast | the script builds the toast XML itself, against the AUMID Windows registers for PowerShell by default |

WSLg ships no notification daemon, so `sudo apt install libnotify-bin` may still
show nothing. It is not worth the install.

## Probe

```bash
for h in notify-waiting cbm-code-discovery-gate cbm-session-reminder cbm-subagent-reminder; do
  f="$HOME/.claude/hooks/$h"
  printf '%-26s %s\n' "$h" "$([ -x "$f" ] && echo present || { [ -e "$f" ] && echo 'NOT EXECUTABLE' || echo MISSING; })"
done
```

`NOT EXECUTABLE` is a distinct result and it is the common one after a copy. A
copied file loses its mode bit through some transports, the hook then runs and
fails, and nothing appears. Treat it as `MISSING` and re-run Install step 2.

## Validate

There is no upstream to check, so Validate checks the two things the scripts
depend on at run time.

```bash
[ -x /usr/bin/python3 ] && echo "python3 OK" || echo "python3 FAIL"
command -v powershell.exe >/dev/null 2>&1 && echo "powershell OK" || echo "powershell FAIL"
```

Pass: both `OK`.

`python3 FAIL` means wave 1 did not finish. Report `FAILED` naming
`system-packages`.

`powershell FAIL` is not a stop. It means this machine is not WSL2, so the toast
cannot work. Install the scripts anyway — `notify-waiting` falls back to a
terminal bell — and say in `notes` that the toast is unavailable here.

## Install

No `sudo`.

1. Copy all four scripts from the old machine into `~/.claude/hooks/`:
   ```bash
   mkdir -p "$HOME/.claude/hooks"
   # replace <source> with the path the user gave you
   cp <source>/notify-waiting <source>/cbm-code-discovery-gate \
      <source>/cbm-session-reminder <source>/cbm-subagent-reminder \
      "$HOME/.claude/hooks/"
   ```
2. Set the mode bit. Do this every time, even when the copy looks right:
   ```bash
   chmod +x "$HOME/.claude/hooks/"notify-waiting \
            "$HOME/.claude/hooks/"cbm-*
   ```
3. Create the log directory `notify-waiting` appends to:
   ```bash
   mkdir -p "$HOME/.claude/hooks/logs"
   ```

## Return

```json
{
  "preferredNotifChannel": "terminal_bell",
  "hooks": {
    "PermissionRequest": [
      { "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/notify-waiting\" 'approve tool?'", "async": true, "timeout": 15 } ] }
    ],
    "Notification": [
      { "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/notify-waiting\" 'waiting'", "async": true, "timeout": 15 } ] }
    ],
    "Elicitation": [
      { "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/notify-waiting\" 'input needed'", "async": true, "timeout": 15 } ] }
    ],
    "PreToolUse": [
      { "matcher": "Grep|Glob", "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-code-discovery-gate\"", "timeout": 5 } ] }
    ],
    "PostToolUse": [
      { "matcher": "Read", "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-code-discovery-gate\"", "timeout": 5 } ] }
    ],
    "SessionStart": [
      { "matcher": "startup", "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-session-reminder\"", "timeout": 5 } ] },
      { "matcher": "resume",  "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-session-reminder\"", "timeout": 5 } ] },
      { "matcher": "clear",   "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-session-reminder\"", "timeout": 5 } ] },
      { "matcher": "compact", "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-session-reminder\"", "timeout": 5 } ] }
    ],
    "SubagentStart": [
      { "matcher": "*", "hooks": [ { "type": "command", "command": "\"$HOME/.claude/hooks/cbm-subagent-reminder\"", "timeout": 5 } ] }
    ]
  }
}
```

Two things about this fragment the caller must respect.

`async: true` on the three notifier events is not a preference. PowerShell takes
about 1.5 seconds to start. A synchronous hook adds that 1.5 seconds to every
permission prompt.

`caveman.md` returns its own entries for `PreToolUse`, `PostToolUse`,
`SessionStart`, and `SubagentStart`. The caller **appends** to those arrays. It
does not replace them, or one plugin's hooks silently disappear.

## Verify

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git push origin main --force"},"cwd":"'"$HOME"'/projects/example"}' \
  | "$HOME/.claude/hooks/notify-waiting" "approve tool?"; echo "exit=$?"
```

Expect `exit=0`, and on WSL2 a three-line toast:

```
Claude — example
approve tool? · Bash
VS Code pts/NN · git push origin main --force
```

Line 1 must read `Claude — example`, not `Claude — Bash`. The tool name on line 1
means the script's field delimiter was changed to a tab, which shifts every value
one slot left. The toast still looks plausible, which is what makes it dangerous.

For anything past this — no toast at all, a blank detail line, adding an event,
silencing the notifier — the `notify-on-wait` skill owns it. Do not duplicate its
tests here.
