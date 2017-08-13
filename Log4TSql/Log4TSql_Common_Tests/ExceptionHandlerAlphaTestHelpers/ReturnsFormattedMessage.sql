create procedure [ExceptionHandlerAlphaTestHelpers].[ReturnsFormattedMessage]
(
  @ErrorContext		nvarchar	(  512 )	= null
)
as
begin
	set nocount on;

	declare @returnMessage	nvarchar(1000)

	begin try
		raiserror('This is a test exception', 16, 99);
	end try
	begin catch
		exec [log4].[ExceptionHandler] @ErrorContext = @ErrorContext, @ReturnMessage = @returnMessage out
	end catch

	select @returnMessage as [returnMessage]

	return;
end