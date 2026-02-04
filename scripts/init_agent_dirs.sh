#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if we're vendored (path contains /vendor/ai-workspace-framework-core)
if [[ "$SCRIPT_DIR" == */vendor/ai-workspace-framework-core/scripts ]]; then
  # Vendored: project root is 3 levels up from scripts/
  ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
  LINK_PREFIX="../../vendor/ai-workspace-framework-core"
  CORE_DIR="$ROOT_DIR/vendor/ai-workspace-framework-core"
  echo "Detected vendored installation"
else
  # Not vendored: we're in the framework repo itself
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  LINK_PREFIX="../.."
  CORE_DIR="$ROOT_DIR"
  echo "Detected standalone installation"
fi

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
for cmd in "$CORE_DIR/commands/"*.md; do
  name="$(basename "$cmd")"
  link_file "$LINK_PREFIX/commands/$name" "$ROOT_DIR/.cursor/commands/$name"
  link_file "$LINK_PREFIX/commands/$name" "$ROOT_DIR/.claude/commands/$name"
  link_file "$LINK_PREFIX/commands/$name" "$ROOT_DIR/.agent/workflows/$name"
done

# Link all rules into Cursor rules directory (Cursor reads rules from .cursor/rules/)
for rule in "$CORE_DIR/rules/"*.md; do
  name="$(basename "$rule")"
  link_file "$LINK_PREFIX/rules/$name" "$ROOT_DIR/.cursor/rules/$name"
done

echo "Initialized agent directories:"
echo "  - .cursor/commands -> $LINK_PREFIX/commands/"
echo "  - .cursor/rules    -> $LINK_PREFIX/rules/"
echo "  - .claude/commands -> $LINK_PREFIX/commands/"
echo "  - .agent/workflows -> $LINK_PREFIX/commands/"

