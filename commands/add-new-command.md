# Add a new command

Create a new command file in the centralized `commands/` directory and create symlinks in all relevant agent directories.

## Parameters
- `{command_name}` - The name of the command file (without .md extension, kebab-case recommended)

## Instructions

1. **Create the command file** in `commands/{command_name}.md` with the command content (prompt/instructions for the agent).

2. **Create symlinks** in agent-specific directories:
   - `.cursor/commands/{command_name}.md` → `../../commands/{command_name}.md`
   - `.agent/workflows/{command_name}.md` → `../../commands/{command_name}.md` (Antigravity uses workflows)
   - `.claude/commands/{command_name}.md` → `../../commands/{command_name}.md` (if using Claude Code)

3. **Update documentation** if needed:
   - Update `rules/NORMS.md` if the command should be listed as a canonical command
   - Update `README.md` if the command should be mentioned

4. **Ensure agent directories exist**: Before creating symlinks, ensure the agent directories exist (see NORMS.md for initialization pattern).

## Important

- All commands must be created in the centralized `commands/` directory
- Symlinks must be created for all relevant agent directories:
  - Cursor: `.cursor/commands/`
  - Antigravity: `.agent/workflows/`
  - Claude Code: `.claude/commands/`
- Commands are tracked in git and will be preserved on clone
