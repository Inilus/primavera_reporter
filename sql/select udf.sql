/****** Сценарий для команды SelectTopNRows среды SSMS  ******/
SELECT 
	UDFVALUE.[fk_id], UDFVALUE.[udf_number]
  FROM [dbo].[UDFTYPE] AS UDFTYPE
	LEFT JOIN [dbo].[UDFVALUE] AS UDFVALUE
		ON UDFVALUE.[udf_type_id] = UDFTYPE.[udf_type_id]
  WHERE UDFTYPE.[table_name] = 'TASK' AND UDFTYPE.[udf_type_label] LIKE 'Количество'