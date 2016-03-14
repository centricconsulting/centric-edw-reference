CREATE TABLE cube.[ops_ar_balance](
	[snapshot_date_key] [int] NOT NULL,
	[project_operating_group_key] [int] NOT NULL,
	[client_key] [int] NOT NULL,
	[project_key] [int] NOT NULL,
	resource_key INT NOT NULL,
	resource_operating_group_key INT NOT NULL,
	[Invoice Nbr] [varchar](50) NULL,
	[Transaction Terms] [varchar](50) NULL,
	[Invoice Date] [date] NULL,
	[Past Due Flag] [varchar](12) NOT NULL,
	[Past Due Days] [int] NULL,
	[Invoice Age Flag] [varchar](14) NOT NULL,
	[Invoice Age] [int] NULL,
	[Term Days] [int] NOT NULL,
	[Customer Ref] varchar(200) NULL,
	[Project Ref] varchar(200) NULL,
	[base_balance_amt] money NULL,
	[base_90plusday_balance_amt] money NULL,
	[base_6190day_balance_amt] money NULL,
	[base_3160day_balance_amt] money NULL,
	[base_0030day_balance_amt] money NULL,
	[base_grace_balance_amt] money NULL, 
    [past_due_flag_sort_index] INT NULL, 
    [Most Recent Flag] VARCHAR(3) NULL

) ON [PRIMARY]

GO