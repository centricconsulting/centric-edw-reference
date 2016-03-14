CREATE TABLE cube.ops_resource_book (
  project_key INT NOT NULL
, project_operating_group_key INT NOT NULL
, client_key INT NOT NULL
, resource_key INT NOT NULL
, resource_operating_group_key INT NOT NULL
, book_date_key INT NOT NULL
, [Charge Flag] VARCHAR(200) NOT NULL
, base_book_revenue money
, base_book_hours decimal(20,12)
)