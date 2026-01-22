#!/bin/bash
# Initialize SQLite database for a project
# Usage: ./init-db.sh <db_path> [schema_file]

set -e

DB_PATH="$1"
SCHEMA_FILE="${2:-}"

if [ -z "$DB_PATH" ]; then
    echo "Usage: ./init-db.sh <db_path> [schema_file]"
    echo ""
    echo "Arguments:"
    echo "  db_path     Path to the SQLite database file"
    echo "  schema_file Optional path to SQL schema file"
    echo ""
    echo "Examples:"
    echo "  ./init-db.sh projects/my-project/data/project.db"
    echo "  ./init-db.sh projects/my-project/data/brain.db schemas/second-brain.sql"
    exit 1
fi

# Resolve to absolute path
DB_PATH=$(cd "$(dirname "$DB_PATH")" 2>/dev/null && pwd)/$(basename "$DB_PATH") || {
    # Directory doesn't exist yet
    DB_DIR=$(dirname "$DB_PATH")
    mkdir -p "$DB_DIR"
    DB_PATH="$DB_DIR/$(basename "$DB_PATH")"
}

DB_DIR=$(dirname "$DB_PATH")

echo "Initializing database at: $DB_PATH"

# Create directory structure
mkdir -p "$DB_DIR/migrations"
mkdir -p "$DB_DIR/backups"

# Check if database already exists
if [ -f "$DB_PATH" ]; then
    echo "Warning: Database already exists at $DB_PATH"
    read -p "Do you want to back it up and reinitialize? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_NAME="$DB_DIR/backups/$(basename "$DB_PATH" .db)_$(date +%Y%m%d_%H%M%S).db"
        cp "$DB_PATH" "$BACKUP_NAME"
        echo "Backed up to: $BACKUP_NAME"
        rm "$DB_PATH"
    else
        echo "Aborting."
        exit 0
    fi
fi

# Create database with schema if provided
if [ -n "$SCHEMA_FILE" ]; then
    if [ ! -f "$SCHEMA_FILE" ]; then
        echo "Error: Schema file not found: $SCHEMA_FILE"
        exit 1
    fi
    echo "Applying schema from: $SCHEMA_FILE"
    sqlite3 "$DB_PATH" < "$SCHEMA_FILE"

    # Copy schema to project for reference
    cp "$SCHEMA_FILE" "$DB_DIR/schema.sql"
    echo "Schema copied to: $DB_DIR/schema.sql"
else
    # Create empty database with version tracking
    sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS _schema_version (
    version INTEGER PRIMARY KEY,
    applied_at TEXT DEFAULT (datetime('now')),
    description TEXT
);
INSERT INTO _schema_version (version, description) VALUES (0, 'Empty database initialized');
EOF
fi

# Verify
echo ""
echo "Database initialized successfully!"
echo ""
echo "Tables:"
sqlite3 "$DB_PATH" ".tables"
echo ""
echo "Schema version:"
sqlite3 "$DB_PATH" "SELECT * FROM _schema_version ORDER BY version DESC LIMIT 1;"
echo ""
echo "Next steps:"
echo "1. Configure MCP server in .claude/settings.local.json"
echo "2. Add the following configuration:"
echo ""
echo '{'
echo '  "mcpServers": {'
echo '    "project-db": {'
echo '      "command": "uvx",'
echo '      "args": ["mcp-server-sqlite", "--db-path", "'"$DB_PATH"'"]'
echo '    }'
echo '  }'
echo '}'
