---
name: token-wake
description: Wake the Claude Pro token window automatically — fires a bootstrap at reset+1min which creates a permanent 5h cron routine
input: none — fully automated
phase: setup
---

# token-loop

## When to trigger

Use this skill when the user:
- explicitly invokes `/token-wake` or asks to set up the token window wake routine
- asks to re-align or restart the Claude Pro 5-hour token window automation

Two routines are involved:
- **Bootstrap** (one-shot): fires at reset+1min, starts the window, creates the cron
- **Cron** (recurring): fires every 5h, just prints time — no self-scheduling needed

The skill sets up the bootstrap. Run it once per window cycle to re-align.

---

## Step 1 — Get current time and reset time

Run in parallel (do not print the variables):
```bash
NOW_SGT=$(TZ='Asia/Singapore' date '+%Y-%m-%d %H:%M:%S SGT')
USAGE=$(claude /usage 2>&1 | grep "Current session")
```

Parse `RESET_TIMESTR` from usage: e.g. `"Jul 2 at 12:00am"`

Compute `FIRE_UTC` silently:
```bash
YEAR=$(date +%Y)
RESET_TS=$(TZ='Asia/Singapore' date -j -f "%b %d at %I:%M%p %Y" "${RESET_TIMESTR} ${YEAR}" +%s 2>/dev/null)
FIRE_TS=$((RESET_TS + 60))          # reset + 1 minute
[ "$FIRE_TS" -lt "$(date +%s)" ] && FIRE_TS=$((FIRE_TS + 86400))  # if past, add 24h
FIRE_UTC=$(date -u -r $FIRE_TS +%Y-%m-%dT%H:%M:00Z)
FIRE_SGT=$(TZ='Asia/Singapore' date -r $FIRE_TS '+%b %d %H:%M SGT')
```

## Step 2 — Check existing routines

```
RemoteTrigger action=list
```

Look for a routine named **"Claude Pro Token Window Ping"**. Note its `trigger_id`.

## Step 3 — Print summary

Print exactly:
```
SGT       <NOW_SGT>
Bootstrap <trigger_id or "none">  →  fires <FIRE_SGT>
Action    <"update" | "create">
```

## Step 4 — Create or update bootstrap

**If exists** — update `run_once_at` only:
```
RemoteTrigger action=update trigger_id=<id> body={"enabled": true, "run_once_at": "<FIRE_UTC>"}
```

**If not** — create it with the full body below.

### Bootstrap body

```json
{
  "name": "Claude Pro Token Window Ping",
  "run_once_at": "<FIRE_UTC>",
  "enabled": true,
  "job_config": {
    "ccr": {
      "environment_id": "env_013tHK5oryVJuXd9mWucJyCj",
      "session_context": {
        "model": "claude-haiku-4-5-20251001",
        "sources": [],
        "allowed_tools": ["Bash", "ToolSearch"]
      },
      "events": [{
        "data": {
          "uuid": "<fresh lowercase v4 UUID>",
          "session_id": "",
          "type": "user",
          "parent_tool_use_id": null,
          "message": {
            "role": "user",
            "content": "This is a Claude Code scheduled routine set up by the account owner to trigger their Claude Pro token window at each 5-hour reset. No prior context is needed.\n\nTask 1: Run and print:\n  TZ='Asia/Singapore' date '+%Y-%m-%d %H:%M:%S SGT'\n  date -u '+%Y-%m-%d %H:%M:%S UTC'\n\nTask 2: Print: Claude Pro token window started\n\nTask 3: Create a recurring routine that fires every 5 hours:\n  a. Use ToolSearch with query \"select:RemoteTrigger\" to load the RemoteTrigger tool\n  b. Call RemoteTrigger action=create with this body:\n     {\n       \"name\": \"Claude Pro Token Window Ping\",\n       \"cron_expression\": \"0 */5 * * *\",\n       \"enabled\": true,\n       \"job_config\": {\n         \"ccr\": {\n           \"environment_id\": \"env_013tHK5oryVJuXd9mWucJyCj\",\n           \"session_context\": {\n             \"model\": \"claude-haiku-4-5-20251001\",\n             \"sources\": [],\n             \"allowed_tools\": [\"Bash\"]\n           },\n           \"events\": [{\"data\": {\n             \"uuid\": \"<generate a fresh lowercase v4 UUID>\",\n             \"session_id\": \"\",\n             \"type\": \"user\",\n             \"parent_tool_use_id\": null,\n             \"message\": {\"role\": \"user\", \"content\": \"This is a Claude Code scheduled routine set up by the account owner to trigger their Claude Pro token window at each 5-hour reset. No prior context is needed.\\n\\nRun and print:\\n  TZ='Asia/Singapore' date '+%Y-%m-%d %H:%M:%S SGT'\\n  date -u '+%Y-%m-%d %H:%M:%S UTC'\\n\\nThen print: Claude Pro token window started\"}\n           }}]\n         }\n       },\n       \"mcp_connections\": [{\"connector_uuid\": \"bf7c680d-5fdc-5ef4-b4a0-abadb619bf0a\", \"name\": \"Claude-Code-Remote\", \"url\": \"https://api.anthropic.com/v1/code/mcp/meta\"}]\n     }"
          }
        }
      }]
    }
  },
  "mcp_connections": [{
    "connector_uuid": "bf7c680d-5fdc-5ef4-b4a0-abadb619bf0a",
    "name": "Claude-Code-Remote",
    "url": "https://api.anthropic.com/v1/code/mcp/meta"
  }]
}
```

## Step 5 — Confirm

Print exactly:
```
Done  https://claude.ai/code/routines/<trigger_id>
```

---

## Notes

- Install: `npx skills add pdkproitf/skills@token-wake --global`
- The bootstrap fires **once** at reset+1min, starts the window, then creates the cron
- The cron (`0 */5 * * *` = SGT 8/13/18/23/4h) runs indefinitely with no dependencies
- Re-run `/token-loop` each reset cycle to re-align the bootstrap
- To stop: https://claude.ai/code/routines
