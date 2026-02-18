-- Migration 0010: Add unique constraint on box_content_lines
-- Enforces that a flask can appear only once per shipment header
-- Applied: YYYY-MM-DD

BEGIN;

-- Add unique index on (box_content_header_id, flask_id) combination
-- Enforces the business rule: a flask cannot appear twice in the same shipment
CREATE UNIQUE INDEX box_content_lines_unique_index_1
    ON box_content_lines (box_content_header_id, flask_id);

COMMIT;

-- Rollback instructions:
-- DROP INDEX box_content_lines_unique_index_1;
