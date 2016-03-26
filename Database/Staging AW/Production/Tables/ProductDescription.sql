/*
#############################################################################################################
Note that staging tables adhere to the following rules:

- ADD process_batch_key INT NOT NULL for audit purposes.
- KEEP all PK and unique indexes.
- KEEP all NOT NULL check constraints.
- CHANGE calculated columns with their resulting data type.
- CHANGE complex data types/objects to simple/standard data types. Add columns if needed (e.g. in case of XML)
- REMOVE IDENTITY column attributes.
- REMOVE column defaults.
- REMOVE all other check (besides NOT NULL) and foreign key constraints.
- REMOVE non-unique indexes (may be added later if needed for ETL performance)
- REMOVE objects other than tables and indexes (e.g. triggers, extended properties)
#############################################################################################################
*/

CREATE TABLE [Production].[ProductDescription] (
    [ProductDescriptionID] INT NOT NULL,
    [Description]          NVARCHAR (400)   NOT NULL,
    [rowguid]              VARCHAR(100) NOT NULL,
    [ModifiedDate]         DATETIME NOT NULL,
    process_batch_key INT NOT NULL,
    CONSTRAINT [PK_ProductDescription_ProductDescriptionID] PRIMARY KEY CLUSTERED ([ProductDescriptionID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProductDescription_rowguid]
    ON [Production].[ProductDescription]([rowguid] ASC);


GO