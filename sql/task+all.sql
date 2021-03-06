/****** Сценарий для команды SelectTopNRows среды SSMS  ******/
SELECT  
	   --TASK.[status_code],
	   TASK.[task_name],
	   --TASK.[remain_drtn_hr_cnt],TASK.[target_drtn_hr_cnt],
	   --TASK.[act_start_date],TASK.[act_end_date],
	   --TASK.[late_start_date],TASK.[late_end_date],
	   --TASK.[early_start_date],TASK.[early_end_date],
	   --TASK.[target_start_date],TASK.[target_end_date],
	   --TASK.[rem_late_start_date],TASK.[rem_late_end_date],	   
	   ACTVTYPE.[actv_code_type],
	   ACTVCODE.[short_name],ACTVCODE.[parent_actv_code_id],ACTVCODE.[actv_code_name],
	   ACTVCODE2.[short_name],ACTVCODE2.[actv_code_name]
  FROM [tempPMDB].[dbo].[TASK] AS TASK
  LEFT JOIN [tempPMDB].[dbo].[TASKACTV] AS TASKACTV 
	ON TASKACTV.[task_id] = TASK.[task_id]
  LEFT JOIN [tempPMDB].[dbo].[ACTVTYPE] AS ACTVTYPE
	ON ACTVTYPE.[actv_code_type_id] = TASKACTV.[actv_code_type_id]
  LEFT JOIN [tempPMDB].[dbo].[ACTVCODE] AS ACTVCODE
	ON ACTVCODE.[actv_code_id] = TASKACTV.[actv_code_id]
	LEFT JOIN [tempPMDB].[dbo].[ACTVCODE] AS ACTVCODE2
	ON ACTVCODE2.[actv_code_id] = ACTVCODE.[parent_actv_code_id]
  WHERE TASK.[proj_id]	= 4143 AND TASK.[wbs_id] = 42964 AND TASK.[task_type] = 'TT_Task'	
	AND ( ( TASK.[target_start_date] BETWEEN CONVERT(DATETIME, '2011-04-01', 102) AND CONVERT(DATETIME, '2011-05-01', 102) ) OR ( TASK.[target_end_date] BETWEEN CONVERT(DATETIME, '2011-04-01', 102) AND CONVERT(DATETIME, '2011-05-01', 102) ) )