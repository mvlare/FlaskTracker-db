-- Migration 0004: Add UNIQUE constraints to flasks.name and boxes.name
-- This ensures that flask names and box names are unique across the database

-- Drop existing non-unique indexes since UNIQUE constraints will create unique indexes
DROP INDEX IF EXISTS "flasks_index_0";
DROP INDEX IF EXISTS "boxes_index_0";

-- Add UNIQUE constraint to flasks.name
-- This will automatically create a unique index
ALTER TABLE "flasks"
ADD CONSTRAINT "flasks_name_unique" UNIQUE ("name");

-- Add UNIQUE constraint to boxes.name
-- This will automatically create a unique index
ALTER TABLE "boxes"
ADD CONSTRAINT "boxes_name_unique" UNIQUE ("name");

-- Update table comments to reflect the uniqueness constraint
COMMENT ON COLUMN "flasks"."name" IS 'Unique flask identifier. Once flask is used in box_content_lines or flasks_ref, the name cannot be updated.';
COMMENT ON COLUMN "boxes"."name" IS 'Unique box identifier. Once box is used in box_content_headers, the name cannot be updated.';
