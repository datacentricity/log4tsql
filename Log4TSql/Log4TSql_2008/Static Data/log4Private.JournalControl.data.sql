set nocount on
go

merge into [log4Private].[JournalControl] as Target
using (values
  ('SYSTEM_DEFAULT','ON')
 ,('SYSTEM_OVERRIDE','ON')
) as Source ([ModuleName],[OnOffSwitch])
on (Target.[ModuleName] = Source.[ModuleName])
when matched and (
	nullif(Source.[OnOffSwitch], Target.[OnOffSwitch]) is not null or nullif(Target.[OnOffSwitch], Source.[OnOffSwitch]) is not null) then
 update set
  [OnOffSwitch] = Source.[OnOffSwitch]
when not matched by target then
 insert([ModuleName],[OnOffSwitch])
 values(Source.[ModuleName],Source.[OnOffSwitch])
when not matched by source then 
 delete
;
go
declare @mergeError int
 , @mergeCount int
select @mergeError = @@error, @mergeCount = @@rowcount
if @mergeError != 0
 begin
 print 'ERROR OCCURRED IN MERGE FOR [log4Private].[JournalControl]. Rows affected: ' + cast(@mergeCount as varchar(100)); -- SQL should always return zero rows affected
 end
else
 begin
 print '[log4Private].[JournalControl] rows affected by MERGE: ' + cast(@mergeCount as varchar(100));
 end
go

set nocount off
go
