/* 
##################################################################################################
###########  INCLUDED ENTITIES:
###############  Source
###############  Currency
###############  State
###############  Country
###############  Legal Entity
###############  Customer
###############  Customer Type
###############  Customer Xref
###############  Legal Entity
###############  Legal Entity Holiday
###############  Legal Entity Fiscal Period
###############  Sales Order
###############  Sales Order Line
###############  Sales Order Line Status
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
###########  ENTITY OBJECT DEFINITIONS FOR [Country]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[country]', N'U') IS NOT NULL
  DROP TABLE ver.[country]
;

CREATE TABLE ver.[country] (

  -- VERSION IDENTITY KEY COLUMN
  country_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , country_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , country_code VARCHAR(20)
 , country_name VARCHAR(200) NOT NULL
 , world_subregion_desc VARCHAR(200)
 , world_region_desc VARCHAR(200)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_country_pk
    PRIMARY KEY NONCLUSTERED (country_version_key)
);
GO

CREATE CLUSTERED INDEX ver_country_cx ON
  ver.[country] (country_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[country]', N'U') IS NOT NULL
DROP TABLE vex.[country]
;

CREATE TABLE [vex].[country] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  country_version_key INT NOT NULL
, next_country_version_key INT NULL
, country_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_country_pk
    PRIMARY KEY (country_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_country_u1 ON
  vex.[country] (country_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[country]', N'V') IS NOT NULL
DROP VIEW dbo.[country]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[country]

DESCRIPTION: Exposes the current view of the version country table,
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

CREATE VIEW dbo.[country] AS
SELECT 

  -- KEY COLUMNS
  vx.country_key

  -- GRAIN COLUMNS
 , v.country_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.country_code
 , v.country_name
 , v.world_subregion_desc
 , v.world_region_desc

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.country_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.country v
INNER JOIN vex.country vx ON
  vx.country_version_key = v.country_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[country_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[country_settle]
;
GO
/* ################################################################################

OBJECT: vex.[country_settle]

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

CREATE PROCEDURE vex.[country_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[country];

INSERT INTO vex.[country] (
  country_version_key
, next_country_version_key
, country_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.country_version_key

, LEAD(v.country_version_key, 1) OVER (
    PARTITION BY v.country_uid
    ORDER BY v.country_version_key ASC) AS next_country_version_key

, MIN(v.country_version_key) OVER (
    PARTITION BY v.country_uid) AS country_key

, ROW_NUMBER() OVER (
    PARTITION BY v.country_uid
    ORDER BY v.country_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.country_version_key) OVER (
      PARTITION BY v.country_uid
      ORDER BY v.country_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.country_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.country_version_key) OVER (
    PARTITION BY v.country_uid
    ORDER BY v.country_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.country_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.country_uid
    ORDER BY v.country_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.country_uid
    ORDER BY v.country_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.country_uid
    ORDER BY v.country_version_key ASC) AS end_source_rev_dtmx

FROM
ver.country v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[country_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[country_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[country_settle_merge]

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

CREATE PROCEDURE vex.[country_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.country vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.country vs
      WHERE vs.country_version_key = vt.country_version_key
    );

  END


  MERGE vex.country WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.country_version_key

    , LEAD(v.country_version_key, 1) OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC) AS next_country_version_key

    , MIN(v.country_version_key) OVER (
        PARTITION BY v.country_uid) AS country_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.country_version_key) OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.country_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.country_version_key) OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.country_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.country_uid
        ORDER BY v.country_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.country v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.country vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.country_uid = v.country_uid

    )

  ) AS vs

  ON vs.country_version_key = vt.country_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_country_version_key, -1) != 
      COALESCE(vt.next_country_version_key, -1) THEN

    UPDATE SET
      next_country_version_key = vs.next_country_version_key
    , country_key = vs.country_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      country_version_key
    , next_country_version_key
    , country_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.country_version_key
    , vs.next_country_version_key
    , vs.country_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Currency]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[currency]', N'U') IS NOT NULL
  DROP TABLE ver.[currency]
;

CREATE TABLE ver.[currency] (

  -- VERSION IDENTITY KEY COLUMN
  currency_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , currency_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , currency_code VARCHAR(20)
 , currency_name VARCHAR(200) NOT NULL
 , currency_symbol NVARCHAR(10)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_currency_pk
    PRIMARY KEY NONCLUSTERED (currency_version_key)
);
GO

CREATE CLUSTERED INDEX ver_currency_cx ON
  ver.[currency] (currency_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[currency]', N'U') IS NOT NULL
DROP TABLE vex.[currency]
;

CREATE TABLE [vex].[currency] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  currency_version_key INT NOT NULL
, next_currency_version_key INT NULL
, currency_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_currency_pk
    PRIMARY KEY (currency_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_currency_u1 ON
  vex.[currency] (currency_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[currency]', N'V') IS NOT NULL
DROP VIEW dbo.[currency]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[currency]

DESCRIPTION: Exposes the current view of the version currency table,
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

CREATE VIEW dbo.[currency] AS
SELECT 

  -- KEY COLUMNS
  vx.currency_key

  -- GRAIN COLUMNS
 , v.currency_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.currency_code
 , v.currency_name
 , v.currency_symbol

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.currency_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.currency v
INNER JOIN vex.currency vx ON
  vx.currency_version_key = v.currency_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[currency_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[currency_settle]
;
GO
/* ################################################################################

OBJECT: vex.[currency_settle]

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

CREATE PROCEDURE vex.[currency_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[currency];

INSERT INTO vex.[currency] (
  currency_version_key
, next_currency_version_key
, currency_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.currency_version_key

, LEAD(v.currency_version_key, 1) OVER (
    PARTITION BY v.currency_uid
    ORDER BY v.currency_version_key ASC) AS next_currency_version_key

, MIN(v.currency_version_key) OVER (
    PARTITION BY v.currency_uid) AS currency_key

, ROW_NUMBER() OVER (
    PARTITION BY v.currency_uid
    ORDER BY v.currency_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.currency_version_key) OVER (
      PARTITION BY v.currency_uid
      ORDER BY v.currency_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.currency_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.currency_version_key) OVER (
    PARTITION BY v.currency_uid
    ORDER BY v.currency_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.currency_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.currency_uid
    ORDER BY v.currency_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.currency_uid
    ORDER BY v.currency_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.currency_uid
    ORDER BY v.currency_version_key ASC) AS end_source_rev_dtmx

FROM
ver.currency v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[currency_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[currency_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[currency_settle_merge]

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

CREATE PROCEDURE vex.[currency_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.currency vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.currency vs
      WHERE vs.currency_version_key = vt.currency_version_key
    );

  END


  MERGE vex.currency WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.currency_version_key

    , LEAD(v.currency_version_key, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS next_currency_version_key

    , MIN(v.currency_version_key) OVER (
        PARTITION BY v.currency_uid) AS currency_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.currency_version_key) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.currency_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.currency_version_key) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.currency_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.currency_uid
        ORDER BY v.currency_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.currency v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.currency vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.currency_uid = v.currency_uid

    )

  ) AS vs

  ON vs.currency_version_key = vt.currency_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_currency_version_key, -1) != 
      COALESCE(vt.next_currency_version_key, -1) THEN

    UPDATE SET
      next_currency_version_key = vs.next_currency_version_key
    , currency_key = vs.currency_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      currency_version_key
    , next_currency_version_key
    , currency_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.currency_version_key
    , vs.next_currency_version_key
    , vs.currency_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Customer]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[customer]', N'U') IS NOT NULL
  DROP TABLE ver.[customer]
;

CREATE TABLE ver.[customer] (

  -- VERSION IDENTITY KEY COLUMN
  customer_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , customer_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , managing_legal_entity_uid VARCHAR(200)
 , customer_type_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS
 , customer_name VARCHAR(200) NOT NULL
 , customer_nbr VARCHAR(100)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_customer_pk
    PRIMARY KEY NONCLUSTERED (customer_version_key)
);
GO

CREATE CLUSTERED INDEX ver_customer_cx ON
  ver.[customer] (customer_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[customer]', N'U') IS NOT NULL
DROP TABLE vex.[customer]
;

CREATE TABLE [vex].[customer] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  customer_version_key INT NOT NULL
, next_customer_version_key INT NULL
, customer_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_customer_pk
    PRIMARY KEY (customer_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_u1 ON
  vex.[customer] (customer_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[customer]', N'V') IS NOT NULL
DROP VIEW dbo.[customer]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[customer]

DESCRIPTION: Exposes the current view of the version customer table,
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

CREATE VIEW dbo.[customer] AS
SELECT 

  -- KEY COLUMNS
  vx.customer_key

  -- GRAIN COLUMNS
 , v.customer_uid

  -- FOREIGN REFERENCE COLUMNS
 , v.managing_legal_entity_uid
 , v.customer_type_uid

  -- ATTRIBUTE COLUMNS
 , v.customer_name
 , v.customer_nbr

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.customer_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.customer v
INNER JOIN vex.customer vx ON
  vx.customer_version_key = v.customer_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_settle]
;
GO
/* ################################################################################

OBJECT: vex.[customer_settle]

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

CREATE PROCEDURE vex.[customer_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[customer];

INSERT INTO vex.[customer] (
  customer_version_key
, next_customer_version_key
, customer_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.customer_version_key

, LEAD(v.customer_version_key, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS next_customer_version_key

, MIN(v.customer_version_key) OVER (
    PARTITION BY v.customer_uid) AS customer_key

, ROW_NUMBER() OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.customer_version_key) OVER (
      PARTITION BY v.customer_uid
      ORDER BY v.customer_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.customer_version_key) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS end_source_rev_dtmx

FROM
ver.customer v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[customer_settle_merge]

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

CREATE PROCEDURE vex.[customer_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.customer vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.customer vs
      WHERE vs.customer_version_key = vt.customer_version_key
    );

  END


  MERGE vex.customer WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.customer_version_key

    , LEAD(v.customer_version_key, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS next_customer_version_key

    , MIN(v.customer_version_key) OVER (
        PARTITION BY v.customer_uid) AS customer_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.customer_version_key) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.customer_version_key) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.customer v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.customer vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.customer_uid = v.customer_uid

    )

  ) AS vs

  ON vs.customer_version_key = vt.customer_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_customer_version_key, -1) != 
      COALESCE(vt.next_customer_version_key, -1) THEN

    UPDATE SET
      next_customer_version_key = vs.next_customer_version_key
    , customer_key = vs.customer_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      customer_version_key
    , next_customer_version_key
    , customer_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.customer_version_key
    , vs.next_customer_version_key
    , vs.customer_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Customer Type]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[customer_type]', N'U') IS NOT NULL
  DROP TABLE ver.[customer_type]
;

CREATE TABLE ver.[customer_type] (

  -- VERSION IDENTITY KEY COLUMN
  customer_type_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , customer_type_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , customer_type_name VARCHAR(200) NOT NULL
 , customer_type_code VARCHAR(20)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_customer_type_pk
    PRIMARY KEY NONCLUSTERED (customer_type_version_key)
);
GO

CREATE CLUSTERED INDEX ver_customer_type_cx ON
  ver.[customer_type] (customer_type_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[customer_type]', N'U') IS NOT NULL
DROP TABLE vex.[customer_type]
;

CREATE TABLE [vex].[customer_type] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  customer_type_version_key INT NOT NULL
, next_customer_type_version_key INT NULL
, customer_type_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_customer_type_pk
    PRIMARY KEY (customer_type_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_type_u1 ON
  vex.[customer_type] (customer_type_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[customer_type]', N'V') IS NOT NULL
DROP VIEW dbo.[customer_type]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[customer_type]

DESCRIPTION: Exposes the current view of the version customer_type table,
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

CREATE VIEW dbo.[customer_type] AS
SELECT 

  -- KEY COLUMNS
  vx.customer_type_key

  -- GRAIN COLUMNS
 , v.customer_type_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.customer_type_name
 , v.customer_type_code

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.customer_type_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.customer_type v
INNER JOIN vex.customer_type vx ON
  vx.customer_type_version_key = v.customer_type_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_type_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_type_settle]
;
GO
/* ################################################################################

OBJECT: vex.[customer_type_settle]

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

CREATE PROCEDURE vex.[customer_type_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[customer_type];

INSERT INTO vex.[customer_type] (
  customer_type_version_key
, next_customer_type_version_key
, customer_type_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.customer_type_version_key

, LEAD(v.customer_type_version_key, 1) OVER (
    PARTITION BY v.customer_type_uid
    ORDER BY v.customer_type_version_key ASC) AS next_customer_type_version_key

, MIN(v.customer_type_version_key) OVER (
    PARTITION BY v.customer_type_uid) AS customer_type_key

, ROW_NUMBER() OVER (
    PARTITION BY v.customer_type_uid
    ORDER BY v.customer_type_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.customer_type_version_key) OVER (
      PARTITION BY v.customer_type_uid
      ORDER BY v.customer_type_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_type_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.customer_type_version_key) OVER (
    PARTITION BY v.customer_type_uid
    ORDER BY v.customer_type_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_type_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.customer_type_uid
    ORDER BY v.customer_type_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.customer_type_uid
    ORDER BY v.customer_type_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.customer_type_uid
    ORDER BY v.customer_type_version_key ASC) AS end_source_rev_dtmx

FROM
ver.customer_type v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_type_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_type_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[customer_type_settle_merge]

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

CREATE PROCEDURE vex.[customer_type_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.customer_type vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.customer_type vs
      WHERE vs.customer_type_version_key = vt.customer_type_version_key
    );

  END


  MERGE vex.customer_type WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.customer_type_version_key

    , LEAD(v.customer_type_version_key, 1) OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC) AS next_customer_type_version_key

    , MIN(v.customer_type_version_key) OVER (
        PARTITION BY v.customer_type_uid) AS customer_type_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.customer_type_version_key) OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_type_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.customer_type_version_key) OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_type_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.customer_type_uid
        ORDER BY v.customer_type_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.customer_type v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.customer_type vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.customer_type_uid = v.customer_type_uid

    )

  ) AS vs

  ON vs.customer_type_version_key = vt.customer_type_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_customer_type_version_key, -1) != 
      COALESCE(vt.next_customer_type_version_key, -1) THEN

    UPDATE SET
      next_customer_type_version_key = vs.next_customer_type_version_key
    , customer_type_key = vs.customer_type_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      customer_type_version_key
    , next_customer_type_version_key
    , customer_type_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.customer_type_version_key
    , vs.next_customer_type_version_key
    , vs.customer_type_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Customer Xref]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[customer_xref]', N'U') IS NOT NULL
  DROP TABLE ver.[customer_xref]
;

CREATE TABLE ver.[customer_xref] (

  -- VERSION IDENTITY KEY COLUMN
  customer_xref_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , customer_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , master_customer_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_customer_xref_pk
    PRIMARY KEY NONCLUSTERED (customer_xref_version_key)
);
GO

CREATE CLUSTERED INDEX ver_customer_xref_cx ON
  ver.[customer_xref] (customer_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[customer_xref]', N'U') IS NOT NULL
DROP TABLE vex.[customer_xref]
;

CREATE TABLE [vex].[customer_xref] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  customer_xref_version_key INT NOT NULL
, next_customer_xref_version_key INT NULL
, customer_xref_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_customer_xref_pk
    PRIMARY KEY (customer_xref_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_xref_u1 ON
  vex.[customer_xref] (customer_xref_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[customer_xref]', N'V') IS NOT NULL
DROP VIEW dbo.[customer_xref]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[customer_xref]

DESCRIPTION: Exposes the current view of the version customer_xref table,
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

CREATE VIEW dbo.[customer_xref] AS
SELECT 

  -- KEY COLUMNS
  vx.customer_xref_key

  -- GRAIN COLUMNS
 , v.customer_uid

  -- FOREIGN REFERENCE COLUMNS
 , v.master_customer_uid

  -- ATTRIBUTE COLUMNS

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.customer_xref_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.customer_xref v
INNER JOIN vex.customer_xref vx ON
  vx.customer_xref_version_key = v.customer_xref_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_xref_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_xref_settle]
;
GO
/* ################################################################################

OBJECT: vex.[customer_xref_settle]

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

CREATE PROCEDURE vex.[customer_xref_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[customer_xref];

INSERT INTO vex.[customer_xref] (
  customer_xref_version_key
, next_customer_xref_version_key
, customer_xref_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.customer_xref_version_key

, LEAD(v.customer_xref_version_key, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_xref_version_key ASC) AS next_customer_xref_version_key

, MIN(v.customer_xref_version_key) OVER (
    PARTITION BY v.customer_uid) AS customer_xref_key

, ROW_NUMBER() OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_xref_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.customer_xref_version_key) OVER (
      PARTITION BY v.customer_uid
      ORDER BY v.customer_xref_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_xref_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.customer_xref_version_key) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_xref_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_xref_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_xref_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_xref_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_xref_version_key ASC) AS end_source_rev_dtmx

FROM
ver.customer_xref v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_xref_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_xref_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[customer_xref_settle_merge]

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

CREATE PROCEDURE vex.[customer_xref_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.customer_xref vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.customer_xref vs
      WHERE vs.customer_xref_version_key = vt.customer_xref_version_key
    );

  END


  MERGE vex.customer_xref WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.customer_xref_version_key

    , LEAD(v.customer_xref_version_key, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC) AS next_customer_xref_version_key

    , MIN(v.customer_xref_version_key) OVER (
        PARTITION BY v.customer_uid) AS customer_xref_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.customer_xref_version_key) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_xref_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.customer_xref_version_key) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_xref_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_xref_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.customer_xref v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.customer_xref vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.customer_uid = v.customer_uid

    )

  ) AS vs

  ON vs.customer_xref_version_key = vt.customer_xref_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_customer_xref_version_key, -1) != 
      COALESCE(vt.next_customer_xref_version_key, -1) THEN

    UPDATE SET
      next_customer_xref_version_key = vs.next_customer_xref_version_key
    , customer_xref_key = vs.customer_xref_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      customer_xref_version_key
    , next_customer_xref_version_key
    , customer_xref_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.customer_xref_version_key
    , vs.next_customer_xref_version_key
    , vs.customer_xref_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Legal Entity]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[customer]', N'U') IS NOT NULL
  DROP TABLE ver.[customer]
;

CREATE TABLE ver.[customer] (

  -- VERSION IDENTITY KEY COLUMN
  customer_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , customer_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , customer_legal_name VARCHAR(200) NOT NULL
 , parent_organization_name VARCHAR(200) NOT NULL
 , customer_nbr VARCHAR(50)
 , risk_score_val DECIMAL(20,12)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_customer_pk
    PRIMARY KEY NONCLUSTERED (customer_version_key)
);
GO

CREATE CLUSTERED INDEX ver_customer_cx ON
  ver.[customer] (customer_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[customer]', N'U') IS NOT NULL
DROP TABLE vex.[customer]
;

CREATE TABLE [vex].[customer] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  customer_version_key INT NOT NULL
, next_customer_version_key INT NULL
, customer_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_customer_pk
    PRIMARY KEY (customer_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_customer_u1 ON
  vex.[customer] (customer_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[customer]', N'V') IS NOT NULL
DROP VIEW dbo.[customer]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[customer]

DESCRIPTION: Exposes the current view of the version customer table,
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

CREATE VIEW dbo.[customer] AS
SELECT 

  -- KEY COLUMNS
  vx.customer_key

  -- GRAIN COLUMNS
 , v.customer_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.customer_legal_name
 , v.parent_organization_name
 , v.customer_nbr
 , v.risk_score_val

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.customer_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.customer v
INNER JOIN vex.customer vx ON
  vx.customer_version_key = v.customer_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_settle]
;
GO
/* ################################################################################

OBJECT: vex.[customer_settle]

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

CREATE PROCEDURE vex.[customer_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[customer];

INSERT INTO vex.[customer] (
  customer_version_key
, next_customer_version_key
, customer_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.customer_version_key

, LEAD(v.customer_version_key, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS next_customer_version_key

, MIN(v.customer_version_key) OVER (
    PARTITION BY v.customer_uid) AS customer_key

, ROW_NUMBER() OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.customer_version_key) OVER (
      PARTITION BY v.customer_uid
      ORDER BY v.customer_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.customer_version_key) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.customer_uid
    ORDER BY v.customer_version_key ASC) AS end_source_rev_dtmx

FROM
ver.customer v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[customer_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[customer_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[customer_settle_merge]

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

CREATE PROCEDURE vex.[customer_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.customer vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.customer vs
      WHERE vs.customer_version_key = vt.customer_version_key
    );

  END


  MERGE vex.customer WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.customer_version_key

    , LEAD(v.customer_version_key, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS next_customer_version_key

    , MIN(v.customer_version_key) OVER (
        PARTITION BY v.customer_uid) AS customer_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.customer_version_key) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.customer_version_key) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.customer_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.customer_uid
        ORDER BY v.customer_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.customer v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.customer vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.customer_uid = v.customer_uid

    )

  ) AS vs

  ON vs.customer_version_key = vt.customer_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_customer_version_key, -1) != 
      COALESCE(vt.next_customer_version_key, -1) THEN

    UPDATE SET
      next_customer_version_key = vs.next_customer_version_key
    , customer_key = vs.customer_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      customer_version_key
    , next_customer_version_key
    , customer_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.customer_version_key
    , vs.next_customer_version_key
    , vs.customer_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Legal Entity]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[legal_entity]', N'U') IS NOT NULL
  DROP TABLE ver.[legal_entity]
;

CREATE TABLE ver.[legal_entity] (

  -- VERSION IDENTITY KEY COLUMN
  legal_entity_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , legal_entity_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , parent_legal_entity_uid VARCHAR(200)
 , incorporation_country_uid VARCHAR(200)
 , gl_currency_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS
 , legal_entity_name VARCHAR(200) NOT NULL
 , legal_entity_code VARCHAR(20)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_legal_entity_pk
    PRIMARY KEY NONCLUSTERED (legal_entity_version_key)
);
GO

CREATE CLUSTERED INDEX ver_legal_entity_cx ON
  ver.[legal_entity] (legal_entity_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[legal_entity]', N'U') IS NOT NULL
DROP TABLE vex.[legal_entity]
;

CREATE TABLE [vex].[legal_entity] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  legal_entity_version_key INT NOT NULL
, next_legal_entity_version_key INT NULL
, legal_entity_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_legal_entity_pk
    PRIMARY KEY (legal_entity_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_legal_entity_u1 ON
  vex.[legal_entity] (legal_entity_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[legal_entity]', N'V') IS NOT NULL
DROP VIEW dbo.[legal_entity]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[legal_entity]

DESCRIPTION: Exposes the current view of the version legal_entity table,
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

CREATE VIEW dbo.[legal_entity] AS
SELECT 

  -- KEY COLUMNS
  vx.legal_entity_key

  -- GRAIN COLUMNS
 , v.legal_entity_uid

  -- FOREIGN REFERENCE COLUMNS
 , v.parent_legal_entity_uid
 , v.incorporation_country_uid
 , v.gl_currency_uid

  -- ATTRIBUTE COLUMNS
 , v.legal_entity_name
 , v.legal_entity_code

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.legal_entity_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.legal_entity v
INNER JOIN vex.legal_entity vx ON
  vx.legal_entity_version_key = v.legal_entity_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[legal_entity_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[legal_entity_settle]
;
GO
/* ################################################################################

OBJECT: vex.[legal_entity_settle]

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

CREATE PROCEDURE vex.[legal_entity_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[legal_entity];

INSERT INTO vex.[legal_entity] (
  legal_entity_version_key
, next_legal_entity_version_key
, legal_entity_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.legal_entity_version_key

, LEAD(v.legal_entity_version_key, 1) OVER (
    PARTITION BY v.legal_entity_uid
    ORDER BY v.legal_entity_version_key ASC) AS next_legal_entity_version_key

, MIN(v.legal_entity_version_key) OVER (
    PARTITION BY v.legal_entity_uid) AS legal_entity_key

, ROW_NUMBER() OVER (
    PARTITION BY v.legal_entity_uid
    ORDER BY v.legal_entity_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.legal_entity_version_key) OVER (
      PARTITION BY v.legal_entity_uid
      ORDER BY v.legal_entity_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.legal_entity_version_key) OVER (
    PARTITION BY v.legal_entity_uid
    ORDER BY v.legal_entity_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.legal_entity_uid
    ORDER BY v.legal_entity_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.legal_entity_uid
    ORDER BY v.legal_entity_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.legal_entity_uid
    ORDER BY v.legal_entity_version_key ASC) AS end_source_rev_dtmx

FROM
ver.legal_entity v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[legal_entity_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[legal_entity_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[legal_entity_settle_merge]

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

CREATE PROCEDURE vex.[legal_entity_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.legal_entity vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.legal_entity vs
      WHERE vs.legal_entity_version_key = vt.legal_entity_version_key
    );

  END


  MERGE vex.legal_entity WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.legal_entity_version_key

    , LEAD(v.legal_entity_version_key, 1) OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC) AS next_legal_entity_version_key

    , MIN(v.legal_entity_version_key) OVER (
        PARTITION BY v.legal_entity_uid) AS legal_entity_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.legal_entity_version_key) OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.legal_entity_version_key) OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.legal_entity_uid
        ORDER BY v.legal_entity_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.legal_entity v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.legal_entity vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.legal_entity_uid = v.legal_entity_uid

    )

  ) AS vs

  ON vs.legal_entity_version_key = vt.legal_entity_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_legal_entity_version_key, -1) != 
      COALESCE(vt.next_legal_entity_version_key, -1) THEN

    UPDATE SET
      next_legal_entity_version_key = vs.next_legal_entity_version_key
    , legal_entity_key = vs.legal_entity_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      legal_entity_version_key
    , next_legal_entity_version_key
    , legal_entity_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.legal_entity_version_key
    , vs.next_legal_entity_version_key
    , vs.legal_entity_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Legal Entity Fiscal Period]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[legal_entity_fiscal_period]', N'U') IS NOT NULL
  DROP TABLE ver.[legal_entity_fiscal_period]
;

CREATE TABLE ver.[legal_entity_fiscal_period] (

  -- VERSION IDENTITY KEY COLUMN
  legal_entity_fiscal_period_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , legal_entity_uid VARCHAR(200) NOT NULL
 , fiscal_year INT NOT NULL
 , fiscal_period_of_year_index INT NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , begin_fiscal_period_date DATE NOT NULL
 , end_fiscal_period_date DATE
 , display_month_of_year INT NOT NULL

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_legal_entity_fiscal_period_pk
    PRIMARY KEY NONCLUSTERED (legal_entity_fiscal_period_version_key)
);
GO

CREATE CLUSTERED INDEX ver_legal_entity_fiscal_period_cx ON
  ver.[legal_entity_fiscal_period] (legal_entity_uid, fiscal_year, fiscal_period_of_year_index);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[legal_entity_fiscal_period]', N'U') IS NOT NULL
DROP TABLE vex.[legal_entity_fiscal_period]
;

CREATE TABLE [vex].[legal_entity_fiscal_period] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  legal_entity_fiscal_period_version_key INT NOT NULL
, next_legal_entity_fiscal_period_version_key INT NULL
, legal_entity_fiscal_period_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_legal_entity_fiscal_period_pk
    PRIMARY KEY (legal_entity_fiscal_period_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_legal_entity_fiscal_period_u1 ON
  vex.[legal_entity_fiscal_period] (legal_entity_fiscal_period_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[legal_entity_fiscal_period]', N'V') IS NOT NULL
DROP VIEW dbo.[legal_entity_fiscal_period]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[legal_entity_fiscal_period]

DESCRIPTION: Exposes the current view of the version legal_entity_fiscal_period table,
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

CREATE VIEW dbo.[legal_entity_fiscal_period] AS
SELECT 

  -- KEY COLUMNS
  vx.legal_entity_fiscal_period_key

  -- GRAIN COLUMNS
 , v.legal_entity_uid
 , v.fiscal_year
 , v.fiscal_period_of_year_index

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.begin_fiscal_period_date
 , v.end_fiscal_period_date
 , v.display_month_of_year

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.legal_entity_fiscal_period_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.legal_entity_fiscal_period v
INNER JOIN vex.legal_entity_fiscal_period vx ON
  vx.legal_entity_fiscal_period_version_key = v.legal_entity_fiscal_period_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[legal_entity_fiscal_period_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[legal_entity_fiscal_period_settle]
;
GO
/* ################################################################################

OBJECT: vex.[legal_entity_fiscal_period_settle]

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

CREATE PROCEDURE vex.[legal_entity_fiscal_period_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[legal_entity_fiscal_period];

INSERT INTO vex.[legal_entity_fiscal_period] (
  legal_entity_fiscal_period_version_key
, next_legal_entity_fiscal_period_version_key
, legal_entity_fiscal_period_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.legal_entity_fiscal_period_version_key

, LEAD(v.legal_entity_fiscal_period_version_key, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
    ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS next_legal_entity_fiscal_period_version_key

, MIN(v.legal_entity_fiscal_period_version_key) OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index) AS legal_entity_fiscal_period_key

, ROW_NUMBER() OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
    ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.legal_entity_fiscal_period_version_key) OVER (
      PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
      ORDER BY v.legal_entity_fiscal_period_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_fiscal_period_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.legal_entity_fiscal_period_version_key) OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
    ORDER BY v.legal_entity_fiscal_period_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_fiscal_period_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
    ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
    ORDER BY v.legal_entity_fiscal_period_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
    ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS end_source_rev_dtmx

FROM
ver.legal_entity_fiscal_period v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[legal_entity_fiscal_period_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[legal_entity_fiscal_period_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[legal_entity_fiscal_period_settle_merge]

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

CREATE PROCEDURE vex.[legal_entity_fiscal_period_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.legal_entity_fiscal_period vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.legal_entity_fiscal_period vs
      WHERE vs.legal_entity_fiscal_period_version_key = vt.legal_entity_fiscal_period_version_key
    );

  END


  MERGE vex.legal_entity_fiscal_period WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.legal_entity_fiscal_period_version_key

    , LEAD(v.legal_entity_fiscal_period_version_key, 1) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS next_legal_entity_fiscal_period_version_key

    , MIN(v.legal_entity_fiscal_period_version_key) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index) AS legal_entity_fiscal_period_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.legal_entity_fiscal_period_version_key) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_fiscal_period_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.legal_entity_fiscal_period_version_key) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.legal_entity_fiscal_period_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.legal_entity_uid, v.fiscal_year, v.fiscal_period_of_year_index
        ORDER BY v.legal_entity_fiscal_period_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.legal_entity_fiscal_period v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.legal_entity_fiscal_period vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.legal_entity_uid = v.legal_entity_uid
      AND vg.fiscal_year = v.fiscal_year
      AND vg.fiscal_period_of_year_index = v.fiscal_period_of_year_index

    )

  ) AS vs

  ON vs.legal_entity_fiscal_period_version_key = vt.legal_entity_fiscal_period_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_legal_entity_fiscal_period_version_key, -1) != 
      COALESCE(vt.next_legal_entity_fiscal_period_version_key, -1) THEN

    UPDATE SET
      next_legal_entity_fiscal_period_version_key = vs.next_legal_entity_fiscal_period_version_key
    , legal_entity_fiscal_period_key = vs.legal_entity_fiscal_period_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      legal_entity_fiscal_period_version_key
    , next_legal_entity_fiscal_period_version_key
    , legal_entity_fiscal_period_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.legal_entity_fiscal_period_version_key
    , vs.next_legal_entity_fiscal_period_version_key
    , vs.legal_entity_fiscal_period_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Legal Entity Holiday]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[legal_entity_holiday]', N'U') IS NOT NULL
  DROP TABLE ver.[legal_entity_holiday]
;

CREATE TABLE ver.[legal_entity_holiday] (

  -- VERSION IDENTITY KEY COLUMN
  legal_entity_holiday_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , legal_entity_uid VARCHAR(200) NOT NULL
 , holiday_date DATE NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , holiday_name VARCHAR(200)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_legal_entity_holiday_pk
    PRIMARY KEY NONCLUSTERED (legal_entity_holiday_version_key)
);
GO

CREATE CLUSTERED INDEX ver_legal_entity_holiday_cx ON
  ver.[legal_entity_holiday] (legal_entity_uid, holiday_date);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[legal_entity_holiday]', N'U') IS NOT NULL
DROP TABLE vex.[legal_entity_holiday]
;

CREATE TABLE [vex].[legal_entity_holiday] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  legal_entity_holiday_version_key INT NOT NULL
, next_legal_entity_holiday_version_key INT NULL
, legal_entity_holiday_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_legal_entity_holiday_pk
    PRIMARY KEY (legal_entity_holiday_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_legal_entity_holiday_u1 ON
  vex.[legal_entity_holiday] (legal_entity_holiday_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[legal_entity_holiday]', N'V') IS NOT NULL
DROP VIEW dbo.[legal_entity_holiday]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[legal_entity_holiday]

DESCRIPTION: Exposes the current view of the version legal_entity_holiday table,
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

CREATE VIEW dbo.[legal_entity_holiday] AS
SELECT 

  -- KEY COLUMNS
  vx.legal_entity_holiday_key

  -- GRAIN COLUMNS
 , v.legal_entity_uid
 , v.holiday_date

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.holiday_name

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.legal_entity_holiday_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.legal_entity_holiday v
INNER JOIN vex.legal_entity_holiday vx ON
  vx.legal_entity_holiday_version_key = v.legal_entity_holiday_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[legal_entity_holiday_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[legal_entity_holiday_settle]
;
GO
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
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[legal_entity_holiday_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[legal_entity_holiday_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[legal_entity_holiday_settle_merge]

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

CREATE PROCEDURE vex.[legal_entity_holiday_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.legal_entity_holiday vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.legal_entity_holiday vs
      WHERE vs.legal_entity_holiday_version_key = vt.legal_entity_holiday_version_key
    );

  END


  MERGE vex.legal_entity_holiday WITH (HOLDLOCK) AS vt

  USING (
  
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
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.legal_entity_holiday vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.legal_entity_uid = v.legal_entity_uid
      AND vg.holiday_date = v.holiday_date

    )

  ) AS vs

  ON vs.legal_entity_holiday_version_key = vt.legal_entity_holiday_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_legal_entity_holiday_version_key, -1) != 
      COALESCE(vt.next_legal_entity_holiday_version_key, -1) THEN

    UPDATE SET
      next_legal_entity_holiday_version_key = vs.next_legal_entity_holiday_version_key
    , legal_entity_holiday_key = vs.legal_entity_holiday_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      legal_entity_holiday_version_key
    , next_legal_entity_holiday_version_key
    , legal_entity_holiday_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.legal_entity_holiday_version_key
    , vs.next_legal_entity_holiday_version_key
    , vs.legal_entity_holiday_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Sales Order]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[sales_order]', N'U') IS NOT NULL
  DROP TABLE ver.[sales_order]
;

CREATE TABLE ver.[sales_order] (

  -- VERSION IDENTITY KEY COLUMN
  sales_order_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , sales_order_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , revenue_legal_entity_uid VARCHAR(200)
 , customer_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS
 , sales_order_date DATE
 , sales_order_nbr VARCHAR(100)
 , tax_amt DECIMAL(20,12)
 , freight_amt DECIMAL(20,12)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_sales_order_pk
    PRIMARY KEY NONCLUSTERED (sales_order_version_key)
);
GO

CREATE CLUSTERED INDEX ver_sales_order_cx ON
  ver.[sales_order] (sales_order_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[sales_order]', N'U') IS NOT NULL
DROP TABLE vex.[sales_order]
;

CREATE TABLE [vex].[sales_order] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  sales_order_version_key INT NOT NULL
, next_sales_order_version_key INT NULL
, sales_order_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_sales_order_pk
    PRIMARY KEY (sales_order_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_sales_order_u1 ON
  vex.[sales_order] (sales_order_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[sales_order]', N'V') IS NOT NULL
DROP VIEW dbo.[sales_order]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[sales_order]

DESCRIPTION: Exposes the current view of the version sales_order table,
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

CREATE VIEW dbo.[sales_order] AS
SELECT 

  -- KEY COLUMNS
  vx.sales_order_key

  -- GRAIN COLUMNS
 , v.sales_order_uid

  -- FOREIGN REFERENCE COLUMNS
 , v.revenue_legal_entity_uid
 , v.customer_uid

  -- ATTRIBUTE COLUMNS
 , v.sales_order_date
 , v.sales_order_nbr
 , v.tax_amt
 , v.freight_amt

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.sales_order_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.sales_order v
INNER JOIN vex.sales_order vx ON
  vx.sales_order_version_key = v.sales_order_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_settle]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_settle]

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

CREATE PROCEDURE vex.[sales_order_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[sales_order];

INSERT INTO vex.[sales_order] (
  sales_order_version_key
, next_sales_order_version_key
, sales_order_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.sales_order_version_key

, LEAD(v.sales_order_version_key, 1) OVER (
    PARTITION BY v.sales_order_uid
    ORDER BY v.sales_order_version_key ASC) AS next_sales_order_version_key

, MIN(v.sales_order_version_key) OVER (
    PARTITION BY v.sales_order_uid) AS sales_order_key

, ROW_NUMBER() OVER (
    PARTITION BY v.sales_order_uid
    ORDER BY v.sales_order_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.sales_order_version_key) OVER (
      PARTITION BY v.sales_order_uid
      ORDER BY v.sales_order_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.sales_order_version_key) OVER (
    PARTITION BY v.sales_order_uid
    ORDER BY v.sales_order_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.sales_order_uid
    ORDER BY v.sales_order_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.sales_order_uid
    ORDER BY v.sales_order_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.sales_order_uid
    ORDER BY v.sales_order_version_key ASC) AS end_source_rev_dtmx

FROM
ver.sales_order v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_settle_merge]

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

CREATE PROCEDURE vex.[sales_order_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.sales_order vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.sales_order vs
      WHERE vs.sales_order_version_key = vt.sales_order_version_key
    );

  END


  MERGE vex.sales_order WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.sales_order_version_key

    , LEAD(v.sales_order_version_key, 1) OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC) AS next_sales_order_version_key

    , MIN(v.sales_order_version_key) OVER (
        PARTITION BY v.sales_order_uid) AS sales_order_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.sales_order_version_key) OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.sales_order_version_key) OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.sales_order_uid
        ORDER BY v.sales_order_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.sales_order v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.sales_order vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.sales_order_uid = v.sales_order_uid

    )

  ) AS vs

  ON vs.sales_order_version_key = vt.sales_order_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_sales_order_version_key, -1) != 
      COALESCE(vt.next_sales_order_version_key, -1) THEN

    UPDATE SET
      next_sales_order_version_key = vs.next_sales_order_version_key
    , sales_order_key = vs.sales_order_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      sales_order_version_key
    , next_sales_order_version_key
    , sales_order_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.sales_order_version_key
    , vs.next_sales_order_version_key
    , vs.sales_order_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Sales Order Line]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[sales_order_line]', N'U') IS NOT NULL
  DROP TABLE ver.[sales_order_line]
;

CREATE TABLE ver.[sales_order_line] (

  -- VERSION IDENTITY KEY COLUMN
  sales_order_line_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , sales_order_lineuid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , sales_order_uid VARCHAR(200)
 , item_uid VARCHAR(200)
 , current_sales_order_line_status_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS
 , sales_order_line_desc VARCHAR(200)
 , sales_order_line_index INT
 , item_unit_qty DECIMAL(20,12)
 , sale_amt DECIMAL(20,12)
 , standard_cost_amt DECIMAL(20,12)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_sales_order_line_pk
    PRIMARY KEY NONCLUSTERED (sales_order_line_version_key)
);
GO

CREATE CLUSTERED INDEX ver_sales_order_line_cx ON
  ver.[sales_order_line] (sales_order_lineuid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[sales_order_line]', N'U') IS NOT NULL
DROP TABLE vex.[sales_order_line]
;

CREATE TABLE [vex].[sales_order_line] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  sales_order_line_version_key INT NOT NULL
, next_sales_order_line_version_key INT NULL
, sales_order_line_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_sales_order_line_pk
    PRIMARY KEY (sales_order_line_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_sales_order_line_u1 ON
  vex.[sales_order_line] (sales_order_line_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[sales_order_line]', N'V') IS NOT NULL
DROP VIEW dbo.[sales_order_line]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[sales_order_line]

DESCRIPTION: Exposes the current view of the version sales_order_line table,
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

CREATE VIEW dbo.[sales_order_line] AS
SELECT 

  -- KEY COLUMNS
  vx.sales_order_line_key

  -- GRAIN COLUMNS
 , v.sales_order_lineuid

  -- FOREIGN REFERENCE COLUMNS
 , v.sales_order_uid
 , v.item_uid
 , v.current_sales_order_line_status_uid

  -- ATTRIBUTE COLUMNS
 , v.sales_order_line_desc
 , v.sales_order_line_index
 , v.item_unit_qty
 , v.sale_amt
 , v.standard_cost_amt

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.sales_order_line_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.sales_order_line v
INNER JOIN vex.sales_order_line vx ON
  vx.sales_order_line_version_key = v.sales_order_line_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_line_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_line_settle]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_line_settle]

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

CREATE PROCEDURE vex.[sales_order_line_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[sales_order_line];

INSERT INTO vex.[sales_order_line] (
  sales_order_line_version_key
, next_sales_order_line_version_key
, sales_order_line_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.sales_order_line_version_key

, LEAD(v.sales_order_line_version_key, 1) OVER (
    PARTITION BY v.sales_order_lineuid
    ORDER BY v.sales_order_line_version_key ASC) AS next_sales_order_line_version_key

, MIN(v.sales_order_line_version_key) OVER (
    PARTITION BY v.sales_order_lineuid) AS sales_order_line_key

, ROW_NUMBER() OVER (
    PARTITION BY v.sales_order_lineuid
    ORDER BY v.sales_order_line_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.sales_order_line_version_key) OVER (
      PARTITION BY v.sales_order_lineuid
      ORDER BY v.sales_order_line_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.sales_order_line_version_key) OVER (
    PARTITION BY v.sales_order_lineuid
    ORDER BY v.sales_order_line_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.sales_order_lineuid
    ORDER BY v.sales_order_line_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.sales_order_lineuid
    ORDER BY v.sales_order_line_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.sales_order_lineuid
    ORDER BY v.sales_order_line_version_key ASC) AS end_source_rev_dtmx

FROM
ver.sales_order_line v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_line_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_line_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_line_settle_merge]

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

CREATE PROCEDURE vex.[sales_order_line_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.sales_order_line vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.sales_order_line vs
      WHERE vs.sales_order_line_version_key = vt.sales_order_line_version_key
    );

  END


  MERGE vex.sales_order_line WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.sales_order_line_version_key

    , LEAD(v.sales_order_line_version_key, 1) OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC) AS next_sales_order_line_version_key

    , MIN(v.sales_order_line_version_key) OVER (
        PARTITION BY v.sales_order_lineuid) AS sales_order_line_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.sales_order_line_version_key) OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.sales_order_line_version_key) OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.sales_order_lineuid
        ORDER BY v.sales_order_line_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.sales_order_line v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.sales_order_line vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.sales_order_lineuid = v.sales_order_lineuid

    )

  ) AS vs

  ON vs.sales_order_line_version_key = vt.sales_order_line_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_sales_order_line_version_key, -1) != 
      COALESCE(vt.next_sales_order_line_version_key, -1) THEN

    UPDATE SET
      next_sales_order_line_version_key = vs.next_sales_order_line_version_key
    , sales_order_line_key = vs.sales_order_line_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      sales_order_line_version_key
    , next_sales_order_line_version_key
    , sales_order_line_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.sales_order_line_version_key
    , vs.next_sales_order_line_version_key
    , vs.sales_order_line_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Sales Order Line Status]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[sales_order_line_status]', N'U') IS NOT NULL
  DROP TABLE ver.[sales_order_line_status]
;

CREATE TABLE ver.[sales_order_line_status] (

  -- VERSION IDENTITY KEY COLUMN
  sales_order_line_status_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , sales_order_line_status_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , sales_order_line_status_desc VARCHAR(200) NOT NULL
 , sales_order_line_status_code VARCHAR(20)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_sales_order_line_status_pk
    PRIMARY KEY NONCLUSTERED (sales_order_line_status_version_key)
);
GO

CREATE CLUSTERED INDEX ver_sales_order_line_status_cx ON
  ver.[sales_order_line_status] (sales_order_line_status_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[sales_order_line_status]', N'U') IS NOT NULL
DROP TABLE vex.[sales_order_line_status]
;

CREATE TABLE [vex].[sales_order_line_status] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  sales_order_line_status_version_key INT NOT NULL
, next_sales_order_line_status_version_key INT NULL
, sales_order_line_status_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_sales_order_line_status_pk
    PRIMARY KEY (sales_order_line_status_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_sales_order_line_status_u1 ON
  vex.[sales_order_line_status] (sales_order_line_status_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[sales_order_line_status]', N'V') IS NOT NULL
DROP VIEW dbo.[sales_order_line_status]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[sales_order_line_status]

DESCRIPTION: Exposes the current view of the version sales_order_line_status table,
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

CREATE VIEW dbo.[sales_order_line_status] AS
SELECT 

  -- KEY COLUMNS
  vx.sales_order_line_status_key

  -- GRAIN COLUMNS
 , v.sales_order_line_status_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.sales_order_line_status_desc
 , v.sales_order_line_status_code

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.sales_order_line_status_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.sales_order_line_status v
INNER JOIN vex.sales_order_line_status vx ON
  vx.sales_order_line_status_version_key = v.sales_order_line_status_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_line_status_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_line_status_settle]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_line_status_settle]

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

CREATE PROCEDURE vex.[sales_order_line_status_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[sales_order_line_status];

INSERT INTO vex.[sales_order_line_status] (
  sales_order_line_status_version_key
, next_sales_order_line_status_version_key
, sales_order_line_status_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.sales_order_line_status_version_key

, LEAD(v.sales_order_line_status_version_key, 1) OVER (
    PARTITION BY v.sales_order_line_status_uid
    ORDER BY v.sales_order_line_status_version_key ASC) AS next_sales_order_line_status_version_key

, MIN(v.sales_order_line_status_version_key) OVER (
    PARTITION BY v.sales_order_line_status_uid) AS sales_order_line_status_key

, ROW_NUMBER() OVER (
    PARTITION BY v.sales_order_line_status_uid
    ORDER BY v.sales_order_line_status_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.sales_order_line_status_version_key) OVER (
      PARTITION BY v.sales_order_line_status_uid
      ORDER BY v.sales_order_line_status_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.sales_order_line_status_version_key) OVER (
    PARTITION BY v.sales_order_line_status_uid
    ORDER BY v.sales_order_line_status_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.sales_order_line_status_uid
    ORDER BY v.sales_order_line_status_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.sales_order_line_status_uid
    ORDER BY v.sales_order_line_status_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.sales_order_line_status_uid
    ORDER BY v.sales_order_line_status_version_key ASC) AS end_source_rev_dtmx

FROM
ver.sales_order_line_status v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[sales_order_line_status_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[sales_order_line_status_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[sales_order_line_status_settle_merge]

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

CREATE PROCEDURE vex.[sales_order_line_status_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.sales_order_line_status vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.sales_order_line_status vs
      WHERE vs.sales_order_line_status_version_key = vt.sales_order_line_status_version_key
    );

  END


  MERGE vex.sales_order_line_status WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.sales_order_line_status_version_key

    , LEAD(v.sales_order_line_status_version_key, 1) OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC) AS next_sales_order_line_status_version_key

    , MIN(v.sales_order_line_status_version_key) OVER (
        PARTITION BY v.sales_order_line_status_uid) AS sales_order_line_status_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.sales_order_line_status_version_key) OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.sales_order_line_status_version_key) OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.sales_order_line_status_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.sales_order_line_status_uid
        ORDER BY v.sales_order_line_status_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.sales_order_line_status v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.sales_order_line_status vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.sales_order_line_status_uid = v.sales_order_line_status_uid

    )

  ) AS vs

  ON vs.sales_order_line_status_version_key = vt.sales_order_line_status_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_sales_order_line_status_version_key, -1) != 
      COALESCE(vt.next_sales_order_line_status_version_key, -1) THEN

    UPDATE SET
      next_sales_order_line_status_version_key = vs.next_sales_order_line_status_version_key
    , sales_order_line_status_key = vs.sales_order_line_status_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      sales_order_line_status_version_key
    , next_sales_order_line_status_version_key
    , sales_order_line_status_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.sales_order_line_status_version_key
    , vs.next_sales_order_line_status_version_key
    , vs.sales_order_line_status_key
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
 , sales_order_line_uid VARCHAR(200) NOT NULL
 , status_date DATE NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , sales_order_line_status_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS
 , status_comment_desc VARCHAR(200)

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
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.sales_order_line_status_history vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.sales_order_line_status_history vs
      WHERE vs.sales_order_line_status_history_version_key = vt.sales_order_line_status_history_version_key
    );

  END


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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [Source]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[source]', N'U') IS NOT NULL
  DROP TABLE ver.[source]
;

CREATE TABLE ver.[source] (

  -- VERSION IDENTITY KEY COLUMN
  source_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , source_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , source_name VARCHAR(200) NOT NULL
 , source_code VARCHAR(20) NOT NULL
 , source_desc VARCHAR(200)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_source_pk
    PRIMARY KEY NONCLUSTERED (source_version_key)
);
GO

CREATE CLUSTERED INDEX ver_source_cx ON
  ver.[source] (source_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[source]', N'U') IS NOT NULL
DROP TABLE vex.[source]
;

CREATE TABLE [vex].[source] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  source_version_key INT NOT NULL
, next_source_version_key INT NULL
, source_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_source_pk
    PRIMARY KEY (source_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_source_u1 ON
  vex.[source] (source_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[source]', N'V') IS NOT NULL
DROP VIEW dbo.[source]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[source]

DESCRIPTION: Exposes the current view of the version source table,
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

CREATE VIEW dbo.[source] AS
SELECT 

  -- KEY COLUMNS
  vx.source_key

  -- GRAIN COLUMNS
 , v.source_uid

  -- FOREIGN REFERENCE COLUMNS

  -- ATTRIBUTE COLUMNS
 , v.source_name
 , v.source_code
 , v.source_desc

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.source_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.source v
INNER JOIN vex.source vx ON
  vx.source_version_key = v.source_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[source_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[source_settle]
;
GO
/* ################################################################################

OBJECT: vex.[source_settle]

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

CREATE PROCEDURE vex.[source_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[source];

INSERT INTO vex.[source] (
  source_version_key
, next_source_version_key
, source_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.source_version_key

, LEAD(v.source_version_key, 1) OVER (
    PARTITION BY v.source_uid
    ORDER BY v.source_version_key ASC) AS next_source_version_key

, MIN(v.source_version_key) OVER (
    PARTITION BY v.source_uid) AS source_key

, ROW_NUMBER() OVER (
    PARTITION BY v.source_uid
    ORDER BY v.source_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.source_version_key) OVER (
      PARTITION BY v.source_uid
      ORDER BY v.source_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.source_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.source_version_key) OVER (
    PARTITION BY v.source_uid
    ORDER BY v.source_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.source_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.source_uid
    ORDER BY v.source_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.source_uid
    ORDER BY v.source_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.source_uid
    ORDER BY v.source_version_key ASC) AS end_source_rev_dtmx

FROM
ver.source v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[source_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[source_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[source_settle_merge]

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

CREATE PROCEDURE vex.[source_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.source vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.source vs
      WHERE vs.source_version_key = vt.source_version_key
    );

  END


  MERGE vex.source WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.source_version_key

    , LEAD(v.source_version_key, 1) OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC) AS next_source_version_key

    , MIN(v.source_version_key) OVER (
        PARTITION BY v.source_uid) AS source_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.source_version_key) OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.source_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.source_version_key) OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.source_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.source_uid
        ORDER BY v.source_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.source v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.source vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.source_uid = v.source_uid

    )

  ) AS vs

  ON vs.source_version_key = vt.source_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_source_version_key, -1) != 
      COALESCE(vt.next_source_version_key, -1) THEN

    UPDATE SET
      next_source_version_key = vs.next_source_version_key
    , source_key = vs.source_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      source_version_key
    , next_source_version_key
    , source_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.source_version_key
    , vs.next_source_version_key
    , vs.source_key
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

  
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [State]
##################################################################################################
*/

IF OBJECT_ID(N'ver.[state]', N'U') IS NOT NULL
  DROP TABLE ver.[state]
;

CREATE TABLE ver.[state] (

  -- VERSION IDENTITY KEY COLUMN
  state_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS
 , state_uid VARCHAR(200) NOT NULL

  -- FOREIGN REFERENCE COLUMNS
 , country_uid VARCHAR(200)

  -- ATTRIBUTE COLUMNS
 , state_code VARCHAR(20)
 , country_code VARCHAR(20)
 , state_name VARCHAR(200) NOT NULL
 , country_desc VARCHAR(200)

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_state_pk
    PRIMARY KEY NONCLUSTERED (state_version_key)
);
GO

CREATE CLUSTERED INDEX ver_state_cx ON
  ver.[state] (state_uid);
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
IF OBJECT_ID(N'vex.[state]', N'U') IS NOT NULL
DROP TABLE vex.[state]
;

CREATE TABLE [vex].[state] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  state_version_key INT NOT NULL
, next_state_version_key INT NULL
, state_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_state_pk
    PRIMARY KEY (state_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_state_u1 ON
  vex.[state] (state_key)
  WHERE version_latest_ind = 1;
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'dbo.[state]', N'V') IS NOT NULL
DROP VIEW dbo.[state]
;
GO
/* ################################################################################

OBJECT: VIEW dbo.[state]

DESCRIPTION: Exposes the current view of the version state table,
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

CREATE VIEW dbo.[state] AS
SELECT 

  -- KEY COLUMNS
  vx.state_key

  -- GRAIN COLUMNS
 , v.state_uid

  -- FOREIGN REFERENCE COLUMNS
 , v.country_uid

  -- ATTRIBUTE COLUMNS
 , v.state_code
 , v.country_code
 , v.state_name
 , v.country_desc

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.state_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.state v
INNER JOIN vex.state vx ON
  vx.state_version_key = v.state_version_key
WHERE
vx.version_latest_ind = 1
GO

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[state_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[state_settle]
;
GO
/* ################################################################################

OBJECT: vex.[state_settle]

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

CREATE PROCEDURE vex.[state_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[state];

INSERT INTO vex.[state] (
  state_version_key
, next_state_version_key
, state_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.state_version_key

, LEAD(v.state_version_key, 1) OVER (
    PARTITION BY v.state_uid
    ORDER BY v.state_version_key ASC) AS next_state_version_key

, MIN(v.state_version_key) OVER (
    PARTITION BY v.state_uid) AS state_key

, ROW_NUMBER() OVER (
    PARTITION BY v.state_uid
    ORDER BY v.state_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.state_version_key) OVER (
      PARTITION BY v.state_uid
      ORDER BY v.state_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.state_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.state_version_key) OVER (
    PARTITION BY v.state_uid
    ORDER BY v.state_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.state_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY v.state_uid
    ORDER BY v.state_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY v.state_uid
    ORDER BY v.state_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY v.state_uid
    ORDER BY v.state_version_key ASC) AS end_source_rev_dtmx

FROM
ver.state v

END;
GO


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

IF OBJECT_ID(N'vex.[state_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[state_settle_merge]
;
GO
/* ################################################################################

OBJECT: vex.[state_settle_merge]

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

CREATE PROCEDURE vex.[state_settle_merge] 
  @begin_version_batch_key INT
, @suspend_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @suspend_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.state vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.state vs
      WHERE vs.state_version_key = vt.state_version_key
    );

  END


  MERGE vex.state WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.state_version_key

    , LEAD(v.state_version_key, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS next_state_version_key

    , MIN(v.state_version_key) OVER (
        PARTITION BY v.state_uid) AS state_key

    , ROW_NUMBER() OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.state_version_key) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.state_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.state_version_key) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.state_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY v.state_uid
        ORDER BY v.state_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.state v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.state vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND
      vg.state_uid = v.state_uid

    )

  ) AS vs

  ON vs.state_version_key = vt.state_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_state_version_key, -1) != 
      COALESCE(vt.next_state_version_key, -1) THEN

    UPDATE SET
      next_state_version_key = vs.next_state_version_key
    , state_key = vs.state_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      state_version_key
    , next_state_version_key
    , state_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.state_version_key
    , vs.next_state_version_key
    , vs.state_key
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

  