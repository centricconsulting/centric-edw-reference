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

CREATE TABLE [Person].[Person] (
    [BusinessEntityID]      INT                                                           NOT NULL,
    [PersonType]            NCHAR (2)                                                     NOT NULL,
    [NameStyle]             VARCHAR(100) NOT NULL,
    [Title]                 NVARCHAR (8)                                                  NULL,
    [FirstName]             VARCHAR(100)                                                  NOT NULL,
    [MiddleName]            VARCHAR(100)                                                  NULL,
    [LastName]              VARCHAR(100)                                                  NOT NULL,
    [Suffix]                NVARCHAR (10)                                                 NULL,
    [EmailPromotion]        INT                                                           NOT NULL,
    [AdditionalContactInfo] VARCHAR(100) NULL,
    [Demographics]          VARCHAR(100)      NULL,
    [rowguid]               VARCHAR(100) NOT NULL,
    [ModifiedDate]          DATETIME NOT NULL,
    CONSTRAINT [PK_Person_BusinessEntityID] PRIMARY KEY CLUSTERED ([BusinessEntityID] ASC));


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Person_rowguid]
    ON [Person].[Person]([rowguid] ASC);

GO
