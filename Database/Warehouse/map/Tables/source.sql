/*
##################################################################
Note that map tables are seeded with an IDENTITY of 1000.  The 
intent is to reserve a block of key values that can be used
for Governance or other manually specified values.  Every map
table must have a primary key on the named key column and a 
grain (unique) index on the combined UID and source_key columns.

The map.source able tis unique in that the grain is only
comprised of the UID column.  The source key (named entity)
is used as the primary key.
##################################################################
*/

CREATE TABLE [map].[source] (
    [source_key]       INT  NOT NULL IDENTITY(1000,1),
    [origin_source_key] INT NOT NULL,
    [source_uid]       VARCHAR (200) NOT NULL,
    [process_batch_key] INT        NOT NULL,
    CONSTRAINT [map_source_pk] PRIMARY KEY CLUSTERED ([source_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [map_source_gx]
    ON [map].[source]([source_uid] ASC, origin_source_key);

