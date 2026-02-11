# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlaskTracker-db is a PostgreSQL database schema for tracking laboratory gas flasks through their lifecycle - registration, shipment in boxes, status updates (broken/low pressure), and replacement tracking. The system emphasizes data integrity and audit trail maintenance.

## Database Operations

### Applying Migrations
```bash
psql -d your_database_name -f migrations/0001_initial.sql
```

Migrations are numbered sequentially (0001, 0002, etc.). Apply them in order.

### Creating New Migrations
- Never modify existing migration files
- Create new files: `migrations/0002_description.sql`, `0003_description.sql`, etc.
- After schema changes, regenerate ER diagrams in `diagram/`
- Update README.md to reflect schema changes

## Architecture

### Database Schema Design

**Core Entity Model**: The database uses a 6-table design around two main concepts:

1. **Flask Inventory** (`flasks`, `flasks_ref`, `flask_ref_type`)
   - `flasks`: Master table for gas flask records
   - `flasks_ref`: Self-referential relationships (tracks when flask A is replaced by/refilled as flask B)
   - `flask_ref_type`: Categorizes relationship types (e.g., "Refilled", "Replaced")

2. **Shipment Tracking** (`boxes`, `box_content_headers`, `box_content_lines`)
   - `boxes`: Reusable shipping containers
   - `box_content_headers`: Shipment-level data (destination, ready/return timestamps)
   - `box_content_lines`: Item-level data (which flasks are in which shipment)
   - Follows ERP header/lines pattern for one-to-many shipments

**Status Tracking via Timestamps**: Flask status is NOT an enum field. Instead, nullable timestamp columns capture both state and when it occurred:
- `flasks.broken_at`: When flask was marked broken (NULL = not broken)
- `flasks.Low_pressure_at`: When flask reached low pressure (NULL = normal pressure)

**Flask History Tracking**: The `flasks_hist` table automatically captures all changes to the `flasks` table via database triggers. This enables:
- Tracking multiple low pressure cycles per flask
- Complete audit trail of all flask changes
- Historical analysis of flask lifecycle patterns
- No application-level code needed - triggers handle everything automatically

**Name Immutability Pattern**: Critical for audit trail integrity:
- `flasks.name` becomes immutable once flask appears in `box_content_lines` or `flasks_ref`
- `boxes.name` becomes immutable once box appears in `box_content_headers`
- Currently enforced via table comments; application layer must validate
- No database triggers enforce this yet

## Critical Business Rules

### Shipment Lifecycle Constraints
1. **Ready before Return**: `returned_at` can only be set when `ready_at` is filled
   - Not enforced by CHECK constraint yet (application-level validation only)
2. **Unique Active Shipment**: Only one combination of `box_id` + `ready_at` allowed
   - A box can't have two shipments ready at the same timestamp
3. **Flask Appears Once Per Shipment**: Unique `box_content_header_id` + `flask_id`

### Name Immutability Validation
When implementing UPDATE operations:
```sql
-- Check if flask name can be updated
SELECT EXISTS (
    SELECT 1 FROM box_content_lines WHERE flask_id = :flask_id
    UNION
    SELECT 1 FROM flasks_ref WHERE original_flask_id = :flask_id OR new_flask_id = :flask_id
);
-- If TRUE, reject the name update

-- Check if box name can be updated
SELECT EXISTS (
    SELECT 1 FROM box_content_headers WHERE box_id = :box_id
);
-- If TRUE, reject the name update
```

## Schema Inconsistencies

- `flasks.Low_pressure_at` uses inconsistent capitalization (should be `low_pressure_at`)
- This is a known issue; if renaming, create migration and update all references

## Known Future Enhancements

### Audit Columns (✅ IMPLEMENTED)
All core tables now have:
- `created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP`
- `created_user_id TEXT` (FK to users table)
- `updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP`
- `updated_user_id TEXT` (FK to users table)

Flask change history is automatically tracked in `flasks_hist` table via triggers.

### Database-Level Constraint Enforcement
Current gaps to address:
- CHECK constraint for `returned_at` requiring `ready_at`: `(returned_at IS NULL OR ready_at IS NOT NULL)`
- Triggers to prevent name updates when referenced
- Explicit UNIQUE constraints (currently documented in table comments only)

### Stored Procedures
The `procedures/` directory is empty. Candidate procedures:
- `get_flask_history(flask_id)`: Complete shipment history via joins
- `get_flask_relationships(flask_id)`: Recursive CTE for replacement chains
- `validate_shipment(box_id, flask_ids[])`: Pre-shipment validation
- `close_shipment(box_content_header_id)`: Safe return marking

## Query Patterns

### Finding Operational Flasks
```sql
-- Operational = not broken AND not low pressure
SELECT * FROM flasks
WHERE broken_at IS NULL AND "Low_pressure_at" IS NULL;
```

### Finding Active Shipments
```sql
-- In transit = ready but not returned
SELECT * FROM box_content_headers
WHERE ready_at IS NOT NULL AND returned_at IS NULL;
```

### Tracing Flask Relationships
```sql
-- Recursive CTE needed for complete replacement chain
WITH RECURSIVE flask_chain AS (
    SELECT original_flask_id, new_flask_id, 1 as depth
    FROM flasks_ref WHERE original_flask_id = :flask_id
    UNION ALL
    SELECT fr.original_flask_id, fr.new_flask_id, fc.depth + 1
    FROM flasks_ref fr
    JOIN flask_chain fc ON fr.original_flask_id = fc.new_flask_id
)
SELECT * FROM flask_chain;
```

### Flask Shipment History
```sql
-- Join pattern: flasks → box_content_lines → box_content_headers → boxes
SELECT f.name as flask_name, b.name as box_name,
       bch.destination_text, bch.ready_at, bch.returned_at
FROM flasks f
JOIN box_content_lines bcl ON f.id = bcl.flask_id
JOIN box_content_headers bch ON bcl.box_content_header_id = bch.id
JOIN boxes b ON bch.box_id = b.id
WHERE f.id = :flask_id
ORDER BY bch.ready_at DESC;
```

### Flask History and Audit Trail

#### View Complete Change History for a Flask
```sql
-- Shows all changes to a flask over time
SELECT
    changed_at,
    operation,
    old_low_pressure_at,
    new_low_pressure_at,
    old_broken_at,
    new_broken_at,
    old_name,
    new_name,
    changed_by
FROM flasks_hist
WHERE flask_id = :flask_id
ORDER BY changed_at DESC;
```

#### Track All Low Pressure Events
```sql
-- Find all times a flask was marked low pressure
SELECT
    changed_at,
    new_low_pressure_at,
    changed_by
FROM flasks_hist
WHERE flask_id = :flask_id
  AND new_low_pressure_at IS NOT NULL
  AND old_low_pressure_at IS DISTINCT FROM new_low_pressure_at
ORDER BY changed_at;
```

#### Find When Flask Was Marked Broken
```sql
-- Get the exact timestamp and user who marked flask as broken
SELECT
    changed_at,
    new_broken_at,
    changed_by
FROM flasks_hist
WHERE flask_id = :flask_id
  AND new_broken_at IS NOT NULL
  AND old_broken_at IS NULL
LIMIT 1;
```

#### Audit Trail - All Changes in Date Range
```sql
-- View all flask changes in a specific period
SELECT
    fh.flask_id,
    f.name as flask_name,
    fh.operation,
    fh.changed_at,
    fh.changed_by,
    fh.old_low_pressure_at,
    fh.new_low_pressure_at,
    fh.old_broken_at,
    fh.new_broken_at
FROM flasks_hist fh
LEFT JOIN flasks f ON fh.flask_id = f.id
WHERE fh.changed_at BETWEEN :start_date AND :end_date
ORDER BY fh.changed_at DESC;
```

#### Find Flasks with Multiple Low Pressure Cycles
```sql
-- Identify flasks that have gone low pressure multiple times
SELECT
    flask_id,
    COUNT(*) as low_pressure_count
FROM flasks_hist
WHERE new_low_pressure_at IS NOT NULL
  AND old_low_pressure_at IS DISTINCT FROM new_low_pressure_at
GROUP BY flask_id
HAVING COUNT(*) > 1
ORDER BY low_pressure_count DESC;
```

#### Flask Lifecycle Timeline
```sql
-- Complete timeline of a flask including history and shipments
SELECT
    'STATUS_CHANGE' as event_type,
    fh.changed_at as event_time,
    fh.operation as detail,
    CASE
        WHEN fh.new_broken_at IS NOT NULL AND fh.old_broken_at IS NULL THEN 'Marked Broken'
        WHEN fh.new_low_pressure_at IS NOT NULL AND fh.old_low_pressure_at IS NULL THEN 'Marked Low Pressure'
        WHEN fh.new_low_pressure_at IS NULL AND fh.old_low_pressure_at IS NOT NULL THEN 'Pressure Restored'
        ELSE fh.operation
    END as description
FROM flasks_hist fh
WHERE fh.flask_id = :flask_id

UNION ALL

SELECT
    'SHIPMENT' as event_type,
    bch.ready_at as event_time,
    'SHIPPED' as detail,
    'Shipped in box ' || b.name || ' to ' || COALESCE(bch.destination_text, 'unknown')
FROM box_content_lines bcl
JOIN box_content_headers bch ON bcl.box_content_header_id = bch.id
JOIN boxes b ON bch.box_id = b.id
WHERE bcl.flask_id = :flask_id AND bch.ready_at IS NOT NULL

ORDER BY event_time DESC;
```

## Technical Details

- **PostgreSQL Version**: Designed for PostgreSQL 10+
- **Identity Columns**: Uses `GENERATED BY DEFAULT AS IDENTITY` (modern approach) instead of SERIAL
- **Timezone Support**: All timestamps use `TIMESTAMPTZ` for timezone awareness
- **Current Indexes**: Only on `flasks.name` and `boxes.name`
  - Consider adding indexes on foreign keys and timestamp columns for query performance

## Edge Cases to Handle

- **Unreturned Shipments**: `returned_at` stays NULL forever if box never returns
- **Flask Status While In Transit**: Flask can be marked broken after shipment but before return
- **Multiple Replacement Chains**: Flask genealogy can span multiple generations through `flasks_ref`
- **Never-Shipped Flasks**: Flasks with no `box_content_lines` entries remain in inventory

---

**Schema Version**: 0005 (flask history tracking added)
