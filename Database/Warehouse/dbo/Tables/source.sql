/*
##################################################################
Note that the Source table is special in its structure due to the
role that source keys play in the architecture.  Because the
source key is the table grain, the origination of the record
is called origin_source_key.
##################################################################
*/

CREATE TABLE [dbo].[source] (
  [source_key] INT  IDENTITY(1000,1) NOT NULL

  -- GRAIN COLUMN(S)
, [source_uid] VARCHAR(200) NOT NULL

, [source_name] VARCHAR (50)  NOT NULL
, [source_desc] VARCHAR (100) NULL
, [source_code] VARCHAR(20) NOT NULL
    
  -- BOILERPLATE: source columns
, origin_source_uid VARCHAR(200) NOT NULL
, source_revision_dtm DATETIME NOT NULL
, source_revision_actor VARCHAR(200) NULL

  -- BOILERPLATE: batch key columns
, provision_batch_key int NOT NULL
, revision_batch_key int NOT NULL

, CONSTRAINT [dbo_source_pk] PRIMARY KEY CLUSTERED ([source_uid] ASC)
);
GO
