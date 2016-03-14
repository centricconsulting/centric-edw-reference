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


SET IDENTITY_INSERT map.project_type ON;

INSERT INTO map.project_type (
  project_type_key
, source_key
, project_type_uid
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key as project_type_key
, @dw_source_key AS source_key
, @unk_uid as project_type_uid
, @process_batch_key as process_batch_key
UNION ALL
SELECT
  @na_key as project_type_key
, @dw_source_key AS source_key
, @na_uid as project_type_uid
, @process_batch_key as process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.project_type t WHERE t.project_type_key = x.project_type_key
);

SET IDENTITY_INSERT map.project_type OFF;

/*
#######################################################################
Insert Content Records
#######################################################################
*/

INSERT INTO dbo.project_type (
  project_type_key
, project_type_desc
, project_type_code
, work_type 
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT x.* FROM (

SELECT
  @unk_key AS project_type_key
, @unk_desc AS project_type_desc
, @unk_uid AS project_type_code
, @unk_desc AS work_type 
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

UNION ALL

SELECT
  @na_key AS project_type_key
, @na_desc AS project_type_desc
, @na_uid AS project_type_code
, @na_desc AS work_type 
, @dw_source_key AS source_key
, CURRENT_TIMESTAMP AS source_revision_dtm
, NULL AS source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.project_type t WHERE t.project_type_key = x.project_type_key
);




/*
#######################################################################
Insert Map Records - Business Content
#######################################################################
*/


INSERT INTO map.project_type (
  source_key
, project_type_uid
, process_batch_key
)
SELECT 
  @gov_source_key AS source_key
, x.project_type_uid
, @process_batch_key AS process_batch_key
FROM (

SELECT
  'CLIENT' as project_type_uid
UNION ALL
SELECT
  'ADMIN' as project_type_uid
UNION ALL
SELECT
  'BD' as project_type_uid
UNION ALL
SELECT
  'PTO' as project_type_uid
UNION ALL
SELECT
  'LEAVE' as project_type_uid
UNION ALL
SELECT
  'TRAINING' as project_type_uid
UNION ALL
SELECT
  'MEETING' as project_type_uid
UNION ALL
SELECT
  'JURYDUTY' as project_type_uid
UNION ALL
SELECT
  'COACH' as project_type_uid
UNION ALL
SELECT
  'OTHER' as project_type_uid

) x
WHERE
NOT EXISTS (
  SELECT 1 FROM map.project_type t WHERE
	t.project_type_uid = x.project_type_uid
	AND t.source_key = @gov_source_key
);


/*
#######################################################################
Insert Content Records - Business Content
#######################################################################
*/

INSERT INTO dbo.project_type (
  project_type_key
, project_type_desc
, project_type_code
, work_type
, internal_flag
, source_key
, source_revision_dtm
, source_revision_actor
, init_process_batch_key
, process_batch_key
)
SELECT
  m.project_type_key
, x.project_type_desc
, x.project_type_code
, x.work_type
, x.internal_flag
, @gov_source_key
, CURRENT_TIMESTAMP source_revision_dtm
, 'SYSTEM' source_revision_actor
, @process_batch_key AS init_process_batch_key
, @process_batch_key AS process_batch_key
FROM (

SELECT
  'CLIENT' as project_type_uid
, 'Client' AS project_type_desc
, 'CLT' AS project_type_code
, 'Work' AS work_type
, 'N' AS internal_flag
UNION ALL
SELECT
  'ADMIN' as project_type_uid
, 'Administration' AS project_type_desc
, 'ADM' AS project_type_code
, 'Work' AS work_type
, 'Y' AS internal_flag
UNION ALL
SELECT
  'BD' as project_type_uid
, 'Business Dev.' AS project_type_desc
, 'BD' AS project_type_code
, 'Work' AS work_type
, 'Y' AS internal_flag
UNION ALL
SELECT
  'PTO' as project_type_uid
, 'PTO' AS project_type_desc
, 'PTO' AS project_type_code
, 'Non-Work' AS work_type
, 'Y' AS internal_flag
UNION ALL
SELECT
  'LEAVE' as project_type_uid
, 'Leave' AS project_type_desc
, 'LEAVE' AS project_type_code
, 'Non-Work' AS work_type
, 'Y' AS internal_flag
UNION ALL
SELECT
  'TRAINING' as project_type_uid
, 'Training' AS project_type_desc
, 'TRN' AS project_type_code
, 'Work' AS work_type
, 'Y' AS internal_flag

UNION ALL
SELECT
  'MEETING' as project_type_uid
, 'Meeting' AS project_type_desc
, 'MTG' AS project_type_code
, 'Work' AS work_type
, 'Y' AS internal_flag

UNION ALL
SELECT
  'JURYDUTY' as project_type_uid
, 'Jury Duty' AS project_type_desc
, 'JD' AS project_type_code
, 'Non-Work' AS work_type
, 'Y' AS internal_flag

UNION ALL
SELECT
  'COACH' as project_type_uid
, 'Coaching' AS project_type_desc
, 'COACH' AS project_type_code
, 'Work' AS work_type
, 'Y' AS internal_flag

UNION ALL
SELECT
  'OTHER' as project_type_uid
, 'Other' AS project_type_desc
, 'OTH' AS project_type_code
, 'Work' AS work_type
, 'Y' AS internal_flag

) x

LEFT JOIN map.project_type m ON
  m.source_key = @gov_source_key
  AND m.project_type_uid = x.project_type_uid

WHERE
NOT EXISTS (
  SELECT 1 FROM dbo.project_type t WHERE
    t.project_type_key = m.project_type_key
);
