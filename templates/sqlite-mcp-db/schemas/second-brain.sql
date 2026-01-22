-- Second Brain Schema
-- Personal life management: trips, receipts, todos, ideas, notes
-- Version: 1.0

-- ============================================
-- SCHEMA VERSION TRACKING
-- ============================================
CREATE TABLE IF NOT EXISTS _schema_version (
    version INTEGER PRIMARY KEY,
    applied_at TEXT DEFAULT (datetime('now')),
    description TEXT
);

INSERT INTO _schema_version (version, description)
VALUES (1, 'Initial second-brain schema: trips, receipts, todos, ideas');

-- ============================================
-- TRIPS
-- ============================================
CREATE TABLE IF NOT EXISTS trips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trip_id TEXT UNIQUE NOT NULL,  -- Human-readable ID (e.g., 'trip-001')
    title TEXT NOT NULL,
    location TEXT,
    purpose TEXT,

    -- Dates
    start_date TEXT,               -- YYYY-MM-DD
    end_date TEXT,                 -- YYYY-MM-DD
    duration_days INTEGER,

    -- Status
    status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'confirmed', 'in_progress', 'completed', 'cancelled', 'archived')),

    -- Travel logistics
    flight_needed INTEGER DEFAULT 0,  -- Boolean: 0 or 1
    flight_confirmation TEXT,         -- Primary flight confirmation code

    -- Reimbursement
    is_work_related INTEGER DEFAULT 0,  -- Boolean
    reimbursement_status TEXT CHECK (reimbursement_status IN ('not_applicable', 'pending', 'submitted', 'approved', 'denied')),
    reimbursement_submitted_at TEXT,
    reimbursement_amount REAL,

    -- Metadata
    role TEXT,                     -- e.g., 'speaker', 'attendee', 'organizer'
    notes TEXT,

    -- Calendar sync
    calendar_event_id TEXT,        -- Google Calendar event ID
    calendar_synced_at TEXT,

    -- Provenance
    source_type TEXT,              -- 'calendar', 'email', 'manual'
    source_details TEXT,           -- JSON with extraction details

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_start_date ON trips(start_date);
CREATE INDEX IF NOT EXISTS idx_trips_trip_id ON trips(trip_id);

-- ============================================
-- FLIGHTS
-- ============================================
CREATE TABLE IF NOT EXISTS flights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trip_id INTEGER REFERENCES trips(id) ON DELETE CASCADE,

    type TEXT CHECK (type IN ('outbound', 'return', 'connection')),
    date TEXT,                     -- YYYY-MM-DD

    -- Route
    departure_airport TEXT,
    arrival_airport TEXT,
    route_display TEXT,            -- e.g., 'EWR → SFO → SBA'

    -- Flight details
    airline TEXT,
    flight_number TEXT,
    departure_time TEXT,           -- HH:MM
    arrival_time TEXT,             -- HH:MM (may include +1 for next day)

    -- Booking
    confirmation_code TEXT,
    booking_reference TEXT,
    ticket_number TEXT,
    seat TEXT,

    -- Status
    status TEXT DEFAULT 'confirmed' CHECK (status IN ('booked', 'confirmed', 'checked_in', 'completed', 'cancelled')),

    -- Receipt
    receipt_id INTEGER REFERENCES receipts(id),
    cost REAL,
    currency TEXT DEFAULT 'USD',

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_flights_trip_id ON flights(trip_id);
CREATE INDEX IF NOT EXISTS idx_flights_date ON flights(date);

-- ============================================
-- HOTELS
-- ============================================
CREATE TABLE IF NOT EXISTS hotels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trip_id INTEGER REFERENCES trips(id) ON DELETE CASCADE,

    name TEXT,
    address TEXT,
    city TEXT,
    country TEXT,

    check_in_date TEXT,            -- YYYY-MM-DD
    check_out_date TEXT,           -- YYYY-MM-DD
    nights INTEGER,

    -- Booking
    confirmation_code TEXT,
    booking_source TEXT,           -- 'direct', 'expedia', 'booking.com', etc.

    -- Cost
    cost_per_night REAL,
    total_cost REAL,
    currency TEXT DEFAULT 'USD',

    -- Receipt
    receipt_id INTEGER REFERENCES receipts(id),

    -- Status
    status TEXT DEFAULT 'confirmed' CHECK (status IN ('booked', 'confirmed', 'checked_in', 'completed', 'cancelled')),

    -- Provided by organizer?
    provided_by_organizer INTEGER DEFAULT 0,

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_hotels_trip_id ON hotels(trip_id);

-- ============================================
-- RECEIPTS
-- ============================================
CREATE TABLE IF NOT EXISTS receipts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- What this receipt is for
    trip_id INTEGER REFERENCES trips(id) ON DELETE SET NULL,
    category TEXT CHECK (category IN ('flight', 'hotel', 'meal', 'transport', 'registration', 'other')),
    description TEXT,

    -- Financial
    amount REAL,
    currency TEXT DEFAULT 'USD',
    date TEXT,                     -- YYYY-MM-DD

    -- Vendor
    vendor_name TEXT,
    vendor_type TEXT,

    -- File storage
    file_path TEXT,                -- Relative path within receipts/ directory
    file_type TEXT,                -- 'pdf', 'jpg', 'png', etc.
    original_filename TEXT,

    -- Extraction
    extracted_from TEXT,           -- 'email', 'photo', 'manual'
    extraction_confidence REAL,    -- 0.0 to 1.0
    raw_text TEXT,                 -- OCR or email text

    -- Reimbursement tracking
    reimbursement_eligible INTEGER DEFAULT 1,
    reimbursement_submitted INTEGER DEFAULT 0,

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_receipts_trip_id ON receipts(trip_id);
CREATE INDEX IF NOT EXISTS idx_receipts_category ON receipts(category);
CREATE INDEX IF NOT EXISTS idx_receipts_date ON receipts(date);

-- ============================================
-- TRIP TODOS
-- ============================================
CREATE TABLE IF NOT EXISTS trip_todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trip_id INTEGER REFERENCES trips(id) ON DELETE CASCADE,

    title TEXT NOT NULL,
    description TEXT,
    due_date TEXT,

    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),

    -- Timestamps
    completed_at TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_trip_todos_trip_id ON trip_todos(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_todos_status ON trip_todos(status);

-- ============================================
-- GENERAL TODOS (Not trip-related)
-- ============================================
CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    title TEXT NOT NULL,
    description TEXT,

    -- Categorization
    category TEXT,                 -- User-defined categories
    project TEXT,                  -- Optional project association

    -- Scheduling
    due_date TEXT,
    scheduled_date TEXT,           -- When to work on it

    -- Status
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled', 'deferred')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),

    -- Context
    context TEXT,                  -- e.g., '@home', '@work', '@computer'
    energy_level TEXT CHECK (energy_level IN ('low', 'medium', 'high')),
    estimated_minutes INTEGER,

    -- Recurrence
    is_recurring INTEGER DEFAULT 0,
    recurrence_pattern TEXT,       -- JSON: {"frequency": "weekly", "days": [1, 3, 5]}

    -- Timestamps
    completed_at TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_todos_status ON todos(status);
CREATE INDEX IF NOT EXISTS idx_todos_category ON todos(category);
CREATE INDEX IF NOT EXISTS idx_todos_due_date ON todos(due_date);

-- ============================================
-- IDEAS
-- ============================================
CREATE TABLE IF NOT EXISTS ideas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    title TEXT NOT NULL,
    description TEXT,

    -- Categorization
    category TEXT,                 -- 'project', 'research', 'writing', 'business', etc.
    domain TEXT,                   -- 'physics', 'tech', 'personal', etc.

    -- Development stage
    stage TEXT DEFAULT 'captured' CHECK (stage IN ('captured', 'developing', 'ready', 'in_progress', 'completed', 'abandoned')),

    -- Linking
    related_project TEXT,
    related_ideas TEXT,            -- JSON array of idea IDs

    -- Notes and evolution
    notes TEXT,

    -- Source
    source TEXT,                   -- Where the idea came from
    source_date TEXT,

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_ideas_category ON ideas(category);
CREATE INDEX IF NOT EXISTS idx_ideas_stage ON ideas(stage);

-- ============================================
-- NOTES (General-purpose)
-- ============================================
CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    title TEXT,
    content TEXT NOT NULL,

    -- Categorization
    category TEXT,
    tags TEXT,                     -- JSON array of tags

    -- Linking
    linked_trip_id INTEGER REFERENCES trips(id),
    linked_idea_id INTEGER REFERENCES ideas(id),
    linked_todo_id INTEGER REFERENCES todos(id),

    -- Source
    source TEXT,                   -- 'manual', 'email', 'voice', etc.

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category);

-- ============================================
-- CONTACTS (Trip-related)
-- ============================================
CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    affiliation TEXT,              -- Institution/Company
    role TEXT,                     -- Their role

    -- Relationship
    relationship_type TEXT,        -- 'collaborator', 'organizer', 'student', etc.
    notes TEXT,

    -- Timestamps
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- Trip-Contact junction table
CREATE TABLE IF NOT EXISTS trip_contacts (
    trip_id INTEGER REFERENCES trips(id) ON DELETE CASCADE,
    contact_id INTEGER REFERENCES contacts(id) ON DELETE CASCADE,
    role_in_trip TEXT,             -- 'host', 'co-speaker', 'met_at', etc.
    PRIMARY KEY (trip_id, contact_id)
);

-- ============================================
-- EMAIL TRACKING
-- ============================================
CREATE TABLE IF NOT EXISTS processed_emails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    email_id TEXT UNIQUE NOT NULL,  -- Gmail message ID
    subject TEXT,
    sender TEXT,
    received_at TEXT,

    -- Processing
    processed_at TEXT DEFAULT (datetime('now')),
    action_taken TEXT,             -- 'created_trip', 'updated_trip', 'added_receipt', etc.
    entity_type TEXT,              -- 'trip', 'receipt', 'hotel', etc.
    entity_id INTEGER,             -- ID of created/updated entity

    -- Raw data
    snippet TEXT                   -- First part of email for reference
);

CREATE INDEX IF NOT EXISTS idx_processed_emails_email_id ON processed_emails(email_id);

-- ============================================
-- TRIGGERS
-- ============================================
CREATE TRIGGER IF NOT EXISTS trips_updated_at
AFTER UPDATE ON trips
BEGIN
    UPDATE trips SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS flights_updated_at
AFTER UPDATE ON flights
BEGIN
    UPDATE flights SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS hotels_updated_at
AFTER UPDATE ON hotels
BEGIN
    UPDATE hotels SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS receipts_updated_at
AFTER UPDATE ON receipts
BEGIN
    UPDATE receipts SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS todos_updated_at
AFTER UPDATE ON todos
BEGIN
    UPDATE todos SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS ideas_updated_at
AFTER UPDATE ON ideas
BEGIN
    UPDATE ideas SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- ============================================
-- VIEWS
-- ============================================

-- Upcoming trips
CREATE VIEW IF NOT EXISTS upcoming_trips AS
SELECT * FROM trips
WHERE status IN ('planned', 'confirmed')
  AND start_date >= date('now')
ORDER BY start_date;

-- Work trips needing reimbursement
CREATE VIEW IF NOT EXISTS pending_reimbursements AS
SELECT t.*,
       (SELECT SUM(r.amount) FROM receipts r WHERE r.trip_id = t.id AND r.reimbursement_eligible = 1) as total_receipts
FROM trips t
WHERE t.is_work_related = 1
  AND t.status = 'completed'
  AND (t.reimbursement_status IS NULL OR t.reimbursement_status = 'pending');

-- Active todos
CREATE VIEW IF NOT EXISTS active_todos AS
SELECT * FROM todos
WHERE status IN ('pending', 'in_progress')
ORDER BY
    CASE priority
        WHEN 'urgent' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END,
    due_date;

-- Trip summary with costs
CREATE VIEW IF NOT EXISTS trip_cost_summary AS
SELECT
    t.id,
    t.trip_id,
    t.title,
    t.start_date,
    t.end_date,
    t.status,
    t.is_work_related,
    (SELECT SUM(f.cost) FROM flights f WHERE f.trip_id = t.id) as flight_costs,
    (SELECT SUM(h.total_cost) FROM hotels h WHERE h.trip_id = t.id) as hotel_costs,
    (SELECT SUM(r.amount) FROM receipts r WHERE r.trip_id = t.id AND r.category = 'meal') as meal_costs,
    (SELECT SUM(r.amount) FROM receipts r WHERE r.trip_id = t.id AND r.category = 'transport') as transport_costs,
    (SELECT SUM(r.amount) FROM receipts r WHERE r.trip_id = t.id AND r.category = 'registration') as registration_costs,
    (SELECT SUM(r.amount) FROM receipts r WHERE r.trip_id = t.id) as total_receipt_amount
FROM trips t;
