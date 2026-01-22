# SQLite MCP Database Framework

A reusable framework for adding SQLite databases to projects, accessible by AI agents via MCP (Model Context Protocol).

## Overview

This system enables:
- **Local SQLite databases** per project
- **AI agent access** via MCP server
- **Structured data management** with schema versioning
- **Future API exposure** via tunnels (optional)

## Architecture

```
project/
├── data/
│   ├── project.db           # SQLite database
│   ├── schema.sql           # Current schema definition
│   ├── migrations/          # Schema migrations
│   │   └── 001_initial.sql
│   └── backups/             # Database backups
├── receipts/                # Binary attachments (receipts, documents)
└── .mcp.json                # MCP server configuration
```

## Quick Start

### 1. Install SQLite MCP Server

Requires `uv` (Python package manager):

```bash
# Install uv if not present
curl -LsSf https://astral.sh/uv/install.sh | sh

# Test SQLite MCP server
uvx mcp-server-sqlite --db-path /tmp/test.db
```

### 2. Initialize Database for a Project

Use the `/init-project-db` command:

```
/init-project-db project_path=projects/my-project schema=second-brain
```

Or manually:

```bash
# Create directories
mkdir -p projects/my-project/data/migrations
mkdir -p projects/my-project/data/backups
mkdir -p projects/my-project/receipts

# Initialize database with schema
sqlite3 projects/my-project/data/project.db < schema.sql
```

### 3. Configure MCP Server

Add to project's `.mcp.json`:

```json
{
  "mcpServers": {
    "project-db": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "mcp-server-sqlite",
        "--db-path",
        "ABSOLUTE_PATH/projects/my-project/data/project.db"
      ],
      "env": {}
    }
  }
}
```

### 4. Use via AI Agent

Once configured, agents can:
- Query data: `SELECT * FROM trips WHERE status = 'planned'`
- Insert records: `INSERT INTO trips (title, start_date) VALUES (...)`
- Update data: `UPDATE trips SET status = 'completed' WHERE id = ?`

## Available Schemas

### `second-brain`
Personal life management: trips, receipts, todos, ideas, notes.

### `custom`
Use `schema-template.sql` as a starting point for project-specific schemas.

## Commands

| Command | Description |
|---------|-------------|
| `/init-project-db` | Initialize database for a project |
| `/db-backup` | Create timestamped backup |
| `/db-migrate` | Apply pending migrations |
| `/db-export` | Export to JSON/CSV |

## Schema Versioning

Use numbered migration files:

```
data/migrations/
├── 001_initial.sql
├── 002_add_receipts.sql
└── 003_add_categories.sql
```

Each migration should be idempotent when possible.

## Backup Strategy

```bash
# Manual backup
./scripts/backup-db.sh projects/my-project/data/project.db

# Backups stored in data/backups/ with timestamps
```

## Exposing via API (Future)

For remote access, use the same pattern as `projects/collections-service`:

1. Create a FastAPI wrapper around the database
2. Expose via Cloudflare Tunnel or similar
3. Add authentication layer

## Directory Structure

```
templates/sqlite-mcp-db/
├── README.md              # This file
├── schema-template.sql    # Generic schema template
├── schemas/
│   └── second-brain.sql   # Pre-built schema for personal management
├── setup/
│   └── INSTALL.md         # Detailed installation instructions
└── scripts/
    ├── init-db.sh         # Database initialization
    └── backup-db.sh       # Backup script
```

## MCP Server Capabilities

The SQLite MCP server provides these tools:

| Tool | Description |
|------|-------------|
| `read_query` | Execute SELECT queries |
| `write_query` | Execute INSERT/UPDATE/DELETE |
| `create_table` | Create new tables |
| `list_tables` | List all tables |
| `describe_table` | Show table schema |
| `append_insight` | Add business insights |

## Security Notes

- Local databases only (no network exposure by default)
- MCP server runs with user permissions
- Backup before migrations
- Consider encryption for sensitive data

## Troubleshooting

### MCP server not found
```bash
# Ensure uv is installed
which uv || curl -LsSf https://astral.sh/uv/install.sh | sh

# Test the server directly
uvx mcp-server-sqlite --help
```

### Database locked
```bash
# Check for other connections
lsof projects/my-project/data/project.db

# Ensure only one MCP server instance per database
```

### Permission denied
```bash
# Check file permissions
ls -la projects/my-project/data/project.db

# Fix if needed
chmod 644 projects/my-project/data/project.db
```
