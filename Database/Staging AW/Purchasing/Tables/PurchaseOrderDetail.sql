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

CREATE TABLE [Purchasing].[PurchaseOrderDetail] (
    [PurchaseOrderID]       INT            NOT NULL,
    [PurchaseOrderDetailID] INT  NOT NULL,
    [DueDate]               DATETIME       NOT NULL,
    [OrderQty]              SMALLINT       NOT NULL,
    [ProductID]             INT            NOT NULL,
    [UnitPrice]             MONEY          NOT NULL,
    [LineTotal]             MONEY NOT NULL,
    [ReceivedQty]           DECIMAL (8, 2) NOT NULL,
    [RejectedQty]           DECIMAL (8, 2) NOT NULL,
    [StockedQty]            DECIMAL(8,2) NOT NULL,
    [ModifiedDate]          DATETIME  NOT NULL,
    process_batch_key INT NOT NULL,
    CONSTRAINT [PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID] PRIMARY KEY CLUSTERED ([PurchaseOrderID] ASC, [PurchaseOrderDetailID] ASC)
);

