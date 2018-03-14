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
###########  INCLUDED ENTITIES:<xsl:for-each select="//model/entity[@caption=//model/render/entity or //model/render[@all='true']]">
###############  <xsl:value-of select="./@caption" /></xsl:for-each><xsl:text>
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

    <xsl:apply-templates select="//model/entity[@caption=//model/render/entity or //model/render[@all='true']]">
      <xsl:sort select="@caption" data-type="text"/>
    </xsl:apply-templates>

  </xsl:template>

  <!-- ######## TEMPLATE: ENTITY ############## -->
  <xsl:template match="entity">
    <xsl:variable name = "table-name"
      select = "user:GetColumnName(
        @caption,
        @name,
        @class,
        //model/@column-whitespace-replace,
        //model/@column-case)" />

<xsl:text>
/*
##################################################################################################  
###########  ENTITY OBJECT DEFINITIONS FOR [</xsl:text><xsl:value-of select="@caption" /><xsl:text>]
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
, @supress_cleanup_ind BIT = 0  
AS
BEGIN

  SET NOCOUNT ON;

  -- cleanup orphaned VEX records
  IF @supress_cleanup_ind = 0
  BEGIN

    DELETE vt FROM
    vex.<xsl:value-of select="$table-name" /> vt
    WHERE
    NOT EXISTS (
      SELECT 1 FROM ver.<xsl:value-of select="$table-name" /> vs
      WHERE vs.<xsl:value-of select="$table-name" />_version_key = vt.<xsl:value-of select="$table-name" />_version_key
    );

  END


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
    select = "user:GetColumnName(
      @caption,
      @name,
      @class,
      //model/@column-whitespace-replace,
      //model/@column-case)" />
 , <xsl:value-of select="$column-prefix" /><xsl:value-of select="$column-name" /><xsl:if test="not($suppress-data-type='true')"><xsl:text> </xsl:text>
  <xsl:value-of select="user:GetColumnDataType(
      @class,
      @required,
      (//model/@multibyte='true' or @multibyte='true'),
      @qualified-data-type,
      @data-length,
      @data-precision)" /></xsl:if></xsl:template>

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
        select = "user:GetColumnName(
        @caption,
        @name,
        @class,
        //model/@column-whitespace-replace,
        //model/@column-case)" />          
      <xsl:if test="$delimit-with-cr='true'"><xsl:text>
      </xsl:text>
      </xsl:if><xsl:if test="position()>1"><xsl:value-of select="concat($phrase-delimiter,' ')"/></xsl:if>
    <xsl:value-of select="$column-prefix"/><xsl:value-of select="$column-name"/>
      <xsl:if test="$second-column-prefix"><xsl:value-of select="concat(' ',$phrase-comparator,' ',$second-column-prefix, $column-name)" />
    </xsl:if>
  </xsl:for-each></xsl:template>

  <!-- ########################################### -->
  <!-- ######## C# Code  ########################## -->  
  <!-- ########################################### -->

  <msxsl:script language="C#" implements-prefix="user">
    <msxsl:assembly name="System.Core" />
    <msxsl:using namespace="System.Linq" />
    <msxsl:using namespace="System.Collections.Generic"/>

    <![CDATA[
 
    // returns the attribute name with suffix
    public string GetAttributeName(string AttributeName, string AttributeClassName)
    {
        AttributeClass ac = AttributeClass.GetAttributeClass(AttributeClassName);
        return ac.GetAttributeName(AttributeName);
    }

    // returns the column name for database usage
    public string GetColumnName(string AttributeName, string ColumnAttributeName, string AttributeClassName, string WhitespaceReplaceChar, string ColumnCase)
    {

        string WorkingAttributeName = null;

        if(ColumnAttributeName != null && ColumnAttributeName.Length > 0)
        {
          WorkingAttributeName = ColumnAttributeName;

        } else {

          WorkingAttributeName = AttributeName;
        }

        AttributeClass ac = AttributeClass.GetAttributeClass(AttributeClassName);
        return ac.GetColumnName(WorkingAttributeName, WhitespaceReplaceChar, ColumnCase);
    }

    // returns the phyisical data type with "NOT NULL" as applicable
    public string GetColumnDataType(string AttributeClassName, string RequiredText, bool MultiByte, 
        string QualifiedDataType, string LengthText, string PrecisionText)
    {
        
        bool Required = (RequiredText=="true");           
        int? Length = ResolveIntegerFromText(LengthText);
        int? Precision = ResolveIntegerFromText(PrecisionText);
        
        AttributeClass ac = AttributeClass.GetAttributeClass(AttributeClassName);
        string result = ac.GetDataTypePhrase(Required, MultiByte, QualifiedDataType, Length, Precision);
        return result;
    }

    // returns an integer value from valid text, or null if invalid text
    private int? ResolveIntegerFromText(string IntegerText)
    {
        int dtv;
        if(!int.TryParse(IntegerText, out dtv)) {return null;}        
        return dtv;        
    }        


    public class AttributeClass
    {

      public enum AttributeClassTypes { None, Text, Time, Bit, Integer, Decimal, Numeric };

      public string Name {get; set;}
      public string Suffix {get; set;}
      public string DataType {get; set;}
      public int Length {get; set;}
      public int Precision {get; set;}      
      public AttributeClassTypes AttributeClassType {get; set;} 

      public AttributeClass() {}

      public string GetAttributeName(string AttributeName)
      {
        if(this.Suffix != null)
        {
            return AttributeName.Replace(".", this.Suffix);
        }
        else
        {
            return AttributeName.Replace(".", String.Empty).Trim();
        }
      }

      public string GetColumnName(string AttributeName, string WhitspaceReplaceChar, string ColumnCase)
      {
        string FinalAttributeName = this.GetAttributeName(AttributeName);
        
        // replace whitespace with other characters
        string result = null;
        if(!string.IsNullOrEmpty(WhitspaceReplaceChar))
        {
            result = FinalAttributeName.Replace(" ", WhitspaceReplaceChar);
        }
        else
        {
            result = FinalAttributeName;
        }

        // change case and return
        switch (ColumnCase.ToUpper())
        {
            case "UPPER":
                return result.ToUpper();

            case "LOWER":
                return result.ToLower();

            case "PROPER":
                System.Globalization.TextInfo textInfo = new System.Globalization.CultureInfo("en-US", false).TextInfo;
                return textInfo.ToTitleCase(result);

            default:
                return result;
        }
      }

      public string GetDataTypePhrase(bool Required, bool MultiByte, string QualifiedDataType = null, int? Length = null, int? Precision = null)
      {
        
        if(!string.IsNullOrEmpty(QualifiedDataType))
        {
            return this.AppendRequiredPhrase(QualifiedDataType, Required);
        }

        if(Length == null) {Length = this.Length;}
        if(Precision == null) {Precision = this.Precision;}

        string dtp = null; 

        switch(this.AttributeClassType)
        {
            case AttributeClassTypes.Text:

                dtp = string.Format("{2}{0}({1})", this.DataType, Length.ToString(), MultiByte ? "N" : String.Empty);
                return this.AppendRequiredPhrase(dtp, Required);
            
            case AttributeClassTypes.Numeric:
            case AttributeClassTypes.Bit:
            case AttributeClassTypes.Integer:
            case AttributeClassTypes.Time:

                dtp = this.DataType;
                return this.AppendRequiredPhrase(dtp, Required);           

            case AttributeClassTypes.Decimal:

                dtp = string.Format("{0}({1},{2})", this.DataType, Length.ToString(), Precision.ToString());
                return this.AppendRequiredPhrase(dtp, Required);

            default:
                return "{UNKNOWN DATA TYPE}";
        }
      }

      private string AppendRequiredPhrase(string DataTypePhrase, bool Required)
      {
        string NewPhrase = (Required == true) ? DataTypePhrase + " NOT NULL" : DataTypePhrase;
        return NewPhrase;
      }

      public static AttributeClass GetAttributeClass(string Name)
      {
        switch (Name.ToUpper())
        {
            case "REF":
            case "REFERENCE":
                return new AttributeClass(){Name="Reference", Suffix="UID", DataType="VARCHAR",Length=200, AttributeClassType = AttributeClassTypes.Text};
            case "DESC":
            case "DESCRIPTION":
                return new AttributeClass(){Name="Description", Suffix="Desc", DataType="VARCHAR",Length=200, AttributeClassType = AttributeClassTypes.Text};
            case "CODE":
                return new AttributeClass(){Name="Code", Suffix="Code", DataType="VARCHAR",Length=20, AttributeClassType = AttributeClassTypes.Text};    
            case "NAME":
                return new AttributeClass(){Name="Name", Suffix="Name", DataType="VARCHAR",Length=200, AttributeClassType = AttributeClassTypes.Text};            
            case "FLAG":
                return new AttributeClass(){Name="Flag", Suffix="Flag", DataType="CHAR",Length=1, AttributeClassType = AttributeClassTypes.Text};
            case "NUMBER":
            case "IDENTIFIER":
                return new AttributeClass(){Name="Identifier", Suffix="Nbr", DataType="VARCHAR",Length=100, AttributeClassType = AttributeClassTypes.Text};
            case "GUID":
                return new AttributeClass(){Name="Guid", Suffix="Guid", DataType="VARCHAR",Length=100, AttributeClassType = AttributeClassTypes.Text};                
            case "DATE":
                return new AttributeClass(){Name="Date", Suffix="Date", DataType="DATE", AttributeClassType = AttributeClassTypes.Time};
            case "DATETIME":
            case "TIMTESTAMP":
                return new AttributeClass(){Name="Timestamp", Suffix="Dtm", DataType="DATETIME2", AttributeClassType = AttributeClassTypes.Time};
            case "DATETIME-EXCLUSIVE":
            case "TIMESTAMP-EXCLUSIVE":
                return new AttributeClass(){Name="Timestamp-Exclusive", Suffix="Dtmx", DataType="DATETIME2", AttributeClassType = AttributeClassTypes.Time};
            case "INDEX":
                return new AttributeClass(){Name="Index", Suffix="Index", DataType="INT", AttributeClassType = AttributeClassTypes.Integer};
            case "COUNT":
                return new AttributeClass(){Name="Count", Suffix="Count", DataType="INT", AttributeClassType = AttributeClassTypes.Integer};
            case "IND":
            case "INDICATOR":
                return new AttributeClass(){Name="Indicator", Suffix="Ind", DataType="BIT", AttributeClassType = AttributeClassTypes.Bit};
            case "QTY":
            case "QUANTITY":
                return new AttributeClass(){Name="Quantity", Suffix="Qty", DataType="DECIMAL", Length=20, Precision=12, AttributeClassType = AttributeClassTypes.Decimal};
            case "MONEY":
            case "CURRENCY":
                return new AttributeClass(){Name="Currency", Suffix="Amt", DataType="DECIMAL", Length=20, Precision=12, AttributeClassType = AttributeClassTypes.Decimal};
            case "RATE":
                return new AttributeClass(){Name="Rate", Suffix="Rate", DataType="DECIMAL", Length=20, Precision=12, AttributeClassType = AttributeClassTypes.Decimal};
            case "VAL":
            case "VALUE":
                return new AttributeClass(){Name="Value", Suffix="Val", DataType="DECIMAL", Length=20, Precision=12, AttributeClassType = AttributeClassTypes.Decimal};
            case "VAL-PRECISE":
            case "VALUE-PRECISE":
                return new AttributeClass(){Name="Value-Precise", Suffix="Val", DataType="FLOAT", AttributeClassType = AttributeClassTypes.Numeric};

            // RESERVED FOR ENTITY CLASS NAMES
            
            case "HISTORY":
                return new AttributeClass(){Name="History", Suffix="History"};
            case "XREF":
            case "CROSS-REFERENCE":
                return new AttributeClass(){Name="Cross-Reference", Suffix="Xref"}; 
            case "MASTER":
                return new AttributeClass(){Name="Master", Suffix=null};                  

            default:
               throw new Exception(string.Format("Invalid attribute class requested: \"{0}\".", Name));

        }
      }
    }

  ]]>
  </msxsl:script>

</xsl:stylesheet>
