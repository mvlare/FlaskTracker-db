-- 13-02-2026: 
-- For a given flask_id, get total tree of broken flasks and repairs,
-- including the starting original.
-- select * from get_flask_ref_tree(8);
CREATE OR REPLACE
FUNCTION get_flask_ref_tree(p_flask_id int) 
RETURNS TABLE
(
  flask_id int,
  flask_name text,
  flask_broken_at timestamptz,
  flask_ref_type_name text
)
AS $$
BEGIN
  RETURN QUERY
  WITH flask_ref_cte AS (
SELECT
      fla_o.id AS ori_flask_id,
      fla_o.broken_at AS ori_flask_broken_at,
      fla_n.id AS flask_id,
      fla_n.name AS flask_name,
      fla_n.broken_at AS flask_broken_at,
      flt.name AS flask_ref_type_name
FROM
  flasks fla_o
JOIN flasks_ref flr ON
  fla_o.id = flr.original_flask_id
JOIN flasks fla_n ON
  flr.new_flask_id = fla_n.id
JOIN flask_ref_type flt ON
  flr.flask_ref_type_id = flt.id
WHERE
  flr.original_flask_id = p_flask_id
  OR EXISTS (
  select 
         1
  from
    flasks_ref flr1
  where
    flr1.new_flask_id = p_flask_id
    And flr1.original_flask_id = flr.original_flask_id
           )
  )
  SELECT
    frc.flask_id AS flask_id,
    frc.flask_name AS flask_name, 
    frc.flask_broken_at AS flask_broken_at,
    frc.flask_ref_type_name AS flask_ref_type_name
FROM
  flask_ref_cte frc
UNION ALL

  SELECT
    fla_o.id AS flask_id,
    fla_o.name AS flask_name,
    fla_o.broken_at AS flask_broken_at,
    'original' AS flask_ref_type_name
FROM
  (
  SELECT
    DISTINCT ori_flask_id
  FROM
    flask_ref_cte
  ) frc
JOIN flasks fla_o ON
  fla_o.id = frc.ori_flask_id
ORDER BY
  flask_id ASC;
END;

$$ LANGUAGE plpgsql;

