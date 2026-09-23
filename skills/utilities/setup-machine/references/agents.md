---
tool: agents
verified: 2026-09-09
source: the old machine — these are local Markdown files with no upstream
upstream: none
wave: 2
depends_on: []
writes_settings: false
---

# agents

Copies the global agent definitions into `~/.claude/agents/`. Six files on the
reference machine:

| File | Does |
| --- | --- |
| `codebase-indexer.md` | builds the code graph in the background |
| `codebase-memory.md` | task-directed graph verification |
| `codebase-memory-scout.md` | fast provisional graph lookup |
| `codebase-memory-auditor.md` | bounded-scope graph audit |
| `committer.md` | groups the working tree into conventional commits |
| `pr-creator.md` | takes a branch to an open pull request |

`tool-installer.md` also lives in this directory. It is part of the
`setup-machine` skill, so copy it too if it is not already there — an agent cannot
install itself, so the caller needs it before any fan-out starts.

## Probe

```bash
d="$HOME/.claude/agents"
printf 'agents dir  %s\n' "$([ -d "$d" ] && echo present || echo MISSING)"
ls -1 "$d"/*.md 2>/dev/null | xargs -r -n1 basename
printf 'count       %s\n' "$(ls -1 "$d"/*.md 2>/dev/null | wc -l)"
```

Report the count and the names. A count of 6 or more with the six names above
present means this tool is done.

A partial set is the interesting case, and it is `MISSING`, not `PRESENT`. Copy
only the absent files, so a locally edited agent on this machine is not
overwritten.

## Validate

No upstream, so Validate checks that each file the caller intends to copy is
readable and has the frontmatter Claude Code needs.

```bash
# replace <source> with the path the user gave you
for f in <source>/*.md; do
  head -1 "$f" | grep -q '^---$' && \
    printf '%-34s frontmatter OK\n' "$(basename "$f")" || \
    printf '%-34s NO FRONTMATTER\n'  "$(basename "$f")"
done
```

Pass: every line reads `frontmatter OK`.

A `NO FRONTMATTER` file is silently ignored by Claude Code. It appears installed,
it never loads, and nothing says why. Report `STALE-SOURCE` naming that file.

## Install

No `sudo`.

1. Make the directory:
   ```bash
   mkdir -p "$HOME/.claude/agents"
   ```
2. Copy only the files the Probe reported absent. `cp -n` refuses to overwrite,
   which protects an agent this machine has edited:
   ```bash
   cp -n <source>/*.md "$HOME/.claude/agents/"
   ```
3. List what arrived, so the report carries the real names:
   ```bash
   ls -1 "$HOME/.claude/agents"/*.md | xargs -n1 basename
   ```

## Return

None. Agents load from the directory. No `settings.json` key names them.

```
null
```

## Verify

```bash
d="$HOME/.claude/agents"
for f in "$d"/*.md; do
  n="$(/usr/bin/python3 - "$f" <<'PY'
import re, sys
t = open(sys.argv[1]).read()
m = re.match(r"^---\n(.*?)\n---", t, re.S)
if not m:
    print("NO-FRONTMATTER"); raise SystemExit
b = m.group(1)
name = re.search(r"^name:\s*(\S+)", b, re.M)
desc = re.search(r"^description:\s*\S", b, re.M)
print((name.group(1) if name else "NO-NAME") + ("" if desc else " NO-DESCRIPTION"))
PY
)"
  printf '%-34s %s\n' "$(basename "$f")" "$n"
done
```

Expect one `name:` value per file, and no `NO-NAME`, `NO-DESCRIPTION`, or
`NO-FRONTMATTER`.

A missing `description` is worth failing on. Claude Code needs it to decide when to
launch the agent, so an agent without one is installed and unreachable.
