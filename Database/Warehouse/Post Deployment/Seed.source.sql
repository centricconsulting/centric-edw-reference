/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/*
############################################################
Populate the source map table.
############################################################
*/

SET IDENTITY_INSERT map.source ON;

INSERT INTO map.source (
  source_key
, source_uid
, origin_source_key
, process_batch_key
)
SELECT
  x.source_key
, x.source_uid
, @unknown_key AS origin_source_key
, @unknown_key as process_batch_key

FROM (

SELECT 
  @unknown_key AS source_key
, @warehouse_source_uid as source_uid

UNION ALL
SELECT 100, @governance_source_uid

-- custom data sources follow
UNION ALL
SELECT 101, 'AW'

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM map.source m WHERE m.source_key = x.source_key
)


SET IDENTITY_INSERT map.source OFF;

/*
############################################################
Populate the source table.
############################################################
*/


INSERT INTO dbo.source (
  source_key
, source_name
, source_desc
, source_code
, origin_source_key
, origin_source_revision_actor
, origin_source_revision_dtm
, init_process_batch_key
, process_batch_key
)
SELECT
  m.source_key
, x.source_name
, x.source_desc
, m.source_uid AS source_code
, @unknown_key AS origin_source_key
, NULL AS origin_source_revision_actor
, CURRENT_TIMESTAMP AS origin_source_revision_dtm
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key
FROM (

SELECT 
  @warehouse_source_uid AS source_uid
, 'Warehouse' as source_name
, 'EDW internally generated data.' AS source_desc

UNION ALL 
SELECT
  @governance_source_uid AS source_uid
, 'Governance' as source_name
, 'Manually maintained data.'  AS source_desc

-- custom data sources follow
UNION ALL 
SELECT
  'AW' AS source_uid
, 'Adventure Works' as source_name
, 'Adventure Works operational system.'  AS source_desc

) x
INNER JOIN map.source m ON
  m.origin_source_key = @unknown_key
  AND m.source_uid = x.source_uid

WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.source c WHERE c.source_key = m.source_key
)