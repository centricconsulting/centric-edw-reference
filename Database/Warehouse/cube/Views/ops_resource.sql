




CREATE VIEW [cube].[ops_resource] AS
SELECT [resource_key]
, [full_name_collated] AS [Resource]
, [resource_type_key]
, [operating_group_key]
, [job_title] AS [Job Title]
, [network_login] AS [Network Login]
, [company_name] AS [Company Name]
, [career_track] AS [Career Track]
, [effective_begin_dt] AS hire_date
, [effective_end_dt] AS termination_date
, YEAR([effective_begin_dt]) * 10000 + MONTH([effective_begin_dt]) * 100 + DAY([effective_begin_dt]) AS hire_date_key
, YEAR([effective_end_dt]) * 10000 + MONTH([effective_end_dt]) * 100 + DAY([effective_end_dt]) AS termination_date_key
, CASE WHEN bench_flag = 'Y' THEN 'Bench' ELSE 'Non-Bench' END AS bench_flag
, CASE WHEN ISNULL(effective_end_dt, '12/31/2100') > ref.[Current Date] THEN 'Employed' ELSE 'Not Employed' END AS [Current Employment Flag]
FROM
[dbo].[resource]
CROSS JOIN [cube].ops_reference ref
;