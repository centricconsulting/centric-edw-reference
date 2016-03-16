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
#######################################################################
Insert Map Records
#######################################################################
*/
/*

SET IDENTITY_INSERT map.client ON;

INSERT INTO map.client (
  client_key
, source_key
, client_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unknown_key as client_key
, @dw_source_key AS source_key
, @unknown_uid as client_uid
, @unknown_key as process_batch_key
UNION ALL
SELECT
  @not_applicable_key as client_key
, @dw_source_key AS source_key
, @not_applicable_uid as client_uid
, @unknown_key as process_batch_key
UNION ALL
SELECT
  1 as client_key
, @dw_source_key AS source_key
, 'CENTRIC' as client_uid
, @unknown_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.client t WHERE t.client_key = x.client_key
);

SET IDENTITY_INSERT map.client OFF;
*/

/*
#######################################################################
Insert Content Records
#######################################################################
*/
/*
INSERT INTO dbo.client (
  client_key
, client_desc
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unknown_key AS client_key
, @unknown_desc AS client_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

UNION ALL

SELECT
  @not_applicable_key AS client_key
, @not_applicable_desc AS client_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key

UNION ALL

SELECT
  1 AS client_key
, 'Centric Consulting' AS client_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @unknown_key AS init_process_batch_key
, @unknown_key AS process_batch_key


) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.client t WHERE t.client_key = x.client_key
);


*/