CREATE TABLE cube.[ops_operating_group_plan](
 [operating_group_key] INT NOT NULL
,[date_key] INT NOT NULL
, project_key INT NOT NULL
, client_key INT NOT NULL
, resource_key INT NOT NULL
, resource_operating_group_key INT NOT NULL
,[base_plan_revenue_amt] money
,[base_plan_operating_profit_amt] money
,[base_plan_gross_profit_amt] money

)
GO