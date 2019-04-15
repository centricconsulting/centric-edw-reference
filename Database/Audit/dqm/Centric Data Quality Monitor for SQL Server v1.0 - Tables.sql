--USE sample_warehouse
--go

-- drop table dqmon_query
create table cdm.dqmon_query (
  dqmon_query_key int identity(1,1)
, dqmon_desc varchar(255) NOT NULL  
, dqmon_type varchar(200) NOT NULL -- Reconciliation, Data Quality, Error Counts, Frame Integrity, Missing Records, Process Monitoring
, scope varchar(200)
, version varchar(20)
, notes varchar(200)
, active_ind bit default 1
, target_value int NOT NULL
, threshold_value int NOT NULL
, value_text varchar(50)
, query varchar(2000) NOT NULL
, tag_list varchar(200)
, constraint dqmon_query_pk primary key (dqmon_query_key)
)


-- drop table dqmon_batch
create table cdm.dqmon_batch (
  dqmon_batch_key int identity(1,1)  
, execution_dtm datetime default getdate()
, constraint dqmon_batch_pk primary key (dqmon_batch_key)
)

-- drop table dqmon_result
create table cdm.dqmon_result (
  dqmon_result_key int identity(1,1)
, dqmon_query_key int NOT NULL
, dqmon_batch_key int NOT NULL
, version varchar(20)  
, execution_start_dtm datetime
, execution_end_dtm datetime
, execution_duration_ms AS (datediff(ms,execution_start_dtm, execution_end_dtm))
, execution_result varchar(20) -- Failed, Successful, Timed-out
, completed_ind bit
, return_value int
, error_number int
, error_message varchar(2000)
, constraint dqmon_result_pk primary key (dqmon_result_key)
)


-- drop table cdm.dqmon_check_grain
create table cdm.dqmon_check_grain (
  dqmon_check_grain_key int identity(1,1)
, table_name varchar(200) not null
, key_column_list varchar(2000) not null
, grain_column_list varchar(2000) not null
, version_ind bit
, active_ind bit default 1
, tag_list varchar(200)
)

-- drop table cdm.dqmon_check_refint
create table cdm.dqmon_check_refint (
  dqmon_check_refint_key int identity(1,1)
, primary_table_name varchar(200) not null
, primary_grain_column_list varchar(2000) not null
, primary_version_ind bit
, foreign_table_name varchar(200) not null
, foreign_grain_column_list varchar(2000) not null
, foreign_frame_ind bit
, reverse_applicable_ind bit
, active_ind bit default 1
, tag_list varchar(200)
)