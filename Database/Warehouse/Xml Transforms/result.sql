/* 
##################################################################################################
###########  INCLUDED ENTITIES:
###############  Sales Order Line Status History
##################################################################################################  

##################################################################################################  
###########  DATABASE PREPARATION
##################################################################################################
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas sc WHERE sc.name = 'dbo')
-- create the CURRENT schema
EXEC sp_executesql N'CREATE SCHEMA [dbo]';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas sc WHERE sc.name = 'ver')
-- create the VERSION schema
EXEC sp_executesql N'CREATE SCHEMA [ver]';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas sc WHERE sc.name = 'vex')
-- create the VERSION SETTLEMENT schema
EXEC sp_executesql N'CREATE SCHEMA [vex]';
GO

/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Sales Order Line Status History]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[sales_order_line_status_history]', N'U') IS NOT NULL
  DROP TABLE ver.[sales_order_line_status_history]
;

CREATE TABLE ver.[sales_order_line_status_history] (

  -- VERSION IDENTITY KEY COLUMN
  sales_order_line_status_history_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
, sales_order_line_uid VARCHAR(200)  NOT NULL
, status_date DATE  NOT NULL

  -- FOREIGN REFERENCE COLUMNS
, sales_order_line_status_uid VARCHAR(200)  NULL

  -- ATTRIBUTE COLUMNS
, status_comment_desc VARCHAR(200)  NULL

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_sales_order_line_status_history_pk
    PRIMARY KEY NONCLUSTERED (sales_order_line_status_history_version_key)
);
GO

CREATE CLUSTERED INDEX ver_sales_order_line_status_history_cx ON
  ver.[sales_order_line_status_history] (sales_order_line_uid, status_date);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[sales_order_line_status_history]', N'U') IS NOT NULL
DROP TABLE vex.[sales_order_line_status_history]
;

CREATE TABLE [vex].[sales_order_line_status_history] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  sales_order_line_status_history_version_key INT NOT NULL
, next_sales_order_line_status_history_version_key INT NULL
, sales_order_line_status_history_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_sales_order_line_status_history_pk
    PRIMARY KEY (sales_order_line_status_history_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_sales_order_line_status_history_u1 ON
  vex.[sales_order_line_status_history] (sales_order_line_status_history_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[sales_order_line_status_history]', N'V') IS NOT NULL
DROP VIEW dbo.[sales_order_line_status_history]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[sales_order_line_status_history]

DESCRIPTION: Exposes the current view of the version sales_order_line_status_history table,
  either latest or current version records.
  
RETURN DATASET:

  - Columns are identical to the corresponding version table.
  - The version key is retained for reference purposes.
  - Assumes that grain column in the version table is unique based on version latest/current
  - The filter "version_latest_ind = 1" is used for domain tables, whereas "version_current_ind = 1" is used for transaction tables.
  - Because this only contains latest records, the end dates have been supressed; they are always null.

NOTES:

  Content views are provided as a way of exposing the current state records
  of Version tables.  This makes it possible to query the dbo schema consistently
  without special logic being applied by the analyst.

HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-28  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################
*/

CREATE VIEW dbo.[sales_order_line_status_history] AS
SELECT 

  -- KEY COLUMNS
  vx.sales_order_line_status_history_key

  -- GRAIN COLUMNS
, v.sales_order_line_uid
, v.status_date

  -- FOREIGN REFERENCE COLUMNS
, v.sales_order_line_status_uid

  -- ATTRIBUTE COLUMNS
, v.status_comment_desc

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.sales_order_line_status_history_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.sales_order_line_status_history v
INNER JOIN vex.sales_order_line_status_history vx ON
  vx.sales_order_line_status_history_version_key = v.sales_order_line_status_history_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_line_status_history_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_line_status_history_settle]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_line_status_history_settle]

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

CREATE PROCEDURE vex.[sales_order_line_status_history_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[sales_order_line_status_history];

INSERT INTO vex.[sales_order_line_status_history] (
  sales_order_line_status_history_version_key
, next_sales_order_line_status_history_version_key
, sales_order_line_status_history_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.sales_order_line_status_history_version_key

, LEAD(v.sales_order_line_status_history_version_key, 1) OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date
    ORDER BY v.sales_order_line_status_history_version_key ASC) AS next_sales_order_line_status_history_version_key

, MIN(v.sales_order_line_status_history_version_key) OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date) AS sales_order_line_status_history_key

, ROW_NUMBER() OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date
    ORDER BY v.sales_order_line_status_history_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.sales_order_line_status_history_version_key) OVER (
      PARTITION BY v.sales_order_line_uid, v.status_date
      ORDER BY v.sales_order_line_status_history_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_history_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.sales_order_line_status_history_version_key) OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date
    ORDER BY v.sales_order_line_status_history_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_history_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date
    ORDER BY v.sales_order_line_status_history_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date
    ORDER BY v.sales_order_line_status_history_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.sales_order_line_uid, v.status_date
    ORDER BY v.sales_order_line_status_history_version_key ASC) AS end_source_rev_dtmx

FROM
ver.sales_order_line_status_history v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_line_status_history_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_line_status_history_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_line_status_history_settle_merge]

DESCRIPTION: Performs a merge of all version records related to grain values that have been affected
  on or after the specified batch key.

PARAMETERS:

  @begin_version_batch_key INT = The minimum batch key used to determine with grain records should
    be considered in the settle.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC


################################################################################ */

CREATE PROCEDURE vex.[sales_order_line_status_history_settle_merge] 
  @begin_version_batch_key INT
AS
BEGIN

  SET NOCOUNT ON;

  MERGE vex.sales_order_line_status_history WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.sales_order_line_status_history_version_key

    , LEAD(v.sales_order_line_status_history_version_key, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS next_sales_order_line_status_history_version_key

    , MIN(v.sales_order_line_status_history_version_key) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date) AS sales_order_line_status_history_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.sales_order_line_status_history_version_key) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_history_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.sales_order_line_status_history_version_key) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_history_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.sales_order_line_uid, v.status_date
        ORDER BY v.sales_order_line_status_history_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.sales_order_line_status_history v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.sales_order_line_status_history vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.sales_order_line_uid = v.sales_order_line_uid
      AND vg.status_date = v.status_date

    )

  ) AS vs

  ON vs.sales_order_line_status_history_version_key = vt.sales_order_line_status_history_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_sales_order_line_status_history_version_key, -1) != 
      COALESCE(vt.next_sales_order_line_status_history_version_key, -1) THEN

    UPDATE SET
      next_sales_order_line_status_history_version_key = vs.next_sales_order_line_status_history_version_key
    , sales_order_line_status_history_key = vs.sales_order_line_status_history_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx


  WHEN NOT MATCHED BY SOURCE
    AND EXISTS (

	    SELECT 1 FROM ver.sales_order_line_status_history vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.sales_order_line_uid = vt.sales_order_line_uid
      AND vg.status_date = vt.status_date

    ) THEN
    
    DELETE

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      sales_order_line_status_history_version_key
    , next_sales_order_line_status_history_version_key
    , sales_order_line_status_history_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.sales_order_line_status_history_version_key
    , vs.next_sales_order_line_status_history_version_key
    , vs.sales_order_line_status_history_key
    , vs.version_index
    , vs.version_current_ind
    , vs.version_latest_ind
    , vs.end_version_dtmx
    , vs.end_version_batch_key
    , vs.end_source_rev_dtmx
    )

  ;


END;
GO

  