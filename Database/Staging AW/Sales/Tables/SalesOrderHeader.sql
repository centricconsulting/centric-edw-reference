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

CREATE TABLE [Sales].[SalesOrderHeader] (
    [SalesOrderID]           INT   NOT NULL,
    [RevisionNumber]         TINYINT   NOT NULL,
    [OrderDate]              DATETIME   NOT NULL,
    [DueDate]                DATETIME    NOT NULL,
    [ShipDate]               DATETIME              NULL,
    [Status]                 TINYINT   NOT NULL,
    [OnlineOrderFlag]        CHAR(1) NOT NULL,
    [SalesOrderNumber]       VARCHAR(100) NOT NULL,
    [PurchaseOrderNumber]    VARCHAR(100)  NULL,
    [AccountNumber]          VARCHAR(100) NULL,
    [CustomerID]             INT                   NOT NULL,
    [SalesPersonID]          INT                   NULL,
    [TerritoryID]            INT                   NULL,
    [BillToAddressID]        INT                   NOT NULL,
    [ShipToAddressID]        INT                   NOT NULL,
    [ShipMethodID]           INT                   NOT NULL,
    [CreditCardID]           INT                   NULL,
    [CreditCardApprovalCode] VARCHAR (15)          NULL,
    [CurrencyRateID]         INT                   NULL,
    [SubTotal]               MONEY  NOT NULL,
    [TaxAmt]                 MONEY NOT NULL,
    [Freight]                MONEY NOT NULL,
    [TotalDue]               MONEY NOT NULL,
    [Comment]                NVARCHAR (128)        NULL,
    [rowguid]                VARCHAR(100) NOT NULL,
    [ModifiedDate]           DATETIME   NOT NULL,
    process_batch_key INT NOT NULL,
    CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED ([SalesOrderID] ASC)

);

GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_SalesOrderNumber]
    ON [Sales].[SalesOrderHeader]([SalesOrderNumber] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesOrderHeader_rowguid]
    ON [Sales].[SalesOrderHeader]([rowguid] ASC);


GO
