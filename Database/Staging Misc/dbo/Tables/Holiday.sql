CREATE TABLE [dbo].[Holiday]
(
  HolidayDate date NOT NULL
, HolidayDesc varchar(100) NOT NULL

, process_batch_key int NOT NULL
, CONSTRAINT Holiday_PK PRIMARY KEY (HolidayDate)
);
