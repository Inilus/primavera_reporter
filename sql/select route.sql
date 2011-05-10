SELECT ACTVTYPE.actv_code_type, ACTVCODE.[actv_code_id], ACTVCODE_PARENT.[actv_code_id] as PARENT_actv_code_id 
FROM [dbo].[ACTVTYPE] AS ACTVTYPE
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE
 		ON ACTVCODE.[actv_code_type_id] = ACTVTYPE.[actv_code_type_id]
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE_PARENT 
		ON ACTVCODE_PARENT.[actv_code_id] = ACTVCODE.[parent_actv_code_id]		
WHERE ACTVTYPE.[actv_code_type] LIKE 'Route' AND ( ACTVCODE.short_name = '4' OR ACTVCODE_PARENT.short_name = '4' )
