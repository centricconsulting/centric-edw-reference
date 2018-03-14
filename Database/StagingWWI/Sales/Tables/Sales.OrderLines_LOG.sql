CREATE TABLE [Sales].[OrderLines_LOG] (
    [OrderLineID]          INT             NOT NULL,
    [OrderID]              INT             NOT NULL,
    [StockItemID]          INT             NOT NULL,
    [Description]          NVARCHAR (100)  NOT NULL,
    [PackageTypeID]        INT             NOT NULL,
    [Quantity]             INT             NOT NULL,
    [UnitPrice]            DECIMAL (18, 2) NULL,
    [TaxRate]              DECIMAL (18, 3) NOT NULL,
    [PickedQuantity]       INT             NOT NULL,
    [PickingCompletedWhen] DATETIME2 (7)   NULL,
    [LastEditedBy]         INT             NOT NULL,
    [LastEditedWhen]       DATETIME2 (7)   NOT NULL,
    process_batch_key INT
);


GO
CREATE NONCLUSTERED INDEX [Sales_OrderLines_LOG_CL]
    ON [Sales].[OrderLines_LOG]([OrderLineID] ASC);

