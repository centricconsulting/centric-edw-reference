

CREATE VIEW [cube].[ops_operating_group] AS
SELECT
  operating_group_key
, [operating_group_type_key]
, operating_group_desc AS [Operating Group]
, operating_group_code AS [Operating Group Code]
FROM
dbo.operating_group
;