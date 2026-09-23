---
tool: skills
verified: 2026-09-09
source: the old machine — these are local skill directories with no upstream
upstream: none
wave: 2
depends_on: []
writes_settings: false
---

# skills

Copies the global skill directories into `~/.claude/skills/`. The reference machine
holds 45 of them.

**Every skill costs tokens in every session, forever.** Claude Code keeps each
skill's `name` and `description` resident in the context prefix of every session,
so it can decide when to trigger one. Forty-five descriptions is a real, permanent
cost on every request you ever make. So this is the one tool where copying
everything is the wrong default.

Ask the user which skills they want on this machine. Offer three answers:

| Answer | Copies |
| --- | --- |
| all | every directory from the source |
| named | only the skills the user lists |
| none for now | nothing; they add skills as they need them |

`setup-machine` itself is a skill and lives in this directory. It is already
present, because it is what is running. Do not overwrite it.

## Probe

```bash
d="$HOME/.claude/skills"
printf 'skills dir  %s\n' "$([ -d "$d" ] && echo present || echo MISSING)"
printf 'count       %s\n' "$(ls -1d "$d"/*/ 2>/dev/null | wc -l)"
ls -1d "$d"/*/ 2>/dev/null | xargs -r -n1 basename | head -50
```

Report the count and the names. Do not treat "fewer than 45" as `MISSING` by
itself — a deliberately smaller set is a valid state on a new machine, and the
choice is the user's.

## Validate

No upstream, so Validate checks each source skill has the `SKILL.md` and the
frontmatter Claude Code needs.

```bash
# replace <source> with the path the user gave you
for dir in <source>/*/; do
  n="$(basename "$dir")"
  if [ ! -r "$dir/SKILL.md" ]; then
    printf '%-30s NO SKILL.md\n' "$n"
  elif ! head -1 "$dir/SKILL.md" | grep -q '^---$'; then
    printf '%-30s NO FRONTMATTER\n' "$n"
  else
    printf '%-30s OK\n' "$n"
  fi
done
```

Pass: every line reads `OK`.

Report `STALE-SOURCE` naming any directory that is not `OK`. A skill without a
`SKILL.md`, or without frontmatter, is silently ignored — it looks installed and
never triggers.

## Install

No `sudo`.

1. Make the directory:
   ```bash
   mkdir -p "$HOME/.claude/skills"
   ```
2. Copy the set the user chose. `cp -rn` copies directories and refuses to
   overwrite, which protects a skill this machine has edited:
   ```bash
   # all
   cp -rn <source>/*/ "$HOME/.claude/skills/"
   # or named, one per line
   cp -rn <source>/<skill-name>/ "$HOME/.claude/skills/"
   ```
3. Some skills carry a `references/` subdirectory. `cp -rn` takes it. Confirm one
   arrived whole:
   ```bash
   find "$HOME/.claude/skills" -maxdepth 2 -name references -type d | head
   ```

## Return

None. Skills load from the directory. No `settings.json` key names them.

```
null
```

`settings.json` does carry a permission that makes skill work quieter, and
`claude-settings.md` owns it:

```json
{ "permissions": { "allow": [ "Read(**/.claude/skills/**)" ] } }
```

## Verify

```bash
d="$HOME/.claude/skills"
fail=0
for dir in "$d"/*/; do
  n="$(basename "$dir")"
  if [ ! -r "$dir/SKILL.md" ]; then printf '%-30s NO SKILL.md\n' "$n"; fail=1
  elif ! grep -qm1 '^name:' "$dir/SKILL.md"; then printf '%-30s NO name:\n' "$n"; fail=1
  elif ! grep -qm1 '^description:' "$dir/SKILL.md"; then printf '%-30s NO description:\n' "$n"; fail=1
  fi
done
printf 'installed   %s\n' "$(ls -1d "$d"/*/ | wc -l)"
[ "$fail" -eq 0 ] && echo "all skills valid" || echo "SOME SKILLS INVALID"
```

Expect the installed count and `all skills valid`.

The skills only appear in the session list after a restart. Say that in `notes` —
otherwise the user restarts nothing, sees no new skills, and concludes the copy
failed.
