CREATE PROCEDURE cube.[prepare_ops_tables] AS
BEGIN

EXEC cube.prepare_ops_ar_balance;
EXEC cube.prepare_ops_operating_group_plan;
EXEC cube.prepare_ops_resource_book;
EXEC cube.prepare_ops_timesheet;
EXEC cube.prepare_ops_operating_group_projection;

END
;
