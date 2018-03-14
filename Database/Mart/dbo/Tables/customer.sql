CREATE TABLE [dbo].[customer] (
    [customer_key]             INT              NOT NULL,
    [last_sales_order_date]    DATE             NULL,
    [customer_legal_name]      VARCHAR (200)    NULL,
    [parent_organization_name] VARCHAR (200)    NULL,
    [customer_nbr]             VARCHAR (50)     NULL,
    [risk_score_val]           DECIMAL (20, 12) NULL,
    [process_batch_key]        INT              NULL,
    CONSTRAINT [dbo_customer_pk] PRIMARY KEY CLUSTERED ([customer_key] ASC)
);



