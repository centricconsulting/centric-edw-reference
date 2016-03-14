CREATE PROCEDURE cube.prepare_ops_ar_balance AS
BEGIN

SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;
SET ANSI_NULLS OFF;

TRUNCATE TABLE cube.ops_ar_balance;

INSERT INTO  cube.ops_ar_balance (
  [snapshot_date_key]
, [project_operating_group_key]
, [client_key]
, [project_key]
, [resource_key]
, [resource_operating_group_key]
, [Invoice Nbr]
, [Transaction Terms]
, [Invoice Date]
, [Past Due Flag]
, [Past Due Days]
, [Invoice Age Flag]
, [Invoice Age]
, [Term Days]
, [Customer Ref]
, [Project Ref]
, [base_balance_amt]
, [base_90plusday_balance_amt]
, [base_6190day_balance_amt]
, [base_3160day_balance_amt]
, [base_0030day_balance_amt]
, [base_grace_balance_amt]
, [past_due_flag_sort_index]
, [Most Recent Flag]
)

SELECT
  snapshot_date_key
, [operating_group_key] AS project_operating_group_key
, [client_key]
, [project_key]
, -1 AS resource_key
, -1 AS resource_operating_group_key

, ar.invoice_nbr AS [Invoice Nbr]
, CASE WHEN ar.transaction_terms ='' THEN 'Unspecified' ELSE ar.transaction_terms END AS [Transaction Terms]
, ar.invoice_date AS [Invoice Date]

, CASE
  WHEN ar.past_due_days > 90 THEN '91+ Days'
	WHEN ar.past_due_days BETWEEN 61 AND 90 THEN '61-90 Days'
	WHEN ar.past_due_days BETWEEN 31 AND 60 THEN '31-60 Days'
	WHEN ar.past_due_days BETWEEN 1 AND 30 THEN '1-30 Days' 
	ELSE 'Grace Period'	END AS [Past Due Flag]

, CASE WHEN ar.past_due_days > 0 THEN NULLIF(ar.past_due_days,0) END AS [Past Due Days]

, CASE
  WHEN ar.invoice_age > 120 THEN '120+ Days'
  WHEN ar.invoice_age BETWEEN 91 AND 120 THEN '91-120 Days'
	WHEN ar.invoice_age BETWEEN 61 AND 90 THEN '61-90 Days'
	WHEN ar.invoice_age BETWEEN 31 AND 60 THEN '31-60 Days'
	WHEN ar.invoice_age BETWEEN 1 AND 30 THEN '1-30 Days' 
	ELSE 'Not Yet Posted'	END AS [Invoice Age Flag]

, ar.invoice_age AS [Invoice Age]
, ar.term_days AS [Term Days]

, ar.original_customer_desc AS [Customer Ref]
, ar.original_project_desc AS [Project Ref]

, NULLIF(ar.[invoice_amt], 0) AS base_invoice_amt
, CASE WHEN ar.past_due_days > 90 THEN NULLIF(ar.invoice_amt,0) END AS base_90plusday_balance_amt
, CASE WHEN ar.past_due_days BETWEEN 61 AND 90 THEN NULLIF(ar.invoice_amt,0) END AS base_6190day_balance_amt
, CASE WHEN ar.past_due_days BETWEEN 31 AND 60 THEN NULLIF(ar.invoice_amt,0) END AS base_3160day_balance_amt
, CASE WHEN ar.past_due_days BETWEEN 1 AND 30 THEN NULLIF(ar.invoice_amt,0) END AS base_0030day_balance_amt
, CASE WHEN ar.past_due_days <= 0 THEN NULLIF(ar.invoice_amt,0) END AS base_grace_balance_amt
, CASE
	WHEN ar.past_due_days > 90 THEN 40				-- 91+ Days
	WHEN ar.past_due_days BETWEEN 61 AND 90 THEN 30	-- 61-90 Days
	WHEN ar.past_due_days BETWEEN 31 AND 60 THEN 20	-- 31-60 Days
	WHEN ar.past_due_days BETWEEN 1 AND 30 THEN 10	-- 1-30 Days
	ELSE 0  END AS [past_due_flag_sort_index]
, CASE
	WHEN ar.snapshot_date_key = ( SELECT MAX(snapshot_date_key) FROM dbo.ar_balance ) THEN 'Yes'
	ELSE 'No'
  END

FROM (

  SELECT 
    snapshot_date_key
  , [operating_group_key]
  , [client_key]
  , [project_key]
  , [transaction_terms]
  , [invoice_amt]
  , [invoice_nbr]
  , original_customer_desc
  , original_project_desc
  , CAST([invoice_date] AS DATE) AS invoice_date

  , DATEDIFF(day, invoice_date, c.[date]) AS invoice_age

  , CASE
    WHEN transaction_terms like '%Net 7' THEN 7
    WHEN transaction_terms like '%Net 10' THEN 10
    WHEN transaction_terms like '%Net 30' THEN 30
    WHEN transaction_terms like '%Net 45' THEN 45
    WHEN transaction_terms like '%Net 60' THEN 60
    WHEN transaction_terms like '%Net 90' THEN 90
    ELSE 30 END AS term_days

  , DATEDIFF(day, invoice_date, c.[date]) - 
      CASE
      WHEN transaction_terms like '%Net 7' THEN 7
      WHEN transaction_terms like '%Net 10' THEN 10
      WHEN transaction_terms like '%Net 30' THEN 30
      WHEN transaction_terms like '%Net 45' THEN 45
      WHEN transaction_terms like '%Net 60' THEN 60
      WHEN transaction_terms like '%Net 90' THEN 90
      ELSE 30 END  AS past_due_days

  FROM
  [dbo].[ar_balance] x
  INNER JOIN dbo.calendar c ON c.date_key = x.snapshot_date_key
  
) ar

;
END