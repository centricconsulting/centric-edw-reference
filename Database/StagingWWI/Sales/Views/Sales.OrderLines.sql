CREATE VIEW [Sales].[OrderLines] AS 

  SELECT
    [OrderLineID]
  , [OrderID]
  , [StockItemID]
  , [Description]
  , [PackageTypeID]
  , [Quantity]
  , [UnitPrice]
  , [TaxRate]
  , [PickedQuantity]
  , [PickingCompletedWhen]
  , [LastEditedBy]
  , [LastEditedWhen]
  , [process_batch_key]
  FROM
  (
    SELECT
      x.*
    , ROW_NUMBER() OVER (
        PARTITION BY x.OrderLineID 
        ORDER BY x.LastEditedWhen DESC, process_batch_key DESC) AS FilterIndex

    FROM Sales.OrderLines_LOG x
  ) xx
  WHERE
  xx.FilterIndex = 1
;