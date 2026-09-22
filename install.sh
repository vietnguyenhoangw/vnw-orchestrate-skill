#!/usr/bin/env bash
set -euo pipefail

if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR=""
fi

if [ -z "$SCRIPT_DIR" ]; then
  echo "install.sh requires a local checkout; clone the repo and run it from there:" >&2
  echo "  git clone https://github.com/vietnguyenhoangw/vnw-orchestrate-skill.git" >&2
  echo "  cd vnw-orchestrate-skill && ./install.sh" >&2
  exit 1
fi

mkdir -p "$HOME/.claude/skills"
rm -rf "$HOME/.claude/skills/orchestrate"
cp -R "$SCRIPT_DIR/skills/orchestrate" "$HOME/.claude/skills/orchestrate"
echo "Installed skill: $HOME/.claude/skills/orchestrate"
