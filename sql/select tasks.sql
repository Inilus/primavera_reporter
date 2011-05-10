SELECT 
	TASK.[task_id], TASK.[task_name], 
	--TASK.[status_code], 
	TASK.[remain_drtn_hr_cnt], TASK.[target_drtn_hr_cnt], 
	TASK.[target_start_date], TASK.[target_end_date],
	ACTVCODE_structure.actv_code_name AS name_structure
FROM [dbo].[TASKACTV] AS TASKACTV
	LEFT JOIN [dbo].[TASK] AS TASK
		ON TASK.[task_id] = TASKACTV.[task_id] AND TASK.[proj_id] = 4190 
			AND TASK.[task_type] = 'TT_Task'
	LEFT JOIN [dbo].[TASKACTV] AS TASKACTV_structure
		ON TASKACTV_structure.task_id = TASK.task_id
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE_structure
		ON ACTVCODE_structure.actv_code_id = TASKACTV_structure.actv_code_id
WHERE TASKACTV.[actv_code_id] = 3787 AND TASKACTV.[proj_id] = 4190 
	 AND TASKACTV_structure.actv_code_type_id = (SELECT TOP 1 ACTVTYPE_structure.actv_code_type_id 
		FROM [dbo].[ACTVTYPE] AS ACTVTYPE_structure 
		WHERE ACTVTYPE_structure.actv_code_type LIKE 'Structure')
	AND ( ( TASK.[target_start_date] BETWEEN CONVERT(DATETIME, '2011-04-01', 102) 
			AND CONVERT(DATETIME, '2011-05-01', 102) ) 
		OR ( TASK.[target_end_date] BETWEEN CONVERT(DATETIME, '2011-04-01', 102) 
			AND CONVERT(DATETIME, '2011-05-01', 102) ) 
		OR ( ( TASK.[target_start_date] < CONVERT(DATETIME, '2011-05-01', 102) ) 
			AND ( TASK.[target_end_date] > CONVERT(DATETIME, '2011-04-01', 102) ) ) )
ORDER BY ACTVCODE_structure.actv_code_id, TASK.[task_id]
	
