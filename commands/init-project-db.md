# Initialize Project Database

Initialize a SQLite database for a project with MCP server configuration.

## Parameters
- `{project_path}` - Path to the project (e.g., `projects/MZ-second-brain`)
- `{schema}` - Optional: Schema to use (`second-brain`, `custom`, or path to .sql file)
- `{db_name}` - Optional: Database filename (default: `project.db`)

## Instructions

1. **Verify the project exists**:
   - Check that `{project_path}` exists
   - If not, suggest running `/create-project` first

2. **Create data directory structure**:
   ```
   {project_path}/
   ├── data/
   │   ├── migrations/
   │   └── backups/
   └── receipts/           # For binary attachments
   ```

3. **Determine schema to use**:
   - If `{schema}` is `second-brain`: Use `templates/sqlite-mcp-db/schemas/second-brain.sql`
   - If `{schema}` is a file path: Use that SQL file
   - If `{schema}` is `custom` or not specified: Use `templates/sqlite-mcp-db/schema-template.sql` as starting point

4. **Initialize the database**:
   ```bash
   sqlite3 {project_path}/data/{db_name} < schema.sql
   ```

5. **Copy schema to project for reference**:
   ```bash
   cp schema.sql {project_path}/data/schema.sql
   ```

6. **Get absolute path for MCP configuration**:
   ```bash
   DB_ABSOLUTE_PATH=$(cd {project_path}/data && pwd)/{db_name}
   ```

7. **Create or update MCP configuration**:
   - Check if `{project_path}/.mcp.json` exists
   - If not, create it with the mcpServers section
   - If exists, merge the new server configuration

   Configuration format:
   ```json
   {
     "mcpServers": {
       "{project_name}-db": {
         "type": "stdio",
         "command": "uvx",
         "args": [
           "mcp-server-sqlite",
           "--db-path",
           "{DB_ABSOLUTE_PATH}"
         ],
         "env": {}
       }
     }
   }
   ```

8. **Verify installation**:
   - Check that `uvx` is available
   - If not, inform user to install: `curl -LsSf https://astral.sh/uv/install.sh | sh`

9. **Report to user**:
   - Database path
   - Schema used
   - Tables created
   - MCP configuration added
   - Next steps:
     - Restart Claude Code to pick up MCP configuration
     - Test with "list all tables in the {project_name}-db database"

## Example Usage

```
/init-project-db project_path=projects/MZ-second-brain schema=second-brain
```

Creates:
- `projects/MZ-second-brain/data/project.db` with second-brain schema
- `projects/MZ-second-brain/data/schema.sql` (copy for reference)
- `projects/MZ-second-brain/data/migrations/`
- `projects/MZ-second-brain/data/backups/`
- `projects/MZ-second-brain/receipts/`
- MCP server configuration in `.mcp.json`
