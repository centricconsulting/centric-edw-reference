CREATE TABLE [dbo].[project_resource_plan] (
    [project_key]               INT             NOT NULL,
    [resource_key]              INT             NOT NULL,
    [month_key]                 INT             NOT NULL,
    [week_key]                  INT             NOT NULL,
    [pipeline_revenue_amt]      MONEY           NULL,
    [pipeline_gross_profit_amt] MONEY           NULL,
    [pipeline_net_profit_amt]   MONEY           NULL,
    [win_probability]           DECIMAL (12, 4) NOT NULL,
    [weighted_revenue_amt]      MONEY           NULL,
    [weighted_gross_profit_amt] MONEY           NULL,
    [weighted_net_profit_amt]   MONEY           NULL,
    [book_revenue_amt]          MONEY           NULL,
    [book_gross_profit_amt]     MONEY           NULL,
    [book_net_profit_amt]       MONEY           NULL,
    [book_hours]                DECIMAL (12, 4) NULL,
    [source_key]                INT             NOT NULL,
    [source_revision_dtm]       DATETIME        NOT NULL,
    [source_revision_actor]     VARCHAR (200)   NULL,
    [init_process_batch_key]    INT             NOT NULL,
    [process_batch_key]         INT             NOT NULL,
    CONSTRAINT [project_resource_plan_pk] PRIMARY KEY CLUSTERED ([project_key] ASC, [resource_key] ASC, [month_key] ASC, [week_key] ASC)
);



