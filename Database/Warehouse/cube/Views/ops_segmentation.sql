CREATE VIEW cube.[ops_segmentation] AS

SELECT
  CAST(x.segment_type AS VARCHAR(20)) AS [Segment Type]
, CAST(x.segment_desc AS VARCHAR(20)) AS [Segment]
, CAST(x.segment_code AS VARCHAR(20)) AS segment_code
, CAST(x.min_value AS DECIMAL(8,4)) AS min_value
, CAST(x.max_value AS DECIMAL(8,4)) AS max_value
, CAST(x.sort_index AS INT) AS sort_index
FROM
(

  SELECT
    'BU Utilization' AS segment_type
  , 'RANGE_MIN_85EXC' AS segment_code
  , -9999.9999 AS min_value
  , 0.85 AS max_value
  , '< 85%' AS segment_desc
  , 10001 AS sort_index

    UNION ALL

  SELECT
    'BU Utilization' AS segment_type
  , 'RANGE_85_100EXC' AS segment_code
  , 0.85 AS min_value
  , 1.00 AS max_value
  , '85%-100%' AS segment_desc
  , 10005 AS sort_index

  UNION ALL

  SELECT
    'BU Utilization' AS segment_type
  , 'RANGE_100_MAX' AS segment_code
  , 1.00 AS min_value
  , 9999.9999 AS max_value
  , '> 100%' AS segment_desc
  , 10007 AS sort_index

) x
;