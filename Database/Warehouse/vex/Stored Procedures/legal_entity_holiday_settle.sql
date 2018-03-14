/* ################################################################################

OBJECT: vex.[legal_entity_holiday_settle]

DESCRIPTION: Truncates corresponding VEX table and reloads it using settle logic.

PARAMETERS: None.

OUTPUT PARAMETERS: None.

RETURN VALUE: None.

RETURN DATASET: None.

HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE vex.[legal_entity_holiday_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[legal_entity_holiday];

INSERT INTO vex.[legal_entity_holiday] (
  legal_entity_holiday_version_key
, next_legal_entity_holiday_version_key
, legal_entity_holiday_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.legal_entity_holiday_version_key

, LEAD(v.legal_entity_holiday_version_key, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date
    ORDER BY v.legal_entity_holiday_version_key ASC) AS next_legal_entity_holiday_version_key

, MIN(v.legal_entity_holiday_version_key) OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date) AS legal_entity_holiday_key

, ROW_NUMBER() OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date
    ORDER BY v.legal_entity_holiday_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.legal_entity_holiday_version_key) OVER (
      PARTITION BY v.legal_entity_uid, v.holiday_date
      ORDER BY v.legal_entity_holiday_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_holiday_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.legal_entity_holiday_version_key) OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date
    ORDER BY v.legal_entity_holiday_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_holiday_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date
    ORDER BY v.legal_entity_holiday_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date
    ORDER BY v.legal_entity_holiday_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.holiday_date
    ORDER BY v.legal_entity_holiday_version_key ASC) AS end_source_rev_dtmx

FROM
ver.legal_entity_holiday v

END;