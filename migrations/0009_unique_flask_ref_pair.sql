-- Migration 0009: Add unique constraint on flask reference pairs
-- Prevents duplicate relationships between the same two flasks
-- Applied: YYYY-MM-DD

BEGIN;

-- Add unique index on (original_flask_id, new_flask_id) combination
-- This ensures each flask relationship is recorded only once
CREATE UNIQUE INDEX flasks_ref_unique_index_1
    ON flasks_ref (original_flask_id, new_flask_id);

COMMIT;

-- Rollback instructions:
-- DROP INDEX flasks_ref_unique_index_1;
