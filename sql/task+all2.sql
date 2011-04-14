/****** Сценарий для команды SelectTopNRows среды SSMS  ******/
SELECT [status_code], [task_name], [remain_drtn_hr_cnt], [target_drtn_hr_cnt], [target_start_date], [target_end_date]
FROM [dbo].[TASK] 
WHERE [proj_id]	= 4143 AND [wbs_id] = 42964 AND [task_type] = 'TT_Task'	AND ( ( [target_start_date] BETWEEN CONVERT(DATETIME, '2011-04-01', 102) AND CONVERT(DATETIME, '2011-05-01', 102) ) OR ( [target_end_date] BETWEEN CONVERT(DATETIME, '2011-04-01', 102) AND CONVERT(DATETIME, '2011-05-01', 102) ) )
