---
tool: statusline
verified: 2026-10-26
source: https://github.com/stephenleo/cship
upstream: https://cship.dev/install.sh
wave: 2
depends_on: []
writes_settings: true
---

# statusline

Installs `cship` — a Rust binary that renders a colored Claude Code status line
showing model, context bar with percentage, read/write token counts, and
session cost with threshold-based color escalation.

Upstream: <https://github.com/stephenleo/cship>

## Probe

```bash
printf '%-18s %s\n' cship "$(command -v cship >/dev/null 2>&1 && cship --version 2>/dev/null || echo MISSING)"
printf '%-18s %s\n' cship-config "$([ -r "$HOME/.config/cship.toml" ] && echo present || echo MISSING)"
```

## Validate

```bash
curl -fsSL --head https://cship.dev/install.sh >/dev/null 2>&1 && echo "upstream OK" || echo "upstream FAIL"
```

Pass: `upstream OK`.

## Install

No `sudo`.

```bash
curl -fsSL https://cship.dev/install.sh | bash -s -- --yes
```

The installer places the binary at `~/.local/bin/cship`, creates a starter
config at `~/.config/cship.toml`, and wires `statusLine` into
`~/.claude/settings.json`. After install, overwrite the config with the
project standard and install the wrapper script:

```bash
cp "$HOME/.claude/skills/setup-machine/references/statusline-template.toml" "$HOME/.config/cship.toml"
cp "$HOME/.claude/skills/setup-machine/references/statusline.sh" "$HOME/.claude/statusline.sh"
chmod +x "$HOME/.claude/statusline.sh"
```

The template lives at `references/statusline-template.toml` — single source of
truth for the config. See that file for the full color scheme and layout docs.

## Return

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

`statusline.sh` pipes the status JSON through `cship`, then through `perl` to
humanize token counts (150000 becomes 150k) while preserving ANSI color codes
and decimal values like `$2.31`, and to inject the git repo basename as a
prefix of the branch name (e.g. `my-app:main`). It then appends the session
name (or session ID when unnamed) in gray.

## Verify

```bash
echo '{"context_window":{"used_percentage":45,"total_input_tokens":50000,"total_output_tokens":5000,"total_tokens":55000,"max_tokens":200000},"model":{"id":"us.anthropic.claude-opus-4-6-v1","name":"Claude Opus 4.6"},"cost":{"total_cost":1.25}}' \
  | "$HOME/.claude/statusline.sh"; echo "exit=$?"
```

Expect `exit=0` and a colored line with model name, context bar, percentage,
cost, and session name. An empty line with `exit=0` means the config is not loading — check
`~/.config/cship.toml` exists and parses (`cship explain` for diagnostics).
