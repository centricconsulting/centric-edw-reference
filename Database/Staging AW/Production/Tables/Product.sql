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

CREATE TABLE [Production].[Product] (
    [ProductID]             INT   NOT NULL,
    [Name]                  VARCHAR(100)     NOT NULL,
    [ProductNumber]         NVARCHAR (25)    NOT NULL,
    [MakeFlag]              CHAR(1) NOT NULL,
    [FinishedGoodsFlag]     CHAR(1)  NOT NULL,
    [Color]                 NVARCHAR (15)    NULL,
    [SafetyStockLevel]      SMALLINT         NOT NULL,
    [ReorderPoint]          SMALLINT         NOT NULL,
    [StandardCost]          MONEY            NOT NULL,
    [ListPrice]             MONEY            NOT NULL,
    [Size]                  NVARCHAR (5)     NULL,
    [SizeUnitMeasureCode]   NCHAR (3)        NULL,
    [WeightUnitMeasureCode] NCHAR (3)        NULL,
    [Weight]                DECIMAL (8, 2)   NULL,
    [DaysToManufacture]     INT              NOT NULL,
    [ProductLine]           NCHAR (2)        NULL,
    [Class]                 NCHAR (2)        NULL,
    [Style]                 NCHAR (2)        NULL,
    [ProductSubcategoryID]  INT              NULL,
    [ProductModelID]        INT              NULL,
    [SellStartDate]         DATETIME         NOT NULL,
    [SellEndDate]           DATETIME         NULL,
    [DiscontinuedDate]      DATETIME         NULL,
    [rowguid]               VARCHAR(100) NOT NULL,
    [ModifiedDate]          DATETIME NOT NULL,
    process_batch_key INT NOT NULL,
    CONSTRAINT [PK_Product_ProductID] PRIMARY KEY CLUSTERED ([ProductID] ASC),   
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_rowguid]
    ON [Production].[Product]([rowguid] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_Name]
    ON [Production].[Product]([Name] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_ProductNumber]
    ON [Production].[Product]([ProductNumber] ASC);


GO