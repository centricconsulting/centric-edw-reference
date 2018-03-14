CREATE VIEW [Sales].[Orders] AS 

  SELECT
    [OrderID]
  , [CustomerID]
  , [SalespersonPersonID]
  , [PickedByPersonID]
  , [ContactPersonID]
  , [BackorderOrderID]
  , [OrderDate]
  , [ExpectedDeliveryDate]
  , [CustomerPurchaseOrderNumber]
  , [IsUndersupplyBackordered]
  , [Comments]
  , [DeliveryInstructions]
  , [InternalComments]
  , [PickingCompletedWhen]
  , [LastEditedBy]
  , [LastEditedWhen]
  , [process_batch_key]
  FROM
  (
    SELECT
      x.*
    , ROW_NUMBER() OVER (
        PARTITION BY x.OrderID
        ORDER BY x.LastEditedWhen DESC, process_batch_key DESC) AS FilterIndex

    FROM Sales.Orders_LOG x
  ) xx
  WHERE
  xx.FilterIndex = 1
;