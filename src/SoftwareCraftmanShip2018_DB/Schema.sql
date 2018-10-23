
----------------- part 1: drop first if exits   ---------------
------------------------------------------------------------

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('"Order"') and o.name = 'FK_ORDER_REFERENCE_CUSTOMER')
alter table "Order"
   drop constraint FK_ORDER_REFERENCE_CUSTOMER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('OrderItem') and o.name = 'FK_ORDERITE_REFERENCE_ORDER')
alter table OrderItem
   drop constraint FK_ORDERITE_REFERENCE_ORDER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('OrderItem') and o.name = 'FK_ORDERITE_REFERENCE_PRODUCT')
alter table OrderItem
   drop constraint FK_ORDERITE_REFERENCE_PRODUCT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Product') and o.name = 'FK_PRODUCT_REFERENCE_SUPPLIER')
alter table Product
   drop constraint FK_PRODUCT_REFERENCE_SUPPLIER
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Customer')
            and   name  = 'IndexCustomerName'
            and   indid > 0
            and   indid < 255)
   drop index Customer.IndexCustomerName
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Customer')
            and   type = 'U')
   drop table Customer
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('"Order"')
            and   name  = 'IndexOrderOrderDate'
            and   indid > 0
            and   indid < 255)
   drop index "Order".IndexOrderOrderDate
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('"Order"')
            and   name  = 'IndexOrderCustomerId'
            and   indid > 0
            and   indid < 255)
   drop index "Order".IndexOrderCustomerId
go

if exists (select 1
            from  sysobjects
           where  id = object_id('"Order"')
            and   type = 'U')
   drop table "Order"
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('OrderItem')
            and   name  = 'IndexOrderItemProductId'
            and   indid > 0
            and   indid < 255)
   drop index OrderItem.IndexOrderItemProductId
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('OrderItem')
            and   name  = 'IndexOrderItemOrderId'
            and   indid > 0
            and   indid < 255)
   drop index OrderItem.IndexOrderItemOrderId
go

if exists (select 1
            from  sysobjects
           where  id = object_id('OrderItem')
            and   type = 'U')
   drop table OrderItem
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Product')
            and   name  = 'IndexProductName'
            and   indid > 0
            and   indid < 255)
   drop index Product.IndexProductName
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Product')
            and   name  = 'IndexProductSupplierId'
            and   indid > 0
            and   indid < 255)
   drop index Product.IndexProductSupplierId
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Product')
            and   type = 'U')
   drop table Product
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Supplier')
            and   name  = 'IndexSupplierCountry'
            and   indid > 0
            and   indid < 255)
   drop index Supplier.IndexSupplierCountry
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Supplier')
            and   name  = 'IndexSupplierName'
            and   indid > 0
            and   indid < 255)
   drop index Supplier.IndexSupplierName
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Supplier')
            and   type = 'U')
   drop table Supplier
go


----------------- part 2: create   ---------------
------------------------------------------------------------


/*==============================================================*/
/* Table: Customer                                              */
/*==============================================================*/
create table Customer (
   Id                   int                  identity,
   FirstName            nvarchar(40)         not null,
   LastName             nvarchar(40)         not null,
   City                 nvarchar(40)         null,
   Country              nvarchar(40)         null,
   Phone                nvarchar(20)         null,
   constraint PK_CUSTOMER primary key (Id)
)
go

/*==============================================================*/
/* Index: IndexCustomerName                                     */
/*==============================================================*/
create index IndexCustomerName on Customer (
LastName ASC,
FirstName ASC
)
go

/*==============================================================*/
/* Table: "Order"                                               */
/*==============================================================*/
create table "Order" (
   Id                   int                  identity,
   OrderDate            datetime             not null default getdate(),
   OrderNumber          nvarchar(10)         null,
   CustomerId           int                  not null,
   TotalAmount          decimal(12,2)        null default 0,
   constraint PK_ORDER primary key (Id)
)
go

/*==============================================================*/
/* Index: IndexOrderCustomerId                                  */
/*==============================================================*/
create index IndexOrderCustomerId on "Order" (
CustomerId ASC
)
go

/*==============================================================*/
/* Index: IndexOrderOrderDate                                   */
/*==============================================================*/
create index IndexOrderOrderDate on "Order" (
OrderDate ASC
)
go

/*==============================================================*/
/* Table: OrderItem                                             */
/*==============================================================*/
create table OrderItem (
   Id                   int                  identity,
   OrderId              int                  not null,
   ProductId            int                  not null,
   UnitPrice            decimal(12,2)        not null default 0,
   Quantity             int                  not null default 1,
   constraint PK_ORDERITEM primary key (Id)
)
go

/*==============================================================*/
/* Index: IndexOrderItemOrderId                                 */
/*==============================================================*/
create index IndexOrderItemOrderId on OrderItem (
OrderId ASC
)
go

/*==============================================================*/
/* Index: IndexOrderItemProductId                               */
/*==============================================================*/
create index IndexOrderItemProductId on OrderItem (
ProductId ASC
)
go

/*==============================================================*/
/* Table: Product                                               */
/*==============================================================*/
create table Product (
   Id                   int                  identity,
   ProductName          nvarchar(50)         not null,
   SupplierId           int                  not null,
   UnitPrice            decimal(12,2)        null default 0,
   Package              nvarchar(30)         null,
   IsDiscontinued       bit                  not null default 0,
   constraint PK_PRODUCT primary key (Id)
)
go

/*==============================================================*/
/* Index: IndexProductSupplierId                                */
/*==============================================================*/
create index IndexProductSupplierId on Product (
SupplierId ASC
)
go

/*==============================================================*/
/* Index: IndexProductName                                      */
/*==============================================================*/
create index IndexProductName on Product (
ProductName ASC
)
go

/*==============================================================*/
/* Table: Supplier                                              */
/*==============================================================*/
create table Supplier (
   Id                   int                  identity,
   CompanyName          nvarchar(40)         not null,
   ContactName          nvarchar(50)         null,
   ContactTitle         nvarchar(40)         null,
   City                 nvarchar(40)         null,
   Country              nvarchar(40)         null,
   Phone                nvarchar(30)         null,
   Fax                  nvarchar(30)         null,
   constraint PK_SUPPLIER primary key (Id)
)
go

/*==============================================================*/
/* Index: IndexSupplierName                                     */
/*==============================================================*/
create index IndexSupplierName on Supplier (
CompanyName ASC
)
go

/*==============================================================*/
/* Index: IndexSupplierCountry                                  */
/*==============================================================*/
create index IndexSupplierCountry on Supplier (
Country ASC
)
go

alter table "Order"
   add constraint FK_ORDER_REFERENCE_CUSTOMER foreign key (CustomerId)
      references Customer (Id)
go

alter table OrderItem
   add constraint FK_ORDERITE_REFERENCE_ORDER foreign key (OrderId)
      references "Order" (Id)
go

alter table OrderItem
   add constraint FK_ORDERITE_REFERENCE_PRODUCT foreign key (ProductId)
      references Product (Id)
go

alter table Product
   add constraint FK_PRODUCT_REFERENCE_SUPPLIER foreign key (SupplierId)
      references Supplier (Id)
go

/****** Object:  StoredProcedure [dbo].[sp_InsertCustomer]    Script Date: 22/10/2018 17:04:01 ******/
DROP PROCEDURE [dbo].[sp_InsertCustomer]
GO

/****** Object:  StoredProcedure [dbo].[sp_InsertCustomer]    Script Date: 22/10/2018 17:04:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Stu Pidasol
-- Create date: Once upon a time a very long time ago
-- Description:	Procedure to insert new customers into the Customer Table
--              Procedure checks all paramaters are not null and checks if textual strings contain numbers and Number strings contain text chars
-- =============================================

CREATE PROCEDURE [dbo].[sp_InsertCustomer] (
                                    @FirstName nvarchar(40)
									, @LastName nvarchar(40)
									, @City nvarchar(40)
									, @Country nvarchar(40)
									, @Phone nvarchar(20)
									, @ID INT OUTPUT 
									)


AS
BEGIN
  SET NOCOUNT ON 
	DECLARE @Now DATETIME = GETDATE()
	DECLARE @Error BIT = 0 
	DECLARE @ErrorExists BIT = 0 
	DECLARE @ErrorMessage NVARCHAR (MAX) = ''
    DECLARE @ErrorSeverity INT = 16
    DECLARE @ErrorState INT = 1  
	DECLARE @ObjectName NVARCHAR (255) = OBJECT_NAME(@@PROCID)
	DECLARE @WorkFlowID INT 
	DECLARE @ContainsLetterMask NVARCHAR (MAX)  = '%[a-Z]%'
	DECLARE @ContainsNumberMask NVARCHAR (MAX)  = '%[0-9]%'
BEGIN TRY

--Validate @FirstName

IF LEN (@FirstName) = 0 
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@FirstName has zero Length, Value: is ' + COALESCE (@FirstName , 'Blank') + '.'  
END 

IF @FirstName  like @ContainsNumberMask
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@FirstName cannot contain numbers, Value: is ' + COALESCE (@FirstName , 'Blank') + '.'  
END 

--Validate @LastName
IF LEN (@LastName) = 0 
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@LastName has zero Length, Value: is ' + COALESCE (@LastName , 'Blank') + '.'  
END 

IF @LastName  like @ContainsNumberMask
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@LastName cannot contain numbers, Value: is ' + COALESCE (@LastName , 'Blank') + '.'  
END 


--Validate @City
IF LEN (@City) = 0 
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@City has zero Length, Value: is ' + COALESCE (@City , 'Blank') + '.'  
END 

IF @City  like @ContainsNumberMask
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@City cannot contain numbers, Value: is ' + COALESCE (@City , 'Blank') + '.'  
END 



--Validate @Country
IF LEN (@Country) = 0 
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@Country has zero Length, Value: is ' + COALESCE (@Country , 'Blank') + '.'  
END 

IF @Country  like @ContainsNumberMask
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@Country cannot contain numbers, Value: is ' + COALESCE (@Country , 'Blank') + '.'  
END 


--Validate @Phone
IF LEN (@Phone) = 0 
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@Phone has zero Length, Value: is ' + COALESCE (@Phone , 'Blank') + '.'  
END 

IF @Phone  like @ContainsLetterMask
BEGIN
	SET @ErrorExists = 1
	SET @ErrorMessage = @ErrorMessage + '@Country cannot contain numbers, Value: is ' + COALESCE (@Phone , 'Blank') + '.'  
END 

IF @ErrorExists = 1
BEGIN
    
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
END      

END TRY

 BEGIN CATCH 
 
     SELECT   
         @ErrorMessage ='Error in object: ' + @ObjectName  + '.' + @ErrorMessage + COALESCE (@ErrorMessage,'') 
       , @ErrorSeverity = ERROR_SEVERITY()  
       , @ErrorState = ERROR_STATE()  

    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  

    END CATCH 

	
 IF @ErrorExists = 0 
BEGIN
 
 BEGIN TRANSACTION Process 
 BEGIN TRY	 

 PRINT 'Inserting CustomerData'
 




INSERT INTO [dbo].[Customer]
           ([FirstName]
           ,[LastName]
           ,[City]
           ,[Country]
           ,[Phone])
     VALUES
           (@FirstName
           ,@LastName
           ,@City
           ,@Country
           ,@Phone)

    SET @ID = SCOPE_IDENTITY()
	COMMIT TRANSACTION Process

	END TRY

	BEGIN CATCH
	DECLARE @ErrorMessageInner NVARCHAR(4000);  
    DECLARE @ErrorSeverityInner INT;  
    DECLARE @ErrorStateInner INT;  

    SELECT   
        @ErrorMessageInner = ERROR_MESSAGE(),  
        @ErrorSeverityInner = ERROR_SEVERITY(),  
        @ErrorStateInner = ERROR_STATE();  

    -- Use RAISERROR inside the CATCH block to return error  
    -- information about the original error that caused  
    -- execution to jump to the CATCH block.  
    RAISERROR (@ErrorMessageInner, -- Message text.  
               @ErrorSeverityInner, -- Severity.  
               @ErrorStateInner -- State.  
               );  
    ROLLBACK TRANSACTION Process
	END CATCH
    END 





	END 




GO


