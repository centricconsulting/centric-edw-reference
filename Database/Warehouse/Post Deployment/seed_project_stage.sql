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

SET IDENTITY_INSERT map.project_stage ON;

INSERT INTO map.project_stage (
  project_stage_key
, source_key
, project_stage_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as project_stage_key
, @dw_source_key AS source_key
, @unk_uid as project_stage_uid
, @process_batch_key as process_batch_key

UNION ALL

SELECT
  @na_key as project_stage_key
, @dw_source_key AS source_key
, @na_uid as project_stage_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.project_stage t WHERE t.project_stage_key = x.project_stage_key
);

SET IDENTITY_INSERT map.project_stage OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

INSERT INTO dbo.project_stage (
  project_stage_key
, project_stage_desc
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key AS project_stage_key
, @unk_desc AS project_stage_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS project_stage_key
, @na_desc AS project_stage_desc
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.project_stage t WHERE t.project_stage_key = x.project_stage_key
);

