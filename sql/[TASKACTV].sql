/****** Сценарий для команды SelectTopNRows среды SSMS  ******/
SELECT TOP 1000 [task_id]
      ,[actv_code_type_id]
      ,[actv_code_id]
      ,[proj_id]
  FROM [tempPMDB].[dbo].[TASKACTV]
  WHERE [proj_id] = 4143