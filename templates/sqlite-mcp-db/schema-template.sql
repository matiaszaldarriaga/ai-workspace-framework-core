-- Schema Template for SQLite MCP Database
-- Copy and customize for your project

-- ============================================
-- METADATA TABLE (recommended for all projects)
-- ============================================
CREATE TABLE IF NOT EXISTS _schema_version (
    version INTEGER PRIMARY KEY,
    applied_at TEXT DEFAULT (datetime('now')),
    description TEXT
);

INSERT INTO _schema_version (version, description)
VALUES (1, 'Initial schema');

-- ============================================
-- EXAMPLE: Simple Items Table
-- ============================================
CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'archived', 'deleted')),
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    metadata TEXT  -- JSON for flexible additional data
);

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_items_status ON items(status);
CREATE INDEX IF NOT EXISTS idx_items_category ON items(category);

-- ============================================
-- EXAMPLE: Tags (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS item_tags (
    item_id INTEGER REFERENCES items(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (item_id, tag_id)
);

-- ============================================
-- EXAMPLE: Audit Log
-- ============================================
CREATE TABLE IF NOT EXISTS audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT NOT NULL,
    record_id INTEGER,
    action TEXT CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values TEXT,  -- JSON
    new_values TEXT,  -- JSON
    agent_id TEXT,    -- Which agent made the change
    created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================
-- VIEWS (Optional)
-- ============================================
CREATE VIEW IF NOT EXISTS active_items AS
SELECT * FROM items WHERE status = 'active';

-- ============================================
-- TRIGGERS (Optional - for updated_at)
-- ============================================
CREATE TRIGGER IF NOT EXISTS items_updated_at
AFTER UPDATE ON items
BEGIN
    UPDATE items SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- ============================================
-- CUSTOMIZATION NOTES
-- ============================================
--
-- 1. Add your domain-specific tables below
-- 2. Use TEXT for dates (ISO 8601 format: 'YYYY-MM-DD HH:MM:SS')
-- 3. Use TEXT + JSON for flexible/evolving schemas
-- 4. Add indexes for frequently queried columns
-- 5. Consider foreign keys for referential integrity
-- 6. Use CHECK constraints for valid values
--
-- Common patterns:
--   - status columns: CHECK (status IN ('value1', 'value2'))
--   - timestamps: DEFAULT (datetime('now'))
--   - soft delete: status = 'deleted' instead of DELETE
--   - audit trail: trigger to log changes
