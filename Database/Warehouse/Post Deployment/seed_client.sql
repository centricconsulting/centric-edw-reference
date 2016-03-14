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

SET IDENTITY_INSERT map.client ON;

INSERT INTO map.client (
  client_key
, source_key
, client_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as client_key
, @dw_source_key AS source_key
, @unk_uid as client_uid
, @process_batch_key as process_batch_key
UNION ALL
SELECT
  @na_key as client_key
, @dw_source_key AS source_key
, @na_uid as client_uid
, @process_batch_key as process_batch_key
UNION ALL
SELECT
  1 as client_key
, @dw_source_key AS source_key
, 'CENTRIC' as client_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.client t WHERE t.client_key = x.client_key
);

SET IDENTITY_INSERT map.client OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

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
  @unk_key AS client_key
, @unk_desc AS client_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS client_key
, @na_desc AS client_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  1 AS client_key
, 'Centric Consulting' AS client_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key


) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.client t WHERE t.client_key = x.client_key
);


