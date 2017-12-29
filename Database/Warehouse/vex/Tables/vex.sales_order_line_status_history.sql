CREATE TABLE [vex].[sales_order_line_status_history] (

  -- KEY COLUMNS
  sales_order_line_status_history_version_key INT NOT NULL
, sales_order_line_status_history_key INT NOT NULL

  -- GRAIN COLUMNS
, sales_order_line_uid VARCHAR(200) NOT NULL
, status_date DATE NOT NULL

  -- VERSION ATTRIBUTES
, version_index INT NOT NULL
, version_current_ind BIT NOT NULL
, version_latest_ind BIT NOT NULL

  -- END OF RANGE COLUMNS
, end_version_dtmx DATETIME2 NULL
, end_version_batch_key INT NULL
, end_source_rev_dtmx DATETIME2 NULL

, CONSTRAINT vex_sales_order_line_status_history_pk PRIMARY KEY (sales_order_line_status_history_version_key)
)
;
GO

CREATE UNIQUE INDEX vex_sales_order_line_status_history_u1 ON vex.sales_order_line_status_history (sales_order_line_status_history_version_key) WHERE version_latest_ind = 1;
GO

