/****** Сценарий для команды SelectTopNRows среды SSMS  ******/
SELECT TOP 1000 [actv_code_id]
      ,[actv_code_type_id]
      ,[short_name]
      ,[parent_actv_code_id]
      ,[actv_code_name]
  FROM [tempPMDB].[dbo].[ACTVCODE]
  