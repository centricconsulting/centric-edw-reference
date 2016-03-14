
CREATE VIEW [cube].[ops_operating_group_type] AS
SELECT [operating_group_type_key]
, [operating_group_type_desc] AS [Operating Group Type]
, [operating_group_type_code] AS [Operating Group Type Code]
FROM
[dbo].[operating_group_type]
;