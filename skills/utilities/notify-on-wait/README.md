# notify-on-wait

> A desktop toast when your session stops and waits for you.

---

## What it does

A session that stops for a permission prompt, a question, an MCP input request, or simply goes idle gives no signal outside the terminal — you find out when you look. `notify-on-wait` operates the desktop notifier that covers those waiting states: it explains what each toast says, tests the notifier end to end (the script alone, an empty payload, the field framing, the settings wiring, then a live prompt), diagnoses why no toast appeared, silences the notifier, and adds or removes a waiting-state event.

It is scoped to *waiting* states only — not "turn finished" pings, and not mobile push (that's a separate setting).

---

## When to use

- No toast appeared and you want to know which link in the chain broke
- You want to test the notifier without waiting for a real prompt
- Silencing notifications for a session, or adding a new waiting event

---

## Install

```bash
npx skills add pdkproitf/skills@notify-on-wait --global
```

---

## Usage

**Claude Code:**
```
/notify-on-wait test the notifier
/notify-on-wait why didn't I get a toast
/notify-on-wait silence it
```

**Other tools:**
```
@notify-on-wait <test | diagnose | silence | add event | remove event>
```

---

## Output

A verdict per link in the chain — notifier script, payload handling, field framing, settings wiring, live prompt — plus the specific edit that fixes the broken one.
