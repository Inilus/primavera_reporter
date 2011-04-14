/****** Сценарий для команды SelectTopNRows среды SSMS  ******/
SELECT ACTVCODE.[actv_code_id], ACTVCODE.[actv_code_type_id], ACTVCODE.[short_name], ACTVCODE.[actv_code_name], ACTVCODE_PARENT.[actv_code_id] as PARENT_actv_code_id, ACTVCODE_PARENT.[short_name] as short_name, ACTVCODE_PARENT.[actv_code_name] as PARENT_actv_code_name 
FROM [dbo].[ACTVCODE] AS ACTVCODE 
LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE_PARENT ON ACTVCODE_PARENT.[actv_code_id] = ACTVCODE.[parent_actv_code_id]; 
