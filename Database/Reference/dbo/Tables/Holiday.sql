CREATE TABLE [dbo].[Holiday]
(
  HolidayDate date NOT NULL
, HolidayDesc varchar(100) NOT NULL
, CONSTRAINT dbo_Holiday_PK PRIMARY KEY (HolidayDate)
);
