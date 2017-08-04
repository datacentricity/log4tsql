create   procedure [CommonSchemaTests].[test log4Private.Journal.SystemDate defaults to local system insert date-time]
as
begin
	declare	@_start datetime2(4) = getdate();

	--! Assemble
	exec tSQLt.FakeTable @TableName = 'log4Private.Journal', @Defaults = 1;

	--! Act
	insert log4Private.Journal (JournalId) values (1);

	--! Assert
	declare @_actual datetime2(4) = (select SystemDate from log4Private.Journal)

	declare	@_end datetime2(4) = getdate();

	if coalesce(@_actual, '19000101') not between @_start and @_end
		begin
			declare @msg varchar(500) = 'Expected SystemDate between '
				+ format(@_start, 'yyyy-MM-dd HH:mm:ss.mmmm') + ' and ' + format(@_end, 'yyyy-MM-dd HH:mm:ss.mmmm')
				+ ' but was ' + coalesce(format(@_actual, 'yyyy-MM-dd HH:mm:ss.mmmm'), 'NULL')

			exec tSQLt.Fail @msg ;
		end
end