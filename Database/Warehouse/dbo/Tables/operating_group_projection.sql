
CREATE TABLE [dbo].[operating_group_projection] (
    [projection_month_key]           INT           NOT NULL,
    [operating_group_key]            INT           NOT NULL,
    [month_key]                      INT           NOT NULL,
    [projection_desc]                VARCHAR (200) NOT NULL,
    [current_flag]                   CHAR (1)      NULL,
    [projected_revenue_amt]          MONEY         NULL,
    [projected_operating_profit_amt] MONEY         NULL,
    [source_key]                     INT           NOT NULL,
    [source_revision_dtm]            DATETIME      NOT NULL,
    [source_revision_actor]          VARCHAR (200) NULL,
    [init_process_batch_key]         INT           NOT NULL,
    [process_batch_key]              INT           NOT NULL,
    CONSTRAINT [operating_group_projection_pk] PRIMARY KEY CLUSTERED ([operating_group_key] ASC, [projection_month_key] ASC, [month_key] ASC)
);





/*

SELECT 
  [YearNumber]
, [MonthNumber]
, [BusinessUnitID]
, bu.Code
, bu.Name
, [ForecastCategoryID]
,  m.Name
, [Amount]
FROM [EnterpriseApps].[dbo].[BusinessUnitForecast] b
inner join LUV_master m on m.id = b.[ForecastCategoryID]
inner join LUV_master bu ON bu.id = b.BusinessUnitID
WHERE
m.Name IN ('Revenue','Operating Profit')


*/
