DECLARE
  @reference_source_key INT = 0;

SET IDENTITY_INSERT dbo.source ON;

MERGE dbo.source AS target
USING (
    SELECT
      'REF' AS source_uid
    , @reference_source_key AS source_key
    , 'Reference' AS source_name
    , 'Goverened reference values.' AS source_desc
    , 'REF' AS source_code
    , 'REF' AS origin_source_uid
    , CURRENT_TIMESTAMP AS source_revision_dtm
    , 'SYSTEM' AS source_revision_actor

) AS source

ON target.source_uid = source.source_uid

WHEN NOT MATCHED BY target THEN

INSERT (
  source_key
, source_uid
, source_name
, source_desc
, source_code
, origin_source_uid
, source_revision_dtm
, source_revision_actor
, provision_batch_key
, revision_batch_key
)
VALUES (
  source.source_key
, source.source_uid
, source_name
, source_desc
, source_code
, origin_source_uid
, source_revision_dtm
, source_revision_actor
, 0 -- provision_batch_key
, 0 -- revision_batch_key
)
;

SET IDENTITY_INSERT dbo.source OFF;
