#!/bin/bash
# Backup SQLite database
# Usage: ./backup-db.sh <db_path> [backup_dir]

set -e

DB_PATH="$1"
BACKUP_DIR="${2:-}"

if [ -z "$DB_PATH" ]; then
    echo "Usage: ./backup-db.sh <db_path> [backup_dir]"
    echo ""
    echo "Arguments:"
    echo "  db_path    Path to the SQLite database file"
    echo "  backup_dir Optional backup directory (defaults to data/backups/)"
    exit 1
fi

if [ ! -f "$DB_PATH" ]; then
    echo "Error: Database not found: $DB_PATH"
    exit 1
fi

# Default backup directory
if [ -z "$BACKUP_DIR" ]; then
    BACKUP_DIR="$(dirname "$DB_PATH")/backups"
fi

mkdir -p "$BACKUP_DIR"

# Generate backup filename with timestamp
DB_NAME=$(basename "$DB_PATH" .db)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.db"

echo "Creating backup..."
echo "  Source: $DB_PATH"
echo "  Target: $BACKUP_PATH"

# Use SQLite's backup command for consistency
sqlite3 "$DB_PATH" ".backup '$BACKUP_PATH'"

# Verify backup
BACKUP_SIZE=$(ls -lh "$BACKUP_PATH" | awk '{print $5}')
BACKUP_TABLES=$(sqlite3 "$BACKUP_PATH" ".tables" | wc -w)

echo ""
echo "Backup created successfully!"
echo "  Size: $BACKUP_SIZE"
echo "  Tables: $BACKUP_TABLES"
echo ""

# Optional: compress old backups
OLD_BACKUPS=$(find "$BACKUP_DIR" -name "*.db" -mtime +7 ! -name "*.gz" 2>/dev/null | wc -l)
if [ "$OLD_BACKUPS" -gt 0 ]; then
    echo "Found $OLD_BACKUPS backup(s) older than 7 days."
    read -p "Compress them to save space? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "$BACKUP_DIR" -name "*.db" -mtime +7 ! -name "*.gz" -exec gzip {} \;
        echo "Old backups compressed."
    fi
fi

# List recent backups
echo ""
echo "Recent backups:"
ls -lht "$BACKUP_DIR" | head -6
