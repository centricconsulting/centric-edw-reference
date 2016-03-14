CREATE VIEW [cube].ops_gl_tran AS
SELECT 
  t.gl_tran_key
, t.client_key
, t.project_key
, t.operating_group_key
, t.resource_key
, r.operating_group_key AS resource_operating_group_key
, t.gl_tran_date_key
, NULLIF(t.net_amt,0) AS base_net_amt
, NULLIF(t.income_amt,0) AS base_income_amt
, NULLIF(t.expense_amt,0) AS base_expense_amt
, NULLIF(t.other_income_expense_amt,0) AS base_other_income_expense_amt
, NULLIF(t.expense_overhead_amt,0) AS base_expense_overhead_amt
, NULLIF(t.net_expense_cogs_amt,0) AS base_net_expense_cogs_amt
, NULLIF(t.net_expense_amt,0) AS base_net_expense_amt
, NULLIF(t.net_revenue_amt,0) AS base_net_revenue_amt
, NULLIF(t.cogs_amt,0) AS base_cogs_amt
, NULLIF(t.net_cogs_amt,0) AS base_net_cogs_amt
, NULLIF(t.reimb_expense_income_amt,0) AS base_reimb_expense_income_amt
, NULLIF(t.reimb_expense_cost_amt,0) AS base_reimb_expense_cost_amt
, NULLIF(t.employee_cogs_amt,0) AS base_employee_cogs_amt
, NULLIF(t.contractor_cogs_amt,0) AS base_contractor_cogs_amt
, NULLIF(t.w2t_cogs_amt,0) AS base_w2t_cogs_amt
, NULLIF(t.employee_cost_amt,0) AS base_employee_cost_amt
, NULLIF(t.contractor_cost_amt,0) AS base_contractor_cost_amt
, NULLIF(t.w2t_cost_amt,0) AS base_w2t_cost_amt
, NULLIF(t.gross_profit_amt,0) AS base_gross_profit_amt
, NULLIF(t.non_cogs_amt,0) AS base_non_cogs_amt
, NULLIF(t.net_profit_amt,0) AS base_net_profit_amt
, NULLIF(t.centric_cost_amt,0) AS base_centric_cost_amt
, NULLIF(t.centric_cost_transfer_amt,0) AS base_centric_cost_transfer_amt
, NULLIF(t.net_centric_cost_amt,0) AS base_net_centric_cost_amt
, NULLIF(t.bu_cost_amt,0) AS base_bu_cost_amt
, NULLIF(t.operating_profit_amt,0) AS base_operating_profit_amt
, NULLIF(t.shared_profit_transfer_amt,0) AS base_shared_profit_transfer_amt
, t.gl_tran_type AS [GL Transaction Type]
, t.gl_category AS [GL Category]
, t.gl_account AS [GL Account]
, t.gl_subaccount AS [GL SubAccount]
, t.gl_rollup_account AS [GL Rollup Account]
, t.gl_forecast_rollup_account AS [GL Forecast Rollup Account]
FROM
dbo.gl_tran t
LEFT JOIN dbo.[resource] r ON r.resource_key = t.resource_key

;