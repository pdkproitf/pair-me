---
tool: system-packages
verified: 2026-09-09
source: the distribution package archive (apt on Debian and Ubuntu)
upstream: apt
wave: 1
depends_on: []
writes_settings: false
---

# system-packages

Installs `git`, `rg`, `gh`, `docker`, `python3`. One agent installs all five.

**Why one agent and not five.** `apt` takes an exclusive lock on
`/var/lib/dpkg/lock-frontend`. Two `apt install` commands at the same time make
the second one fail with `Could not get lock`. A fan-out here would look like a
random failure, so these five stay serial inside one agent.

`python3` matters more than its size suggests. The hook scripts parse their JSON
payload with `/usr/bin/python3`, because `jq` is not installed and must not be.
See `hooks.md`.

## Probe

```bash
for b in git rg gh docker python3; do
  printf '%-10s %s\n' "$b" "$(command -v "$b" >/dev/null 2>&1 && echo present || echo MISSING)"
done
```

All five `present` means this tool is done.

## Validate

```bash
sudo apt-get update -qq && \
for p in git ripgrep gh docker.io python3; do
  apt-cache policy "$p" | grep -q 'Candidate: [^(]' && echo "$p OK" || echo "$p NO-CANDIDATE"
done
```

Pass: every line ends `OK`. A `NO-CANDIDATE` line means the package name changed
in this distribution, or `gh` needs its own apt source added first. Stop and
report `STALE-SOURCE` naming the package.

The `apt` package name differs from the binary name for two of these. `rg` comes
from `ripgrep`. `docker` comes from `docker.io` on Debian and Ubuntu. Installing
the binary name instead fails, or installs the wrong thing.

## Install

Requires `sudo`. Name the command in the report.

1. Refresh the index:
   ```bash
   sudo apt-get update
   ```
2. Install only what the Probe reported `MISSING`:
   ```bash
   sudo apt-get install -y git ripgrep gh docker.io python3
   ```
3. `docker` needs your user in the `docker` group, or every `docker` command needs
   `sudo`:
   ```bash
   sudo usermod -aG docker "$USER"
   ```
   The group applies at the next login. Say so in the report — a `docker` command
   in this same session still fails, and that is expected, not a failure.

## Return

None. These are system binaries and no `settings.json` key names them.

```
null
```

## Verify

```bash
git --version && rg --version | head -1 && gh --version | head -1 && \
  docker --version && /usr/bin/python3 --version
```

Expect five version lines and exit 0. `python3` must answer at
**`/usr/bin/python3`** exactly, because the hooks hard-code that path. A `python3`
that only exists on `PATH` through a virtual environment does not satisfy this.
