CREATE VIEW [cube].[ops_operating_group_manager] AS

SELECT
  r.operating_group_key
, 'CENTRICCONSULTI\' + r.network_login AS manager_domain_login
, 'ON' AS bu_security_value
FROM
dbo.[resource] r
WHERE
CURRENT_TIMESTAMP
  BETWEEN r.effective_begin_dt AND r.effective_end_dt
AND (

  r.bu_lead_flag = 'Y'
  OR r.partner_flag = 'Y'

)
AND EXISTS (

  SELECT 1 FROM
  dbo.operating_group g
  INNER JOIN dbo.operating_group_type t ON t.operating_group_type_key = g.operating_group_type_key
  WHERE
  t.operating_group_type_code = 'BU'
  AND g.operating_group_key = r.operating_group_key

)

UNION ALL

-- added for testing purposes
SELECT
  g.operating_group_key
, NULL
, 'OFF' AS bu_security_value
FROM
dbo.operating_group g
INNER JOIN dbo.operating_group_type t ON t.operating_group_type_key = g.operating_group_type_key
WHERE
t.operating_group_type_code = 'BU'
;

