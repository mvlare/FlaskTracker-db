-- Migration 0002: Initial fixes
-- Applies schema corrections identified in FlaskTracker_latest.dbml
--   1. flasks_ref.flask_ref_type_id      : enforce NOT NULL
--   2. flask_ref_type.name               : enforce NOT NULL
--   3. flasks.Low_pressure_at            : rename to low_pressure_at

-- 1. Every flasks_ref row must declare its relationship type
ALTER TABLE flasks_ref
    ALTER COLUMN flask_ref_type_id SET NOT NULL;

-- 2. A reference type with no name is unusable as a classifier
ALTER TABLE flask_ref_type
    ALTER COLUMN name SET NOT NULL;

-- 3. Normalise to snake_case (all other columns already use it)
ALTER TABLE flasks
    RENAME COLUMN "Low_pressure_at" TO low_pressure_at;


