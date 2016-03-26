/*
##################################################################
Note that the Source table is special in its structure due to the
role that source keys play in the architecture.  Because the
source key is the table grain, the origination of the record
is called origin_source_key.
##################################################################
*/

CREATE TABLE [dbo].[source] (
    [source_key]       INT        NOT NULL,
    [source_name]      VARCHAR (50)  NOT NULL,
    [source_desc]      VARCHAR (100) NULL,
    [source_code]      VARCHAR(20) NOT NULL
    
    -- BOILERPLATE: source columns
    -- Special Case: "origin" prefix is used to differentiate from the table grain (source_key)
  , origin_source_key INT NOT NULL
  , origin_source_revision_actor varchar(50) NULL
  , origin_source_revision_dtm datetime NOT NULL

    -- BOILERPLATE: audit columns
  , init_process_batch_key int NOT NULL
  , process_batch_key int NOT NULL

    CONSTRAINT [dbo_source_pk] PRIMARY KEY CLUSTERED ([source_key] ASC)
);
GO
