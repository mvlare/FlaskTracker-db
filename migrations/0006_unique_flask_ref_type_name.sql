BEGIN;

-- Add unique constraint to flask_ref_type.name
-- This ensures no duplicate reference type names can be created
ALTER TABLE public.flask_ref_type
ADD CONSTRAINT flask_ref_type_name_unique UNIQUE (name);

COMMIT;
