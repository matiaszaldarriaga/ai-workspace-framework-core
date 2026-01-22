# Apply Database Migrations

Apply pending SQL migrations to a project's database.

## Parameters
- `{project_path}` - Path to the project (e.g., `projects/MZ-second-brain`)
- `{db_name}` - Optional: Database filename (default: `project.db`)

## Instructions

1. **Locate the database and migrations**:
   - Database: `{project_path}/data/{db_name}`
   - Migrations: `{project_path}/data/migrations/`

2. **Get current schema version**:
   ```sql
   SELECT MAX(version) FROM _schema_version;
   ```

3. **List available migrations**:
   - Pattern: `NNN_description.sql` (e.g., `002_add_receipts.sql`)
   - Sort numerically by prefix

4. **Identify pending migrations**:
   - Migrations with version > current version

5. **If no pending migrations**:
   - Report "Database is up to date"
   - Show current version

6. **For each pending migration** (in order):

   a. **Create backup first**:
      ```bash
      /db-backup project_path={project_path}
      ```

   b. **Apply migration**:
      ```bash
      sqlite3 {project_path}/data/{db_name} < migration.sql
      ```

   c. **Record in version table**:
      ```sql
      INSERT INTO _schema_version (version, description)
      VALUES ({version}, '{description}');
      ```

   d. **Report success or failure**

7. **Report final state**:
   - Migrations applied
   - Current schema version
   - Any errors encountered

## Migration File Format

```sql
-- Migration: 002_add_categories
-- Description: Add categories table for organizing items

CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    parent_id INTEGER REFERENCES categories(id),
    created_at TEXT DEFAULT (datetime('now'))
);

-- Add category_id to existing items table
ALTER TABLE items ADD COLUMN category_id INTEGER REFERENCES categories(id);
```

## Example Usage

```
/db-migrate project_path=projects/MZ-second-brain
```

## Notes

- Always backup before migrating
- Migrations should be idempotent when possible (use `IF NOT EXISTS`)
- Test migrations on a backup first for complex changes
- Never modify applied migrations - create new ones instead
