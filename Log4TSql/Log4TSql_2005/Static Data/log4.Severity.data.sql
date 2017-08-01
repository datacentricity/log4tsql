set nocount on
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 1
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        1
      , 'Showstopper/Critical Failure'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Showstopper/Critical Failure'
    where
        [SeverityId] = 1
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 2
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        2
      , 'Severe Failure'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Severe Failure'
    where
        [SeverityId] = 2
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 4
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        4
      , 'Major Failure'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Major Failure'
    where
        [SeverityId] = 4
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 8
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        8
      , 'Moderate Failure'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Moderate Failure'
    where
        [SeverityId] = 8
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 16
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        16
      , 'Minor Failure'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Minor Failure'
    where
        [SeverityId] = 16
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 32
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        32
      , 'Concurrency Violation'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Concurrency Violation'
    where
        [SeverityId] = 32
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 64
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        64
      , 'Reserved for future Use 1'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Reserved for future Use 1'
    where
        [SeverityId] = 64
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 128
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        128
      , 'Reserved for future Use 2'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Reserved for future Use 2'
    where
        [SeverityId] = 128
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 256
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        256
      , 'Informational'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Informational'
    where
        [SeverityId] = 256
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 512
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        512
      , 'Success'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Success'
    where
        [SeverityId] = 512
go

if not exists
    (
        select 1 from [log4].[Severity] where [SeverityId] = 1024
    )
  insert into [log4].[Severity]
      (
        [SeverityId]
      , [SeverityName]
      )
  values
      (
        1024
      , 'Debug'
      )
else
    update
        [log4].[Severity]
    set
          [SeverityName] = 'Debug'
    where
        [SeverityId] = 1024
go


set nocount on
go

