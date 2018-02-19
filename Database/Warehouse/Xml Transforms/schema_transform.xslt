<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:ms="urn:schemas-microsoft-com:xslt"
  xmlns:user="urn:schemas-microsoft-com:xslt"
  exclude-result-prefixes="#default msxsl user ms xsl" >

  <xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no"  />

  <!-- ######## TEMPLATE: ROOT NODE ############## -->
  <xsl:template match="/">
<xsl:text>/* 
##################################################################################################</xsl:text>
###########  INCLUDED ENTITIES:<xsl:for-each select="//model/entity[@name=//model/render/entity or //model/render[@all='true']]">
###############  <xsl:value-of select="./@name" /></xsl:for-each><xsl:text>
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
</xsl:text>

    <xsl:apply-templates select="//model/entity[@name=//model/render/entity or //model/render[@all='true']]">
      <xsl:sort select="@name" data-type="text"/>
    </xsl:apply-templates>

  </xsl:template>

  <!-- ######## TEMPLATE: ENTITY ############## -->
  <xsl:template match="entity">
    <xsl:variable name = "table-name"
      select = "user:BuildPhysicalName(
        @name,
        @physical,
        @class,
        //model/@column-case,
        //model/@column-whitespace-replace)" />

<xsl:text>
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [</xsl:text><xsl:value-of select="@name" /><xsl:text>]
##################################################################################################
*/
</xsl:text>
IF OBJECT_ID(N'ver.[<xsl:value-of select="$table-name" />]', N'U') IS NOT NULL
  DROP TABLE ver.[<xsl:value-of select="$table-name" />]
;

CREATE TABLE ver.[<xsl:value-of select="$table-name" />] (

  -- VERSION IDENTITY KEY COLUMN
  <xsl:value-of select="$table-name" />_version_key INT IDENTITY(1000,1)

  -- GRAIN COLUMNS<xsl:apply-templates
      select="attribute[@grain='true']" />

  -- FOREIGN REFERENCE COLUMNS<xsl:apply-templates
      select="attribute[@class='reference' and not(@grain ='true')]" />

  -- ATTRIBUTE COLUMNS<xsl:apply-templates
      select="attribute[not(@class='reference') and not(@grain ='true')]" />

  -- SOURCE COLUMNS
, source_uid VARCHAR(200) NOT NULL
, source_rev_dtm DATETIME NOT NULL
, source_rev_actor VARCHAR(200) NULL
, source_delete_ind BIT NOT NULL

  -- VERSION COLUMNS
, version_dtm DATETIME2
, version_batch_key INT

, CONSTRAINT ver_<xsl:value-of select="$table-name" />_pk
    PRIMARY KEY NONCLUSTERED (<xsl:value-of select="$table-name" />_version_key)
);
GO

CREATE CLUSTERED INDEX ver_<xsl:value-of select="$table-name" />_cx ON
  ver.[<xsl:value-of select="$table-name" />] (<xsl:call-template name="grain-attribute-list" />);
GO

<xsl:text>/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */</xsl:text>
IF OBJECT_ID(N'vex.[<xsl:value-of select="$table-name" />]', N'U') IS NOT NULL
DROP TABLE vex.[<xsl:value-of select="$table-name" />]
;

CREATE TABLE [vex].[<xsl:value-of select="$table-name" />] (
  
  -- GENERAL NOTES: Many columns are marked as nullable in order to improve load efficiency. 
  --   This is safe, assuming that loading is only handled through dedicated procs.

  -- KEY COLUMNS
  <xsl:value-of select="$table-name" />_version_key INT NOT NULL
, next_<xsl:value-of select="$table-name" />_version_key INT NULL
, <xsl:value-of select="$table-name" />_key INT NULL

  -- VERSION ATTRIBUTES
, version_index INT NULL
, version_current_ind BIT NULL
, version_latest_ind BIT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_<xsl:value-of select="$table-name" />_pk
    PRIMARY KEY (<xsl:value-of select="$table-name" />_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_<xsl:value-of select="$table-name" />_u1 ON
  vex.[<xsl:value-of select="$table-name" />] (<xsl:value-of select="$table-name" />_key)
  WHERE version_latest_ind = 1;
GO

<xsl:text>/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */</xsl:text>

IF OBJECT_ID(N'dbo.[<xsl:value-of select="$table-name" />]', N'V') IS NOT NULL
DROP VIEW dbo.[<xsl:value-of select="$table-name" />]
;
GO
<xsl:text>/* ################################################################################</xsl:text>

OBJECT: VIEW dbo.[<xsl:value-of select="$table-name" />]

DESCRIPTION: Exposes the current view of the version <xsl:value-of select="$table-name" /> table,
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

CREATE VIEW dbo.[<xsl:value-of select="$table-name" />] AS
SELECT 

  -- KEY COLUMNS
  vx.<xsl:value-of select="$table-name" />_key

  -- GRAIN COLUMNS<xsl:apply-templates
      select="attribute[@grain ='true']">
          <xsl:with-param name="column-prefix">v.</xsl:with-param>
    <xsl:with-param name="suppress-data-type">true</xsl:with-param>
  </xsl:apply-templates>

  -- FOREIGN REFERENCE COLUMNS<xsl:apply-templates
      select="attribute[@class='reference' and not(@grain ='true')]">
          <xsl:with-param name="column-prefix">v.</xsl:with-param>
    <xsl:with-param name="suppress-data-type">true</xsl:with-param>
  </xsl:apply-templates>

  -- ATTRIBUTE COLUMNS<xsl:apply-templates
      select="attribute[not(@class='reference') and not(@grain ='true')]">
          <xsl:with-param name="column-prefix">v.</xsl:with-param>
    <xsl:with-param name="suppress-data-type">true</xsl:with-param>
  </xsl:apply-templates>

  -- SOURCE COLUMNS
, v.source_uid
, v.source_rev_dtm
, v.source_rev_actor

  -- VERSION COLUMNS
, v.<xsl:value-of select="$table-name" />_version_key
, vx.version_index
, v.version_dtm
, vx.version_current_ind

  -- BATCH COLUMNS
, v.version_batch_key

FROM
ver.<xsl:value-of select="$table-name" /> v
INNER JOIN vex.<xsl:value-of select="$table-name" /> vx ON
  vx.<xsl:value-of select="$table-name" />_version_key = v.<xsl:value-of select="$table-name" />_version_key
WHERE
vx.version_latest_ind = 1
GO

<xsl:text>/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */</xsl:text>

IF OBJECT_ID(N'vex.[<xsl:value-of select="$table-name" />_settle]', N'P') IS NOT NULL
DROP PROCEDURE vex.[<xsl:value-of select="$table-name" />_settle]
;
GO
<xsl:text>/* ################################################################################</xsl:text>

OBJECT: vex.[<xsl:value-of select="$table-name" />_settle]

DESCRIPTION: Truncates corresponding VEX table and reloads it using settle logic.

PARAMETERS: None.

OUTPUT PARAMETERS: None.

RETURN VALUE: None.

RETURN DATASET: None.

HISTORY:

Date        Name            Version  Description
---------------------------------------------------------------------------------
2017-12-27  Jeff Kanel      1.0      Created by Centric Consulting, LLC

<xsl:text>################################################################################ */</xsl:text>

CREATE PROCEDURE vex.[<xsl:value-of select="$table-name" />_settle] AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE vex.[<xsl:value-of select="$table-name" />];

INSERT INTO vex.[<xsl:value-of select="$table-name" />] (
  <xsl:value-of select="$table-name" />_version_key
, next_<xsl:value-of select="$table-name" />_version_key
, <xsl:value-of select="$table-name" />_key
, version_index
, version_current_ind
, version_latest_ind
, end_version_dtmx
, end_version_batch_key
, end_source_rev_dtmx
)
SELECT

  v.<xsl:value-of select="$table-name" />_version_key

, LEAD(v.<xsl:value-of select="$table-name" />_version_key, 1) OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>
    ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS next_<xsl:value-of select="$table-name" />_version_key

, MIN(v.<xsl:value-of select="$table-name" />_version_key) OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>) AS <xsl:value-of select="$table-name" />_key

, ROW_NUMBER() OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>
    ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS version_index

    -- XOR "^" inverts the deleted indicator
  , CASE
    WHEN LAST_VALUE(v.<xsl:value-of select="$table-name" />_version_key) OVER (
      PARTITION BY <xsl:call-template
        name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
      ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC
      RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.<xsl:value-of select="$table-name" />_version_key THEN v.source_delete_ind ^ 1
    ELSE 0 END AS version_current_ind

, CASE
  WHEN LAST_VALUE(v.<xsl:value-of select="$table-name" />_version_key) OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>
    ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC
    RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.<xsl:value-of select="$table-name" />_version_key THEN 1
  ELSE 0 END AS version_latest_ind

, LEAD(v.version_dtm, 1) OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>
    ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS end_version_dtmx

  -- Back the LEAD batch key off by 1
, LEAD(v.version_batch_key, 1) OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>
    ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) - 1 AS end_version_batch_key

, LEAD(v.source_rev_dtm, 1) OVER (
    PARTITION BY <xsl:call-template
      name="grain-attribute-list">
    <xsl:with-param name="column-prefix">v.</xsl:with-param>
  </xsl:call-template>
    ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS end_source_rev_dtmx

FROM
ver.<xsl:value-of select="$table-name" /> v

END;
GO


<xsl:text>/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */</xsl:text>

IF OBJECT_ID(N'vex.[<xsl:value-of select="$table-name" />_settle_merge]', N'P') IS NOT NULL
DROP PROCEDURE vex.[<xsl:value-of select="$table-name" />_settle_merge]
;
GO
<xsl:text>/* ################################################################################</xsl:text>

OBJECT: vex.[<xsl:value-of select="$table-name" />_settle_merge]

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


<xsl:text>################################################################################ */</xsl:text>

CREATE PROCEDURE vex.[<xsl:value-of select="$table-name" />_settle_merge] 
  @begin_version_batch_key INT
AS
BEGIN

  SET NOCOUNT ON;

  MERGE vex.<xsl:value-of select="$table-name" /> WITH (HOLDLOCK) AS vt

  USING (
  
    SELECT

      v.<xsl:value-of select="$table-name" />_version_key

    , LEAD(v.<xsl:value-of select="$table-name" />_version_key, 1) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS next_<xsl:value-of select="$table-name" />_version_key

    , MIN(v.<xsl:value-of select="$table-name" />_version_key) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>) AS <xsl:value-of select="$table-name" />_key

    , ROW_NUMBER() OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS version_index

      -- XOR "^" inverts the deleted indicator
    , CASE
      WHEN LAST_VALUE(v.<xsl:value-of select="$table-name" />_version_key) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
          <xsl:with-param name="column-prefix">v.</xsl:with-param>
        </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.<xsl:value-of select="$table-name" />_version_key THEN v.source_delete_ind ^ 1
      ELSE 0 END AS version_current_ind

    , CASE
      WHEN LAST_VALUE(v.<xsl:value-of select="$table-name" />_version_key) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC
        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) = v.<xsl:value-of select="$table-name" />_version_key THEN 1
      ELSE 0 END AS version_latest_ind

    , LEAD(v.version_dtm, 1) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS end_version_dtmx

      -- Back the LEAD batch key off by 1
    , LEAD(v.version_batch_key, 1) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) - 1 AS end_version_batch_key

    , LEAD(v.source_rev_dtm, 1) OVER (
        PARTITION BY <xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">v.</xsl:with-param>
      </xsl:call-template>
        ORDER BY v.<xsl:value-of select="$table-name" />_version_key ASC) AS end_source_rev_dtmx

    FROM
    ver.<xsl:value-of select="$table-name" /> v
    WHERE
    EXISTS (

	    SELECT 1 FROM ver.<xsl:value-of select="$table-name" /> vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND<xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">vg.</xsl:with-param>
        <xsl:with-param name="second-column-prefix">v.</xsl:with-param>
        <xsl:with-param name="phrase-delimiter">AND</xsl:with-param>
        <xsl:with-param name="delimit-with-cr">true</xsl:with-param>
      </xsl:call-template>

    )

  ) AS vs

  ON vs.<xsl:value-of select="$table-name" />_version_key = vt.<xsl:value-of select="$table-name" />_version_key 

  WHEN MATCHED
    AND COALESCE(vs.next_<xsl:value-of select="$table-name" />_version_key, -1) != 
      COALESCE(vt.next_<xsl:value-of select="$table-name" />_version_key, -1) THEN

    UPDATE SET
      next_<xsl:value-of select="$table-name" />_version_key = vs.next_<xsl:value-of select="$table-name" />_version_key
    , <xsl:value-of select="$table-name" />_key = vs.<xsl:value-of select="$table-name" />_key
    , version_index = vs.version_index
    , version_current_ind = vs.version_current_ind
    , version_latest_ind = vs.version_latest_ind
    , end_version_dtmx = vs.end_version_dtmx
    , end_version_batch_key = vs.end_version_batch_key
    , end_source_rev_dtmx = vs.end_source_rev_dtmx


  WHEN NOT MATCHED BY SOURCE
    AND EXISTS (

	    SELECT 1 FROM ver.<xsl:value-of select="$table-name" /> vg
	    WHERE vg.version_batch_key >= @begin_version_batch_key AND<xsl:call-template
          name="grain-attribute-list">
        <xsl:with-param name="column-prefix">vg.</xsl:with-param>
        <xsl:with-param name="second-column-prefix">vt.</xsl:with-param>
        <xsl:with-param name="phrase-delimiter">AND</xsl:with-param>
        <xsl:with-param name="delimit-with-cr">true</xsl:with-param>
      </xsl:call-template>

    ) THEN
    
    DELETE

  WHEN NOT MATCHED BY TARGET THEN

    INSERT (
      <xsl:value-of select="$table-name" />_version_key
    , next_<xsl:value-of select="$table-name" />_version_key
    , <xsl:value-of select="$table-name" />_key
    , version_index
    , version_current_ind
    , version_latest_ind
    , end_version_dtmx
    , end_version_batch_key
    , end_source_rev_dtmx
    )  VALUES (
      vs.<xsl:value-of select="$table-name" />_version_key
    , vs.next_<xsl:value-of select="$table-name" />_version_key
    , vs.<xsl:value-of select="$table-name" />_key
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

  </xsl:template>

  <!-- ########################################### -->
  <!-- ######## TEMPLATE: ATTRIBUTE ############## -->
  <!-- ########################################### -->

  <xsl:template match="attribute">
  <xsl:param name="column-prefix" />
  <xsl:param name="suppress-data-type" />
  <xsl:variable name = "column-name" 
    select = "user:BuildPhysicalName(
      @name,
      @physical,
      @class,
      //model/@column-case,
      //model/@column-whitespace-replace)" />
, <xsl:value-of select="$column-prefix" /><xsl:value-of select="$column-name" /><xsl:if test="not($suppress-data-type='true')"><xsl:text> </xsl:text>
  <xsl:value-of select="user:GetPhysicalDataType(
      @class,
      @data-type,
      @data-length,
      @data-precision,
      @required,
      //model/@multibyte)" /></xsl:if></xsl:template>


  <!-- ########################################### -->
  <!-- ######## TEMPLATE: GRAIN ATTRIBUTE LIST ### -->  
  <!-- ########################################### -->

  <xsl:template name="grain-attribute-list">
    <xsl:param name="column-prefix" />
    <xsl:param name="phrase-delimiter" select="','" />
    <xsl:param name="second-column-prefix" />
    <xsl:param name="phrase-comparator" select="'='" />
    <xsl:param name="delimit-with-cr" select="'false'" />
    <xsl:for-each select="./attribute[@grain='true']"><xsl:variable name = "column-name"
        select = "user:BuildPhysicalName(
          @name,
          @physical,
          @class,
          //model/@column-case,
          //model/@column-whitespace-replace)" />
      <xsl:if test="$delimit-with-cr='true'"><xsl:text>
      </xsl:text>
      </xsl:if><xsl:if test="position()>1"><xsl:value-of select="concat($phrase-delimiter,' ')"/></xsl:if>
    <xsl:value-of select="$column-prefix"/><xsl:value-of select="$column-name"/>
      <xsl:if test="$second-column-prefix"><xsl:value-of select="concat(' ',$phrase-comparator,' ',$second-column-prefix, $column-name)" />
    </xsl:if>
  </xsl:for-each></xsl:template>


  <msxsl:script language="C#" implements-prefix="user">
    <![CDATA[

    public string BuildPhysicalName(
      string AttributeName,
      string PhysicalName, 
      string Class,
      string ColumnCase,
      string ColumnWhitespaceReplace)
    { 
      string result = null;

      // determine the source of the physical name
      if(PhysicalName.Trim().Length > 0)
      {
        result = PhysicalName.Trim();

      } else if (AttributeName.Trim().Length > 0)
      {
        result = AttributeName.Trim();
      }

      string PhysicalClass = GetPhysicalClassSuffix(Class);
      
      if(PhysicalClass != null)
      {

        // replace "." with the physical class if applicable
        if(result.Contains(".")) result = result.Replace(".", PhysicalClass);

      }

      // replace key words, usually with shorter version
      result = ReplaceKeyWords(result);

      if(ColumnWhitespaceReplace.Trim().Length > 0)
      {
        // replace spaces with underscores
        result = result.Replace(" ", ColumnWhitespaceReplace.Trim());
      }

      // apply case logic
      switch(ColumnCase.ToLower())
      {
        case "upper" : return result.ToUpper();
        case "lower" : return result.ToLower();
        case "proper" :

          System.Globalization.TextInfo textInfo = new System.Globalization.CultureInfo("en-US", false).TextInfo;
          return textInfo.ToTitleCase(result);
        
        default: return result;
      }
    }


    public string ReplaceKeyWords(string Text)
    {
        System.Collections.Generic.Dictionary<string, string> ReplaceList = 
          new System.Collections.Generic.Dictionary<string, string>();

        //ReplaceList.Add("Customer","Cust");
        //ReplaceList.Add("Organization","Org");

        foreach(System.Collections.Generic.KeyValuePair<string, string> item in ReplaceList)
        {
          if(Text.Contains(item.Key))
          {
            Text = Text.Replace(item.Key, item.Value);
          }
        }

        return Text;
    }

    public string GetPhysicalClassSuffix(string Class)
    {
      switch (Class.ToUpper())
      {

        // entity classes
        case "REFERENCE": return "UID";
        case "DATE": return "Date"; 
        case "TIMESTAMP": return "Timestamp";
        case "TIMESTAMP-EXCLUSIVE": return "TimestampEx";
        case "DESC":
        case "DESCRIPTION": return "Desc";
        case "NAME": return "Name";
        case "AMOUNT": return "Amount";
        case "VALUE": return "Value";
        case "CODE": return "Code";
        case "INDEX": return "Index";
        case "COUNT": return "Count";
        case "IDENTIFIER": return "ID";
        case "INDICATOR": return "Ind";
        case "FLAG": return "Flag";
        case "QUANTITY": return "Qty";
        case "NUMBER": return "Number";

        // table classes
        case "HISTORY": return "History";
        case "XREF": return "Xref";
        default: return null;

      }
    }

    


    public string GetPhysicalDataType(
      string Class,
      string DataType,
      string DataTypeLength,
      string DataTypePrecision,
      string Required,
      string MultiByte)
    {
      
      // Data Type is first derived from data type information
      //   and is otherwise defaulted based on class
      string pdt = null;

      string RequiredSQL = (Required == "true") ? " NOT NULL" : " NULL";

      if(DataType == null || DataType.Trim().Length == 0)
      {
        pdt = GetPhysicalDataTypeFromClass(Class, DataTypeLength, MultiByte);

        if(pdt == null)
        {
          return "{UNKNOWN DATA TYPE} " + RequiredSQL;
        }
        else
        {
          return pdt + " " + RequiredSQL;
        }
        
      }
      else
      {
      
        switch (DataType.ToUpper())
        {

          case "MULTIBYTE-STRING":
          case "MB-STRING" : return "NVARCHAR(" + DataTypeLength + ")" + RequiredSQL;
          case "STRING":
          case "TEXT": 
          
            if(MultiByte == "true")
            {
              return "NVARCHAR(" + DataTypeLength + ")" + RequiredSQL;

            } else {

              return "VARCHAR(" + DataTypeLength + ")" + RequiredSQL;
            }

          case "CHARACTER":
          case "CHAR":
          
            if(MultiByte == "true")
            {
              return "NCHAR(" + DataTypeLength + ")" + RequiredSQL;

            } else {

              return "CHAR(" + DataTypeLength + ")" + RequiredSQL;

            }

          case "DATE": return "DATE" + RequiredSQL;
          case "DATETIME": 
          case "TIMESTAMP": return "DATETIME2" + RequiredSQL;
          case "INTEGER": 
          case "INT":
            return "INTEGER" + RequiredSQL;
          case "MONEY": return "MONEY" + RequiredSQL;
          case "NUMBER":
          case "DECIMAL": return "DECIMAL(" + DataTypeLength + "," + DataTypePrecision + ")" + RequiredSQL;
          case "FLOAT": return "FLOAT";

          default: return "{UNKNOWN DATA TYPE}" + RequiredSQL;

        }
      }
    }

    public string GetPhysicalDataTypeFromClass(string Class, string DataTypeLength, string MultiByte)
    {

      string TextPrefix = null;
      if(MultiByte.Equals("true"))
      {
        TextPrefix = "N";
      }

      switch (Class.ToUpper())
      {

        // entity classes
        case "REFERENCE": return TextPrefix + "VARCHAR(" + IntegerText(DataTypeLength, 200) + ")";
        case "DESC":
        case "DESCRIPTION": return TextPrefix + "VARCHAR(" + IntegerText(DataTypeLength, 200) + ")";
        case "CODE": return TextPrefix + "VARCHAR(" + IntegerText(DataTypeLength, 20) + ")";
        case "FLAG": return TextPrefix + "CHAR(" + IntegerText(DataTypeLength, 20) + ")";
        case "NAME": return TextPrefix + "VARCHAR(" + IntegerText(DataTypeLength, 200) + ")";

        case "NUMBER": return TextPrefix + "VARCHAR(" + IntegerText(DataTypeLength, 100) + ")";

        case "DATE": return "DATE"; 
        case "TIMESTAMP": return "DATETIME2";
        case "TIMESTAMP-EXCLUSIVE": return "DATETIME2";
        
        case "QUANTITY":
        case "VALUE":
        case "AMOUNT": return "DECIMAL(20,8)";

        case "INDEX":
        case "COUNT":
        case "IDENTIFIER": return "INT";

        case "IND":
        case "INDICATOR": return "BIT";

        default: return null;

      }
    }


    public string IntegerText(string ProposedText, int DefaultValue)
    {

      int dtv;
      if(!int.TryParse(ProposedText, out dtv))
      {
        // default the data type length
        dtv = DefaultValue;
      }

      return dtv.ToString();
    }

  ]]>
  </msxsl:script>

</xsl:stylesheet>
