set nocount on
go

merge into [log4Private].[Severity] as Target
using (values
  (1,'Showstopper/Critical Failure')
 ,(2,'Severe Failure')
 ,(4,'Major Failure')
 ,(8,'Moderate Failure')
 ,(16,'Minor Failure')
 ,(32,'Concurrency Violation')
 ,(256,'Informational')
 ,(512,'Success')
 ,(1024,'Debug')
) as Source ([SeverityId],[SeverityName])
on (Target.[SeverityId] = Source.[SeverityId])
when matched and (
	nullif(Source.[SeverityName], Target.[SeverityName]) is not null or nullif(Target.[SeverityName], Source.[SeverityName]) is not null) then
 update set
  [SeverityName] = Source.[SeverityName]
when not matched by target then
 insert([SeverityId],[SeverityName])
 values(Source.[SeverityId],Source.[SeverityName])
when not matched by source then 
 delete
;
go
declare @mergeError int
 , @mergeCount int
select @mergeError = @@error, @mergeCount = @@rowcount
if @mergeError != 0
 begin
 print 'ERROR OCCURRED IN MERGE FOR [log4Private].[Severity]. Rows affected: ' + cast(@mergeCount as varchar(100)); -- SQL should always return zero rows affected
 end
else
 begin
 print '[log4Private].[Severity] rows affected by MERGE: ' + cast(@mergeCount as varchar(100));
 end
go

set nocount off
go
