# FlaskTracker Database

## Overview
FlaskTracker-db is a PostgreSQL database designed to track laboratory gas flasks and their shipments in boxes. The system maintains flask inventory, tracks flask relationships (e.g., when flasks are refilled or replaced), and manages the lifecycle of shipping boxes containing flasks.

## Purpose
The database supports:
- Tracking individual laboratory gas flasks and their status
- Recording flask conditions (broken, low pressure)
- Managing shipping boxes and their contents
- Tracking flask shipments to destinations and returns
- Maintaining relationships between flasks (original and replacement/refilled flasks)

## Database Schema

### Core Tables

#### flasks
Main table for tracking laboratory gas flasks.
- `id` - Primary key (auto-generated)
- `name` - Flask identifier (indexed, required)
- `remarks` - Additional notes
- `broken_at` - Timestamp when flask was marked as broken
- `Low_pressure_at` - Timestamp when flask reached low pressure

**Important**: Once a flask is used in `box_content_lines` or `flasks_ref`, its name cannot be updated.

#### boxes
Shipping boxes used to transport flasks.
- `id` - Primary key (auto-generated)
- `name` - Box identifier (indexed, required)
- `remarks` - Additional notes

**Important**: Once a box is used in `box_content_headers`, its name cannot be updated.

#### box_content_headers
Header records for box shipments.
- `id` - Primary key (auto-generated)
- `box_id` - Foreign key to boxes (required)
- `destination_text` - Shipment destination
- `ready_at` - Timestamp when box is ready for shipment
- `returned_at` - Timestamp when box was returned
- `remarks` - Additional notes

**Business Rules**:
- Only one instance of a combination of `box_id` and `ready_at` is allowed
- `returned_at` can only be filled when `ready_at` is filled

#### box_content_lines
Individual flask items within a box shipment.
- `id` - Primary key (auto-generated)
- `box_content_header_id` - Foreign key to box_content_headers (required)
- `flask_id` - Foreign key to flasks (required)
- `remarks` - Additional notes

**Business Rules**:
- The combination of `box_content_header_id` and `flask_id` should be unique

#### flasks_ref
Tracks relationships between flasks (e.g., refills, replacements).
- `id` - Primary key (auto-generated)
- `original_flask_id` - Foreign key to flasks (the original flask)
- `new_flask_id` - Foreign key to flasks (the replacement/refilled flask)
- `flask_ref_type_id` - Foreign key to flask_ref_type

#### flask_ref_type
Types of flask relationships (e.g., "Refilled", "Replaced").
- `id` - Primary key (auto-generated)
- `name` - Type description

#### flasks_hist
Audit history table that automatically tracks all changes to the `flasks` table.
- `id` - Primary key (auto-generated)
- `flask_id` - Reference to the flask (no FK constraint to allow history retention if flask is deleted)
- `old_name` / `new_name` - Name changes
- `old_remarks` / `new_remarks` - Remarks changes
- `old_broken_at` / `new_broken_at` - Broken status changes
- `old_low_pressure_at` / `new_low_pressure_at` - Low pressure status changes
- `operation` - Type of change: INSERT, UPDATE, or DELETE
- `changed_at` - Timestamp of the change
- `changed_by` - User who made the change (FK to user table)

**Automatic Tracking**: This table is populated automatically by database triggers. All INSERT, UPDATE, and DELETE operations on the `flasks` table are logged.

**Use Cases**:
- Track multiple low pressure events for the same flask
- View complete history of when a flask was marked broken
- Audit who changed flask information and when
- Analyze flask lifecycle patterns

## Key Features

### Flask Status Tracking
- Track when flasks become broken or reach low pressure
- Current status stored in `flasks.broken_at` and `flasks.low_pressure_at`
- Complete history of all status changes automatically tracked in `flasks_hist`
- Track multiple low pressure cycles per flask through history table
- Link broken flasks to their replacements via `flasks_ref`

### Box Shipments
- Record when boxes are prepared for shipment
- Track destination information
- Monitor return status
- View contents (flasks) of each shipment

### Flask Relationships
- Track flask lifecycle through replacement/refill relationships
- Maintain reference to original flask when creating replacements
- Categorize relationship types

### Data Integrity
- Name immutability ensures audit trail integrity
- Foreign key constraints maintain referential integrity
- Unique constraints prevent duplicate entries

## Migrations
Database schema migrations are stored in the `migrations/` directory:
- `0001_initial.sql` - Initial schema creation
- `0002_initial_fixes.sql` - Schema fixes
- `0003_betterauth.sql` - User authentication tables and audit columns
- `0004_unique_names.sql` - Unique constraints on flask and box names
- `0005_flasks_history.sql` - Flask history tracking with automatic triggers

To apply migrations, execute the SQL files in order against your PostgreSQL database:
```bash
psql -d your_database_name -f migrations/0001_initial.sql
psql -d your_database_name -f migrations/0002_initial_fixes.sql
psql -d your_database_name -f migrations/0003_betterauth.sql
psql -d your_database_name -f migrations/0004_unique_names.sql
psql -d your_database_name -f migrations/0005_flasks_history.sql
```

## Schema Diagram
A visual representation of the database schema is available in the `diagram/` directory:
- `FlaskTracker_2026-01-27T16_11_21.364Z.png` - Entity relationship diagram
- `FlaskTracker_2026-01-27T16_09_31.586Z.json` - Diagram source data

## Recent Enhancements
- ✅ Audit columns (created_at, created_user_id, updated_at, updated_user_id) added to all tables
- ✅ User authentication tables for tracking who makes changes
- ✅ Unique constraints on flask and box names for data integrity
- ✅ Automatic flask history tracking via `flasks_hist` table and triggers

## Future Enhancements
- History tracking for other tables (boxes, box_content_headers, etc.)
- Stored procedures for common operations (get_flask_history, validate_shipment, etc.)

## Database Setup

### Prerequisites
- PostgreSQL database server
- Database client or psql command-line tool

### Installation
1. Create a new PostgreSQL database
2. Execute the migration scripts in order:
   ```bash
   psql -d your_database_name -f migrations/0001_initial.sql
   ```

## Flask Tracking Workflow

### Typical Workflow
1. **Register Flask**: Add new flask entry to `flasks` table
2. **Prepare Shipment**: Create box in `boxes` table (if not exists)
3. **Create Shipment Header**: Add entry to `box_content_headers` with box_id and destination
4. **Add Flasks to Shipment**: Create entries in `box_content_lines` linking flasks to the shipment
5. **Mark Ready**: Update `ready_at` timestamp when box is prepared
6. **Track Return**: Update `returned_at` timestamp when box returns
7. **Update Flask Status**: Set `broken_at` or `Low_pressure_at` if issues are identified
8. **Record Replacement**: Create new flask and link via `flasks_ref` if flask needs replacement

## License
(Add your license information here)

## Contact
(Add contact information here)
