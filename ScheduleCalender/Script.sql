USE [master]
GO
/****** Object:  Database [Event]    Script Date: 08/09/2014  7:13:03 AM ******/
CREATE DATABASE [Event] ON  PRIMARY 
( NAME = N'Event', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Event.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Event_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Event_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Event].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Event] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Event] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Event] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Event] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Event] SET ARITHABORT OFF 
GO
ALTER DATABASE [Event] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Event] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Event] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Event] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Event] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Event] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Event] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Event] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Event] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Event] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Event] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Event] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Event] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Event] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Event] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Event] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Event] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Event] SET RECOVERY FULL 
GO
ALTER DATABASE [Event] SET  MULTI_USER 
GO
ALTER DATABASE [Event] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Event] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Event', N'ON'
GO
USE [Event]
GO
/****** Object:  StoredProcedure [dbo].[Add_Event]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Anup Debnath
-- Create date: 06-Sep-2014
-- Description:	Add to event Table commit
-- =============================================
CREATE PROCEDURE [dbo].[Add_Event]
	@eventName Varchar(400),	
	@startYear Varchar(10),
	@startMonth Varchar(10),
	@startDay Varchar(10),	
	@endYear Varchar(10),
	@endMonth Varchar(10),
	@endDay Varchar(10),
	@startHour Varchar(10),
	@startMin Varchar(10),
	@endHour Varchar(10),
	@endMin Varchar(10),	
	@OtherInfo Varchar(500)='',	
	@backgroundColor Varchar(20),
	@foregroundColor Varchar(20),
	@eventID int =0 out

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbo].[Events]
           ([eventName]
           ,[starYear]
           ,[startMonth]
           ,[startDay]
           ,[endYear]
           ,[endMonth]
           ,[endDay]
           ,[startHour]
           ,[startMin]
           ,[endHour]
           ,[endMin]
           ,[otherInfo]
           ,[backgroundColor]
           ,[foregroundColor]
           ,[addDate]
           ,[Active])
     VALUES
           (@eventName,			
			@startYear,
			@startMonth,
			@startDay,			
			@endYear,
			@endMonth,
			@endDay,
			@startHour,
			@startMin,
			@endHour,
			@endMin,			
			@OtherInfo,
			@backgroundColor,
			@foregroundColor,
			GETDATE(),
			1)
		set @eventID=SCOPE_IDENTITY()

END

GO
/****** Object:  StoredProcedure [dbo].[Del_Event]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Anup Debnath
-- Create date: 06-Sep-2014
-- Description:	Delete Event Commit
-- =============================================
CREATE PROCEDURE [dbo].[Del_Event]
	-- Add the parameters for the stored procedure here
	@eventID int
AS
BEGIN
	
	update [dbo].[Events] set active=0 where eventID=@eventID

END

GO
/****** Object:  StoredProcedure [dbo].[Drag_Event]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Anup Debnath
-- Create date: 06-Sep-2014
-- Description:	Drag Update commit 
-- =============================================
CREATE PROCEDURE [dbo].[Drag_Event]
	@eventID Varchar(400),	
	@startYear Varchar(10),
	@startMonth Varchar(10),
	@startDay Varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare @totalDay bigint,
			@fromDate date ,
			@toDate date,
			@newStartDate date,
			@newEndDate date

	Select @fromDate=CONVERT(VARCHAR(10),(convert(varchar(10),[starYear])+'-'+convert(varchar(10),[startMonth])+'-'+convert(varchar(10),[startDay])),110),
			@toDate=CONVERT(VARCHAR(10),(convert(varchar(10),[endYear])+'-'+convert(varchar(10),[endMonth])+'-'+convert(varchar(10),[endDay])),110)
	from [dbo].[Events] where [eventID]=@eventID

	set @totalDay=DATEDIFF(day,@fromDate,@toDate)
	set @newStartDate=CONVERT(VARCHAR(10),(convert(varchar(10),@startYear)+'-'+convert(varchar(10),@startMonth)+'-'+convert(varchar(10),@startDay)),110)
	Set @newEndDate=DATEADD(day,@totalDay,@newStartDate)

	Update [Events] set 
			[starYear]=@startYear,
			[startMonth]=@startMonth,
			[startDay]=@startDay,
			[endYear]=datepart(YEAR,@newEndDate),
			[endMonth]=datepart(MONTH,@newEndDate),
			[endDay]=datepart(DAY,@newEndDate)
	Where [eventID]=@eventID
END

GO
/****** Object:  StoredProcedure [dbo].[SP_ADD_FileData]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Anup Debnath
-- Create date: 07-Sep-2014
-- Description:	commit
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADD_FileData]
@PLT varchar(100),
@DEPT varchar(100),
@MACH varchar(100),
@YEARX varchar(100),
@NUMX varchar(100),
@UPC varchar(100),
@PDTNM varchar(100),
@PPDT3 varchar(100),
@PPDT4 varchar(100),
@PPDT5 varchar(100),
@ORDER# varchar(100),
@RO varchar(100),
@REPQTY varchar(100),
@SCHQTY varchar(100),
@DLVQTY varchar(100),
@AVGQTY varchar(100),
@STDATE varchar(100),
@TMDATE varchar(100),
@DLDATE varchar(100),
@LWDATE varchar(100),
@ENDATE varchar(100),
@MCHTYP varchar(100),
@SRMK1 varchar(100),
@SRMK2 varchar(100),
@SRMK3 varchar(100),
@SRMK4 varchar(100),
@SRMK5 varchar(100),
@EOQ varchar(100),
@ROP varchar(100),
@TOTBK varchar(100),
@ACTAL varchar(100),
@AVGSHP varchar(100),
@INST1 varchar(100),
@INST2 varchar(100),
@INST3 varchar(100),
@SEQ# varchar(100),
@CTRMID varchar(100),
@CUSRID varchar(100),
@CCHGDT varchar(100),
@CCHGTM varchar(100),
@CSTS varchar(100),
@eventID int
AS
BEGIN
	INSERT INTO [dbo].[FileDetails]
           ([eventID]
           ,[PLT]
           ,[DEPT]
           ,[MACH]
           ,[YEARX]
           ,[NUMX]
           ,[UPC]
           ,[PDTNM]
           ,[PPDT3]
           ,[PPDT4]
           ,[PPDT5]
           ,[ORDER#]
           ,[RO]
           ,[REPQTY]
           ,[SCHQTY]
           ,[DLVQTY]
           ,[AVGQTY]
           ,[STDATE]
           ,[TMDATE]
           ,[DLDATE]
           ,[LWDATE]
           ,[ENDATE]
           ,[MCHTYP]
           ,[SRMK1]
           ,[SRMK2]
           ,[SRMK3]
           ,[SRMK4]
           ,[SRMK5]
           ,[EOQ]
           ,[ROP]
           ,[TOTBK]
           ,[ACTAL]
           ,[AVGSHP]
           ,[INST1]
           ,[INST2]
           ,[INST3]
           ,[SEQ#]
           ,[CTRMID]
           ,[CUSRID]
           ,[CCHGDT]
           ,[CCHGTM]
           ,[CSTS])
     VALUES
           (@eventID,
		   @PLT,
			@DEPT,
			@MACH,
			@YEARX,
			@NUMX,
			@UPC,
			@PDTNM,
			@PPDT3,
			@PPDT4,
			@PPDT5,
			@ORDER#,
			@RO,
			@REPQTY,
			@SCHQTY,
			@DLVQTY,
			@AVGQTY,
			@STDATE,
			@TMDATE,
			@DLDATE,
			@LWDATE,
			@ENDATE,
			@MCHTYP,
			@SRMK1,
			@SRMK2,
			@SRMK3,
			@SRMK4,
			@SRMK5,
			@EOQ,
			@ROP,
			@TOTBK,
			@ACTAL,
			@AVGSHP,
			@INST1,
			@INST2,
			@INST3,
			@SEQ#,
			@CTRMID,
			@CUSRID,
			@CCHGDT,
			@CCHGTM,
			@CSTS
)
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GET_EVENTBY_ID]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Anup Debnath
-- Create date: 07-Sep-2014
-- Description:	Get Event details by ID Commit
-- =============================================
create PROCEDURE [dbo].[SP_GET_EVENTBY_ID]
	@eventID int
AS
BEGIN
	
	Select * from [Events] where active=1 and eventID=@eventID

END


GO
/****** Object:  StoredProcedure [dbo].[SP_GET_EVENTs]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Anup Debnath
-- Create date: 06-Sep-2014
-- Description:	Get Event Commit
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_EVENTs]
	
AS
BEGIN
	
	Select * from [Events] E
	JOIN [dbo].[FileDetails] F on E.eventID=F.eventID
	where active=1 
	--and startMonth=9

END

GO
/****** Object:  Table [dbo].[Events]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Events](
	[eventID] [int] IDENTITY(1,1) NOT NULL,
	[eventName] [varchar](400) NULL,
	[starYear] [varchar](10) NULL,
	[startMonth] [varchar](10) NULL,
	[startDay] [varchar](10) NULL,
	[endYear] [varchar](10) NULL,
	[endMonth] [varchar](10) NULL,
	[endDay] [varchar](10) NULL,
	[startHour] [varchar](10) NULL,
	[startMin] [varchar](10) NULL,
	[endHour] [varchar](10) NULL,
	[endMin] [varchar](10) NULL,
	[otherInfo] [varchar](500) NULL,
	[backgroundColor] [varchar](20) NULL,
	[foregroundColor] [varchar](20) NULL,
	[addDate] [datetime] NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED 
(
	[eventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FileDetails]    Script Date: 08/09/2014  7:13:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileDetails](
	[eventID] [int] NULL,
	[PLT] [varchar](100) NULL,
	[DEPT] [varchar](100) NULL,
	[MACH] [varchar](100) NULL,
	[YEARX] [varchar](100) NULL,
	[NUMX] [varchar](100) NULL,
	[UPC] [varchar](100) NULL,
	[PDTNM] [varchar](100) NULL,
	[PPDT3] [varchar](100) NULL,
	[PPDT4] [varchar](100) NULL,
	[PPDT5] [varchar](100) NULL,
	[ORDER#] [varchar](100) NULL,
	[RO] [varchar](100) NULL,
	[REPQTY] [varchar](100) NULL,
	[SCHQTY] [varchar](100) NULL,
	[DLVQTY] [varchar](100) NULL,
	[AVGQTY] [varchar](100) NULL,
	[STDATE] [varchar](100) NULL,
	[TMDATE] [varchar](100) NULL,
	[DLDATE] [varchar](100) NULL,
	[LWDATE] [varchar](100) NULL,
	[ENDATE] [varchar](100) NULL,
	[MCHTYP] [varchar](100) NULL,
	[SRMK1] [varchar](100) NULL,
	[SRMK2] [varchar](100) NULL,
	[SRMK3] [varchar](100) NULL,
	[SRMK4] [varchar](100) NULL,
	[SRMK5] [varchar](100) NULL,
	[EOQ] [varchar](100) NULL,
	[ROP] [varchar](100) NULL,
	[TOTBK] [varchar](100) NULL,
	[ACTAL] [varchar](100) NULL,
	[AVGSHP] [varchar](100) NULL,
	[INST1] [varchar](100) NULL,
	[INST2] [varchar](100) NULL,
	[INST3] [varchar](100) NULL,
	[SEQ#] [varchar](100) NULL,
	[CTRMID] [varchar](100) NULL,
	[CUSRID] [varchar](100) NULL,
	[CCHGDT] [varchar](100) NULL,
	[CCHGTM] [varchar](100) NULL,
	[CSTS] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_Active]  DEFAULT ((1)) FOR [Active]
GO
USE [master]
GO
ALTER DATABASE [Event] SET  READ_WRITE 
GO
