/*
#######################################################################
Add foreign key constraint
#######################################################################
*/

IF @environment != 'production' AND @retain_fk_constraints = 1
BEGIN

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.gl_tran') AND x.name='gl_tran_fk_client'
)
  ALTER TABLE dbo.gl_tran WITH NOCHECK
  ADD CONSTRAINT gl_tran_fk_client
  FOREIGN KEY (client_key) REFERENCES dbo.client (client_key);

END

BEGIN
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.gl_tran') AND x.name='gl_tran_fk_project'
)
  ALTER TABLE dbo.gl_tran WITH NOCHECK
  ADD CONSTRAINT gl_tran_fk_project
  FOREIGN KEY (project_key) REFERENCES dbo.project (project_key);

END

BEGIN
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.gl_tran') AND x.name='gl_tran_fk_operating_group'
)
  ALTER TABLE dbo.gl_tran WITH NOCHECK
  ADD CONSTRAINT gl_tran_fk_operating_group
  FOREIGN KEY (operating_group_key) REFERENCES dbo.operating_group (operating_group_key);

END

BEGIN
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.gl_tran') AND x.name='gl_tran_fk_resource'
)
  ALTER TABLE dbo.gl_tran WITH NOCHECK
  ADD CONSTRAINT gl_tran_fk_resource
  FOREIGN KEY (resource_key) REFERENCES dbo.resource (resource_key);

END

BEGIN
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys x
  WHERE x.parent_object_id=OBJECT_ID('dbo.gl_tran') AND x.name='gl_tran_fk_calendar'
)
  ALTER TABLE dbo.gl_tran WITH NOCHECK
  ADD CONSTRAINT gl_tran_fk_calendar
  FOREIGN KEY (gl_tran_date_key) REFERENCES dbo.calendar (date_key);

END