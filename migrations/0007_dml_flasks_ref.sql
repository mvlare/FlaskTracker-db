BEGIN;

INSERT INTO public.flask_ref_type
("name", created_at, updated_at)
VALUES( 'Repaired', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

COMMIT;