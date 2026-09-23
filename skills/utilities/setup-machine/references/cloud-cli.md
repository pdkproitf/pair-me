---
tool: cloud-cli
verified: 2026-09-09
source: AWS and Kubernetes official download endpoints
upstream: https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
wave: 1
depends_on: []
writes_settings: false
---

# cloud-cli

Installs `aws` and `kubectl` into `/usr/local/bin`.

**Separate from `system-packages` on purpose.** Both are single-binary downloads,
not `apt` packages, so neither touches the dpkg lock and both can install in
parallel with everything else in wave 1.

`aws` matters to Claude Code itself on this machine, not only to your own work.
`settings.json` sets `CLAUDE_CODE_USE_BEDROCK=1` with `AWS_PROFILE`, so the model
provider is Bedrock. Without a working `aws` and a logged-in profile, Claude Code
has no model. Say so in the report.

## Probe

```bash
printf '%-8s %s\n' aws     "$(command -v aws     >/dev/null 2>&1 && echo present || echo MISSING)"
printf '%-8s %s\n' kubectl "$(command -v kubectl >/dev/null 2>&1 && echo present || echo MISSING)"
```

## Validate

```bash
curl -fsSI https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip | head -1
curl -fsS  https://dl.k8s.io/release/stable.txt
```

Pass: the first line reads `200`, and the second prints a version such as
`v1.31.4`. An empty second answer means the Kubernetes release channel moved.
Report `STALE-SOURCE`.

## Install

Both need `sudo` for the final move into `/usr/local/bin`. Name both commands in
the report.

1. `aws`:
   ```bash
   cd /tmp
   curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
   unzip -q -o awscliv2.zip
   sudo ./aws/install --update
   rm -rf /tmp/aws /tmp/awscliv2.zip
   ```
   `unzip` is missing on a bare machine. Install it first with
   `sudo apt-get install -y unzip` and say so in the report.
2. `kubectl`, pinned to whatever `stable.txt` returned in Validate:
   ```bash
   cd /tmp
   ver="$(curl -fsS https://dl.k8s.io/release/stable.txt)"
   curl -fsSLO "https://dl.k8s.io/release/${ver}/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   rm -f /tmp/kubectl
   ```

## Return

None. No `settings.json` key names either binary. `settings.json` does set
`AWS_REGION` and `AWS_PROFILE` under `env`, and `claude-settings.md` owns those.

```
null
```

## Verify

```bash
aws --version && kubectl version --client --output=yaml | head -3
```

Expect an `aws-cli/2.x` line, then a client version block.

`aws sts get-caller-identity` is **not** part of Verify. It fails on a machine
with no credentials yet, which is normal at this point and is not an install
failure. Tell the user in `notes` that they still need `aws sso login --profile
<their profile>` before Claude Code can reach Bedrock.
