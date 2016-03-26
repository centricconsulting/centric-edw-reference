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

CREATE TABLE [Person].[Address] (
    [AddressID]       INT NOT NULL,
    [AddressLine1]    NVARCHAR (60)     NOT NULL,
    [AddressLine2]    NVARCHAR (60)     NULL,
    [City]            NVARCHAR (30)     NOT NULL,
    [StateProvinceID] INT               NOT NULL,
    [PostalCode]      NVARCHAR (15)     NOT NULL,

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Note: the more complex sys.geography object type was
    retained because it is standard in SQL Server.
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */

    [SpatialLocation] [sys].[geography] NULL,
    [rowguid]         VARCHAR(100) NOT NULL,
    [ModifiedDate]    DATETIME NOT NULL,
    process_batch_key INT NOT NULL,
    CONSTRAINT [PK_Address_AddressID] PRIMARY KEY CLUSTERED ([AddressID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode]
    ON [Person].[Address]([AddressLine1] ASC, [AddressLine2] ASC, [City] ASC, [StateProvinceID] ASC, [PostalCode] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Address_rowguid]
    ON [Person].[Address]([rowguid] ASC);


GO