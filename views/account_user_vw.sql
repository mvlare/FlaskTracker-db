create or replace
view account_user_vw 
as
SELECT
  a.id as account_id, 
  a.user_id,
  a.provider_id,
  u.email,
  u.name,
  u.is_admin,
  a.password
FROM
  account a
JOIN "user" u ON
  a.user_id = u.id
WHERE
  1 = 1
  AND a.provider_id = 'credential';