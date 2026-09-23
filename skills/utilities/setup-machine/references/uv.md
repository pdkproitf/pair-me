---
tool: uv
verified: 2026-09-09
source: https://astral.sh/uv/install.sh
upstream: https://astral.sh/uv/install.sh
wave: 1
depends_on: []
writes_settings: false
---

# uv

Installs `uv` and `uvx` into `~/.local/bin`. `uv` is the Python tool runner this
machine uses instead of `pipx`.

**`pipx` is deliberately absent.** One Python tool installer is enough. Two means
a tool can be installed twice, from two places, at two versions, and the one on
`PATH` first wins. Do not install `pipx` here.

## Probe

```bash
printf '%-6s %s\n' uv  "$(command -v uv  >/dev/null 2>&1 && echo present || echo MISSING)"
printf '%-6s %s\n' uvx "$(command -v uvx >/dev/null 2>&1 && echo present || echo MISSING)"
```

Both `present` means this tool is done.

## Validate

```bash
curl -fsSLI -o /dev/null -w '%{http_code}\n' https://astral.sh/uv/install.sh
```

Pass: `200`.

Note the `-L`. This URL answers `301` and redirects to the real installer, so a
`HEAD` without `-L` shows `301` and looks like a failure. `-L` follows the
redirect and `-w '%{http_code}'` prints the status of the final response, not the
first one.

Report `STALE-SOURCE` on a `404`, on a `000` (no connection), or on anything else.

## Install

No `sudo`. The installer writes into `~/.local/bin` only.

1. Run the installer:
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
2. `~/.local/bin` must be on `PATH`. Check before you assume the installer did it:
   ```bash
   case ":$PATH:" in *":$HOME/.local/bin:"*) echo "on PATH" ;; *) echo "NOT on PATH" ;; esac
   ```
   `NOT on PATH` means add this line to `~/.zshrc`, then say so in the report so
   the user reloads their shell:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

## Return

None. No `settings.json` key names `uv`.

```
null
```

## Verify

```bash
"$HOME/.local/bin/uv" --version && "$HOME/.local/bin/uvx" --version
```

Expect two version lines and exit 0. Call the absolute path, not the bare name.
A bare `uv` can resolve through a `PATH` entry that this shell has but a hook does
not, which hides a broken install until much later.
