
CREATE VIEW [cube].[ops_resource_business_unit] AS
SELECT
  og.operating_group_key
, og.operating_group_desc AS [Business Unit]
, CASE ogt.operating_group_type_code WHEN 'BU' THEN 'Standard' ELSE 'Non-Standard' END AS [Business Unit Type]
FROM
dbo.operating_group og
	INNER JOIN dbo.operating_group_type ogt
		ON og.operating_group_type_key = ogt.operating_group_type_key
WHERE ogt.operating_group_type_code = 'BU'
	  OR og.operating_group_code = 'NAT'
;