#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$ROOT_DIR/.cursor/commands" "$ROOT_DIR/.cursor/rules"
mkdir -p "$ROOT_DIR/.claude/commands"
mkdir -p "$ROOT_DIR/.agent/workflows"

link_file () {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

# Link all commands into agent-specific command directories
for cmd in "$ROOT_DIR/commands/"*.md; do
  name="$(basename "$cmd")"
  link_file "../../commands/$name" "$ROOT_DIR/.cursor/commands/$name"
  link_file "../../commands/$name" "$ROOT_DIR/.claude/commands/$name"
  link_file "../../commands/$name" "$ROOT_DIR/.agent/workflows/$name"
done

# Link all rules into Cursor rules directory (Cursor reads rules from .cursor/rules/)
for rule in "$ROOT_DIR/rules/"*.md; do
  name="$(basename "$rule")"
  link_file "../../rules/$name" "$ROOT_DIR/.cursor/rules/$name"
done

echo "Initialized agent directories:"
echo "  - .cursor/commands -> commands/"
echo "  - .cursor/rules    -> rules/"
echo "  - .claude/commands -> commands/"
echo "  - .agent/workflows -> commands/"

