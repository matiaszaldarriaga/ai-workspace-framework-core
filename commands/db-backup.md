# Backup Project Database

Create a timestamped backup of a project's SQLite database.

## Parameters
- `{project_path}` - Path to the project (e.g., `projects/MZ-second-brain`)
- `{db_name}` - Optional: Database filename (default: `project.db`)

## Instructions

1. **Locate the database**:
   - Check `{project_path}/data/{db_name}` exists
   - If not found, list available .db files in data/ directory

2. **Create backup directory if needed**:
   ```bash
   mkdir -p {project_path}/data/backups
   ```

3. **Generate timestamped backup**:
   ```bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   sqlite3 {project_path}/data/{db_name} ".backup '{project_path}/data/backups/{db_name_without_ext}_${TIMESTAMP}.db'"
   ```

4. **Verify the backup**:
   - Check file size
   - Count tables in backup
   - Report any issues

5. **Report to user**:
   - Backup path and size
   - Number of tables backed up
   - List recent backups in the directory

## Example Usage

```
/db-backup project_path=projects/MZ-second-brain
```

## Notes

- Uses SQLite's `.backup` command for consistency (handles concurrent reads)
- Backups are stored in `{project_path}/data/backups/`
- Consider running before major changes or migrations
- Old backups can be manually compressed with `gzip`
