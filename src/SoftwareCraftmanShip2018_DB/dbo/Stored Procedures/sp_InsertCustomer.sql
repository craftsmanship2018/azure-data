-- =============================================
-- Author:		Stu Pidasol
-- Create date: Once upon a time a very long time ago
-- Description:	Procedure to insert new customers into the Customer Table
--              Procedure checks all paramaters are not null and checks if textual strings contain numbers and Number strings contain text chars
-- =============================================

CREATE PROCEDURE sp_InsertCustomer (
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



