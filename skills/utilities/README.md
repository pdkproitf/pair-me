# Utility Skills

> Portable AI skills for managing the tool itself — not tied to any one profession.

Unlike `engineers/`, which groups skills by the audience using them, these skills are cross-cutting: they manage the AI session or account, regardless of what you're working on.

---

## Skills

### [token-wake](token-wake/)

> Stop losing Claude Pro tokens while you sleep.

Claude Pro's 5-hour window only starts when you send your first message after a reset. `token-wake` sends that message automatically — 1 minute after each reset — so your window starts the moment it's available, whether you're at your desk or not.

```bash
npx skills add pdkproitf/skills@token-wake --global
```

---

## Install skills

Install a specific skill:
```bash
npx skills add pdkproitf/skills@<skill-name>
```

Browse everything available in the repo:
```bash
npx skills add pdkproitf/skills --list
```
