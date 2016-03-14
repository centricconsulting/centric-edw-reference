
CREATE VIEW [cube].[ops_project_business_unit] AS
SELECT
  operating_group_key
, operating_group_desc AS [Business Unit]
FROM
dbo.operating_group o
;	