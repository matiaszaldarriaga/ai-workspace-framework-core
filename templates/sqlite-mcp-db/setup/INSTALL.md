# SQLite MCP Database Installation

## Prerequisites

### 1. SQLite (usually pre-installed)

```bash
# Check if installed
sqlite3 --version

# macOS (if needed)
brew install sqlite

# Ubuntu/Debian
sudo apt-get install sqlite3
```

### 2. UV (Python Package Manager)

The MCP SQLite server is installed via `uvx` (uv's tool runner):

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify installation
uv --version
uvx --help
```

### 3. MCP SQLite Server

No separate installation needed - `uvx` runs it directly:

```bash
# Test the server
uvx mcp-server-sqlite --help

# Output should show:
# Usage: mcp-server-sqlite [OPTIONS]
# Options:
#   --db-path PATH  Path to SQLite database
```

## Claude Code Configuration

### Project-Level Configuration

Create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "project-db": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "mcp-server-sqlite",
        "--db-path",
        "/absolute/path/to/projects/my-project/data/project.db"
      ],
      "env": {}
    }
  }
}
```

**Important**: Use absolute paths. The MCP server runs as a subprocess and won't resolve relative paths correctly.

### Or Use CLI Command

```bash
# Add to project scope (shared via git)
claude mcp add --transport stdio --scope project project-db -- uvx mcp-server-sqlite --db-path /path/to/project.db

# Add to user scope (personal, cross-project)
claude mcp add --transport stdio --scope user second-brain -- uvx mcp-server-sqlite --db-path /path/to/brain.db
```

### Workspace-Level Configuration

To make a database available across all projects in a workspace, add `.mcp.json` at the workspace root:

```json
{
  "mcpServers": {
    "second-brain": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "mcp-server-sqlite",
        "--db-path",
        "/Users/your-username/path/to/projects/MZ-second-brain/data/brain.db"
      ],
      "env": {}
    }
  }
}
```

## Verifying Setup

### 1. Test Database Creation

```bash
# Create test database
sqlite3 /tmp/test.db "CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT);"
sqlite3 /tmp/test.db "INSERT INTO test (value) VALUES ('hello');"
sqlite3 /tmp/test.db "SELECT * FROM test;"
```

### 2. Test MCP Server

```bash
# Run server manually (will wait for MCP messages on stdin)
uvx mcp-server-sqlite --db-path /tmp/test.db

# Press Ctrl+C to exit
```

### 3. Test in Claude Code

After configuring `.claude/settings.local.json`:

1. Restart Claude Code (or reload the window)
2. Ask the agent to query the database:
   - "List all tables in the database"
   - "Show me the schema for the trips table"
   - "Select all trips"

## Multiple Databases

You can configure multiple databases in `.mcp.json`:

```json
{
  "mcpServers": {
    "second-brain": {
      "type": "stdio",
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "/path/to/brain.db"],
      "env": {}
    },
    "project-data": {
      "type": "stdio",
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "/path/to/project.db"],
      "env": {}
    }
  }
}
```

Each appears as a separate tool set to the agent.

## Troubleshooting

### "uvx: command not found"

```bash
# Add uv to PATH
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### "mcp-server-sqlite: not found"

This usually means network issues. `uvx` downloads on first run:

```bash
# Pre-download the package
uv tool install mcp-server-sqlite

# Then use uvx as normal
uvx mcp-server-sqlite --help
```

### Database file not created

SQLite creates the database file on first write:

```bash
# Ensure directory exists
mkdir -p /path/to/data

# Initialize with schema
sqlite3 /path/to/data/project.db < schema.sql
```

### Permission Issues

```bash
# Check MCP server can access the path
ls -la /path/to/data/

# Ensure write permissions
chmod 755 /path/to/data
chmod 644 /path/to/data/project.db
```
