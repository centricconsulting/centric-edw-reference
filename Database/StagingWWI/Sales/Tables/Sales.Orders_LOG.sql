CREATE TABLE [Sales].[Orders_LOG] (
    [OrderID]                     INT            NOT NULL,
    [CustomerID]                  INT            NOT NULL,
    [SalespersonPersonID]         INT            NOT NULL,
    [PickedByPersonID]            INT            NULL,
    [ContactPersonID]             INT            NOT NULL,
    [BackorderOrderID]            INT            NULL,
    [OrderDate]                   DATE           NOT NULL,
    [ExpectedDeliveryDate]        DATE           NOT NULL,
    [CustomerPurchaseOrderNumber] NVARCHAR (20)  NULL,
    [IsUndersupplyBackordered]    BIT            NOT NULL,
    [Comments]                    NVARCHAR (MAX) NULL,
    [DeliveryInstructions]        NVARCHAR (MAX) NULL,
    [InternalComments]            NVARCHAR (MAX) NULL,
    [PickingCompletedWhen]        DATETIME2 (7)  NULL,
    [LastEditedBy]                INT            NOT NULL,
    [LastEditedWhen]              DATETIME2 (7)  NOT NULL,
    process_batch_key INT
);


GO
CREATE NONCLUSTERED INDEX [Sales_Orders_LOG_CL]
    ON [Sales].[Orders_LOG]([OrderID] ASC);

