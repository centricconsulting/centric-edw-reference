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

SET IDENTITY_INSERT map.resource_type ON;

INSERT INTO map.resource_type (
  resource_type_key
, source_key
, resource_type_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as resource_type_key
, @dw_source_key AS source_key
, @unk_uid as resource_type_uid
, @process_batch_key as process_batch_key

UNION ALL

SELECT
  @na_key as resource_type_key
, @dw_source_key AS source_key
, @na_uid as resource_type_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.resource_type t WHERE t.resource_type_key = x.resource_type_key
);

SET IDENTITY_INSERT map.resource_type OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

INSERT INTO dbo.resource_type (
  resource_type_key
, resource_type_desc
, resource_type_code
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key AS resource_type_key
, @unk_desc AS resource_type_desc
, @unk_uid AS resource_type_code
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS resource_type_key
, @na_desc AS resource_type_desc
, @na_uid AS resource_type_code
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.resource_type t WHERE t.resource_type_key = x.resource_type_key
);

