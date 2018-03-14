CREATE TABLE [dbo].[sales_order] (
    [sales_order_key]          INT              NOT NULL,
    [customer_key]             INT              NULL,
    [revenue_legal_entity_key] INT              NULL,
    [freight_amt]              DECIMAL (20, 12) NULL,
    [tax_amt]                  DECIMAL (20, 12) NULL,
    [sales_order_date]         DATE             NULL,
    [sales_order_nbr]          VARCHAR (100)    NULL,
    [process_batch_key]        INT              NULL,
    CONSTRAINT [dbo_sales_order_pk] PRIMARY KEY CLUSTERED ([sales_order_key] ASC)
);



