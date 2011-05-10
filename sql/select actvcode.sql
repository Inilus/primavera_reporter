SELECT ACTVCODE.[short_name], ACTVCODE.[actv_code_name]
FROM [dbo].[TASKACTV] AS TASKACTV
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE
		ON ACTVCODE.actv_code_id = TASKACTV.actv_code_id
WHERE TASKACTV.[task_id] = 212463
	AND TASKACTV.[actv_code_type_id] = ( 
		SELECT TOP 1 ACTVTYPE.[actv_code_type_id] 
		FROM [dbo].[ACTVTYPE] AS ACTVTYPE
		WHERE ACTVTYPE.[actv_code_type] LIKE 'DO' )