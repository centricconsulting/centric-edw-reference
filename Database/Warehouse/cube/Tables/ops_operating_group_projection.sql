CREATE TABLE cube.ops_operating_group_projection (
  operating_group_key INT NOT NULL
, date_key INT NOT NULL
, project_key INT NOT NULL
, client_key INT NOT NULL
, resource_key INT NOT NULL
, resource_operating_group_key  INT NOT NULL
, base_projected_revenue_amt money
, base_projected_operating_profit_amt money
)