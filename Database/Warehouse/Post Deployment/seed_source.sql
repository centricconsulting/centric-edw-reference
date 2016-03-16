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

INSERT INTO map.source (
  source_key
, source_uid
, batch_key
)
SELECT x.* FROM (

SELECT 
  @unknown_key AS source_key
, @dw_source_uid as source_uid
, @unknown_key as process_batch_key
UNION ALL SELECT 100, @gov_source_uid, @unknown_key

-- custom data sources follow
UNION ALL SELECT 101, 'AW', @unknown_key

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM map.source m WHERE m.source_key = x.source_key
)

/*
############################################################
Populate the source table.
############################################################
*/


INSERT INTO dbo.source (
  source_key
, source_name
, source_desc
, batch_key
)
SELECT x.* FROM (

SELECT 
  @unknown_key AS source_key
, 'Data Warehouse' as source_name
, 'Data Warehouse internally generated data.' AS source_desc
, @unknown_key as process_batch_key
UNION ALL 

SELECT
  100 AS source_key
, 'Governance' as source_name
, 'Manually maintained data.'  AS source_desc
, @unknown_key AS batch_key

-- custom data sources follow
UNION ALL 

SELECT
  101 AS source_key
, 'Adventure Works' as source_name
, 'Adventure Works operational system.'  AS source_desc
, @unknown_key AS batch_key

) x
WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.source m WHERE m.source_key = x.source_key
)