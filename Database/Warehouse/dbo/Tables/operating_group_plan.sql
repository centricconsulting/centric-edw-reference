CREATE TABLE [dbo].[operating_group_plan] (
    [operating_group_key]       INT           NOT NULL,
    [month_key]                 INT           NOT NULL,
    [plan_revenue_amt]          MONEY         NULL,
    [plan_operating_profit_amt] MONEY         NOT NULL,
    [plan_gross_profit_amt]     MONEY         NULL,
    [source_key]                INT           NOT NULL,
    [source_revision_dtm]       DATETIME      NOT NULL,
    [source_revision_actor]     VARCHAR (200) NULL,
    [init_process_batch_key]    INT           NOT NULL,
    [process_batch_key]         INT           NOT NULL,
    CONSTRAINT [operating_group_plan_pk] PRIMARY KEY CLUSTERED ([operating_group_key] ASC, [month_key] ASC)
);




/*

select
  p.YearNumber
, p.MonthNumber
, p.BusinessUnit
, p.TypeDescription
, p.SubTypeDescription
, p.Amount
FROM
CentricEnterpriseDW..LUV_FinancialPlan_ByMonth p
WHERE
TypeDescription IN ('Revenue','Operating Profit')


*/
