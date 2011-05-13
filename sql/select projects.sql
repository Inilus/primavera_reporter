SELECT PROJWBS.[wbs_id], PROJWBS.[proj_id], PROJWBS.[wbs_name], PROJWBS.[wbs_short_name] 
FROM [dbo].[PROJWBS] AS PROJWBS
LEFT JOIN [dbo].[PROJECT] AS PROJECT ON PROJECT.proj_id = PROJWBS.proj_id
WHERE PROJWBS.[proj_node_flag] = 'Y' 
	AND PROJECT.[orig_proj_id] is null
	AND PROJECT.[project_flag] = 'Y'
ORDER BY PROJWBS.[wbs_name] ASC;
