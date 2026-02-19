-- Migration 0011: Add unique constraint on (new_flask_id, flask_ref_type_id) in flasks_ref
-- Ensures a flask can only appear once per reference type as the replacement/refill target
-- Applied: 2026-02-19

BEGIN;

-- Add unique index on (new_flask_id, flask_ref_type_id) combination
-- A new flask can only be the target of a given reference type once
CREATE UNIQUE INDEX flasks_ref_unique_index_2
    ON flasks_ref (new_flask_id, flask_ref_type_id);

COMMIT;

-- Rollback instructions:
-- DROP INDEX flasks_ref_unique_index_2;
