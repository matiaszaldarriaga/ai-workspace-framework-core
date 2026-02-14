# ai-workspace-framework-core

Minimal shared framework used as a vendored dependency inside project repos.

## What this repo contains

- `rules/` — workspace rules and agent contract
- `commands/` — core reusable commands (workflow + templates)
- `guides/` — domain-specific reference guides for AI agents (compute infrastructure, optimization methodology)
- `templates/` — reusable project templates (e.g. Slidev, sqlite-mcp-db)

## How it is used

Recommended: add this repo as a git submodule inside each project, then link command/rule discovery dirs so both **Cursor** and **Claude Code** see the shared commands.

This repo supports discovery via:
- `.cursor/commands/` and `.cursor/rules/`
- `.claude/commands/`
- `.agent/workflows/`

After cloning or updating commands/rules, run:

```bash
./scripts/init_agent_dirs.sh
```
