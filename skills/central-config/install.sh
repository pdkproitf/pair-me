#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/pdkproitf/skills/main/skills/central-config"
SKILL_FILE="central-config.md"
# $0 is "bash" when piped via curl | bash; use that to detect local vs remote run
if [[ "$0" != "bash" && -f "$(dirname "$0")/$SKILL_FILE" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
  SCRIPT_DIR=""
fi

echo ""
echo "central-config installer"
echo "─────────────────────"
echo ""

# ── Step 1: Tool selection ────────────────────────────────────────────────────

echo "Which AI tool are you installing for?"
echo "  1) Claude Code"
echo "  2) Cursor"
echo "  3) GitHub Copilot"
echo "  4) Windsurf"
echo "  5) Cline"
echo "  6) OpenAI Codex"
echo ""
read -rp "Enter number [1-6]: " tool_choice </dev/tty

case "$tool_choice" in
  1) tool="Claude Code"     ;;
  2) tool="Cursor"          ;;
  3) tool="GitHub Copilot"  ;;
  4) tool="Windsurf"        ;;
  5) tool="Cline"           ;;
  6) tool="OpenAI Codex"    ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# ── Step 2: Global or project-level ──────────────────────────────────────────

echo " Global or project-level installation? "
echo "Install globally (all projects) or for a specific project?"
echo "  1) Global"
echo "  2) Project"
echo ""
read -rp "Enter number [1-2]: " scope_choice </dev/tty

case "$scope_choice" in
  1) scope="global"  ;;
  2) scope="project" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# ── Step 3: Resolve destination ──────────────────────────────────────────────

if [[ "$scope" == "project" ]]; then
  echo ""
  read -rp "Project path [$(pwd)]: " project_path </dev/tty
  project_path="${project_path:-$(pwd)}"
  project_path="${project_path/#\~/$HOME}"

  if [[ ! -d "$project_path" ]]; then
    echo "Directory not found: $project_path"
    exit 1
  fi
fi

case "$tool" in
  "Claude Code")
    if [[ "$scope" == "global" ]]; then
      dest_dir="$HOME/.claude/skills"
      dest="$dest_dir/central-config.md"
      install_note="Ask your AI: 'run the central-config skill' to bootstrap any project's config."
    else
      dest_dir="$project_path/.claude/skills"
      dest="$dest_dir/central-config.md"
      install_note="Ask your AI: 'run the central-config skill' to bootstrap this project's config."
    fi
    ;;
  "Cursor")
    if [[ "$scope" == "global" ]]; then
      dest_dir="$HOME/.cursor/rules"
      dest="$dest_dir/central-config.mdc"
    else
      dest_dir="$project_path/.cursor/rules"
      dest="$dest_dir/central-config.mdc"
    fi
    install_note="Invoke by referencing @central-config in your Cursor chat."
    ;;
  "GitHub Copilot")
    if [[ "$scope" == "global" ]]; then
      echo "GitHub Copilot does not support a global skills directory. Installing project-level."
      read -rp "Project path [$(pwd)]: " project_path </dev/tty
      project_path="${project_path:-$(pwd)}"
      project_path="${project_path/#\~/$HOME}"
    fi
    dest_dir="$project_path/.github/skills"
    dest="$dest_dir/central-config.md"
    install_note="Reference this file from .github/copilot-instructions.md when you want to run it."
    ;;
  "Windsurf")
    if [[ "$scope" == "global" ]]; then
      dest_dir="$HOME/.windsurf/rules"
      dest="$dest_dir/central-config.md"
    else
      dest_dir="$project_path/.windsurf/rules"
      dest="$dest_dir/central-config.md"
    fi
    install_note="Invoke by referencing @central-config in your Windsurf chat."
    ;;
  "Cline")
    if [[ "$scope" == "global" ]]; then
      echo "Cline does not support a global skills directory. Installing project-level."
      read -rp "Project path [$(pwd)]: " project_path </dev/tty
      project_path="${project_path:-$(pwd)}"
      project_path="${project_path/#\~/$HOME}"
    fi
    dest_dir="$project_path/.cline/skills"
    dest="$dest_dir/central-config.md"
    install_note="Reference this file from .clinerules when you want to run it."
    ;;
  "OpenAI Codex")
    if [[ "$scope" == "global" ]]; then
      echo "OpenAI Codex does not support a global skills directory. Installing project-level."
      read -rp "Project path [$(pwd)]: " project_path </dev/tty
      project_path="${project_path:-$(pwd)}"
      project_path="${project_path/#\~/$HOME}"
    fi
    dest_dir="$project_path/.codex/skills"
    dest="$dest_dir/central-config.md"
    install_note="Reference this file from AGENTS.md when you want to run it."
    ;;
esac

# ── Step 4: Confirm before writing ───────────────────────────────────────────

echo "Confirm before writing file with the following details:"
echo "  Tool:        $tool"
echo "  Scope:       $scope"
echo "  Install to:  $dest"
echo ""
read -rp "Proceed? [y/n]: " confirm </dev/tty
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

# ── Step 5: Download and install ─────────────────────────────────────────────

mkdir -p "$dest_dir"

local_source="$SCRIPT_DIR/$SKILL_FILE"

if [[ -n "$SCRIPT_DIR" && -f "$local_source" ]]; then
  cp "$local_source" "$dest"
elif command -v curl &>/dev/null; then
  curl -fsSL "$REPO_RAW/$SKILL_FILE" -o "$dest"
elif command -v wget &>/dev/null; then
  wget -qO "$dest" "$REPO_RAW/$SKILL_FILE"
else
  echo "Error: curl or wget is required."
  exit 1
fi

# ── Step 6: Done ──────────────────────────────────────────────────────────────

echo ""
echo "Installed: $dest"
echo ""
echo "$install_note"
echo ""
