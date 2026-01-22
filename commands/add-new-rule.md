# Add a new rule

Create a new rule file in the centralized `rules/` directory and create symlinks in all relevant agent directories.

## Parameters
- `{rule_name}` - The name of the rule file (without .md extension, kebab-case recommended)

## Instructions

1. **Create the rule file** in `rules/{rule_name}.md` with the rule content.

2. **Create symlinks** in agent-specific directories:
   - `.cursor/rules/{rule_name}.md` → `../../rules/{rule_name}.md`
   - For other agents (Antigravity, Claude Code), document that they should reference rules from `.cursor/rules/` or create their own symlinks if their system supports it.

3. **Update documentation** if needed:
   - Update `rules/NORMS.md` if the new rule affects workspace organization
   - Update `rules/AI-AGENT-CONTRACT.md` if the new rule affects agent behavior
   - Update `README.md` if the rule should be mentioned in the rules index

4. **Ensure agent directories exist**: Before creating symlinks, ensure the agent directories exist (see NORMS.md for initialization pattern).

## Important

- All rules must be created in the centralized `rules/` directory
- Symlinks must be created for all relevant agent directories
- Rules are tracked in git and will be preserved on clone
