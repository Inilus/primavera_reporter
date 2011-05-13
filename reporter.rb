# force_encoding: utf-8
#
# File: creater.rb
#
# Docs for Yaml: 				http://santoro.tk/mirror/ruby-core/classes/YAML.html
# Docs for ProgressBar: http://0xcc.net/ruby-progressbar/index.html.en
# Docs for TinyTds: 		https://github.com/rails-sqlserver/tiny_tds#readme
# Docs for HAML:				http://haml-lang.com/docs/yardoc/Haml.html
# Docs for RubyZip: 		http://rubyzip.sourceforge.net/classes/Zip/ZipFile.html

require 'yaml'
#require 'progressbar'
require 'tiny_tds'
require 'haml'
require 'zip/zip'

class Reporter

	def initialize
		config = YAML.load_file( "config.yml" )
		@client = TinyTds::Client.new( :username => config[:db][:username], :password => config[:db][:password], :dataserver => config[:db][:dataserver], :database => config[:db][:database] )
	end
	
	def get_all_projects
		return @client.execute( createSqlQuery( :select_projects ) ).each( :symbolize_keys => true )
	end

	def load_data( name_project, period=Hash[ :start => "2011-04-01", :finish => "2011-06-01" ] )		
		@project = Hash[ :period 		=> period ]
		
		project = nil
	
		if name_project.class == String	
			@project[:name]	= name_project
			project = @client.execute( createSqlQuery( :select_project ) ).each( :symbolize_keys => true )
			if project.nil?
				puts "Don't find project \"#{ @project[:name] }\"!"
				exit( 1 )
			else
				project = project[0]
				@project[:id_project] = project[:proj_id]
			end			
		else
			@project[:id_project] = name_project
			project = @client.execute( createSqlQuery( :select_project_by_id ) ).each( :symbolize_keys => true )[0]
			@project[:name]	= project[:wbs_short_name]
		end
		@project[:id_wbs] = project[:wbs_id]		
		@project[:name_wbs] = project[:wbs_name]
		
	end
	
	def work_with_department
		departments = @client.execute( createSqlQuery( :select_actvtype, { :name => "Route" }  ) ).each( :symbolize_keys => true )
		## ProgressBar
#	  pbar = ProgressBar.new( "Create report", departments.size )	  
	  dir = nil
		departments.each do |department|			
			if department[:PARENT_actv_code_id].nil?				
				dir = create_report( department[:short_name] ) if dir.nil?
				dir << create_report( department[:short_name] )[1]
			end
			## ProgressBar
#			pbar.inc
		end
		## ProgressBar
#		pbar.finish
		return dir
	end
	
	def create_report( department="" )
    haml_engine = Haml::Engine.new( File.read( 'html_report.haml' ) )		
		
		months = Array["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь"]
		
		data = {
		  :department => department,
		  :period     => "на #{ months[@project[:period][:start][5, 2].to_i - 1] } месяц #{ @project[:period][:start][0,4] } г.",
      :heads      => [
        [
          "№ п/п",
          "№ чертежа",
          "Наименование",
          "Маршрут/ Номер точки маршрута",
          "№ опер. по ТП",
          [ "Даты", 4 ],
          [ "Трудоемкость, н/ч", 2 ],
          [ "Количество, шт.", 3 ],
          "Подтверждающий документ",
          "Примеч."   
        ],
        [ "План. старт",
          "План. финиш",
          "Факт. старт",
          "Факт. финиш",
          
          "План. отработ.",
          "Факт. отработ.",
          
          "Всего",
          "План",
          "Факт"
        ]   
      ]
    }
    
    data[:tasks] = prepare_data( department )

    ## Save file
    dir = "public/output/#{ @project[:name] }"
    file = ""
    unless data[:tasks].empty?    	
    	if not File::directory?( dir )
    		Dir.mkdir( dir )
    	end	
    	file = "#{ @project[:period][:start] }-#{ @project[:period][:finish] } #{ department }"
    	html = haml_engine.render(nil, data)
		  File.open( "#{ dir }/#{ file }.html", "w" ) do |file_report|
				file_report.puts html
				file_report.close
			end
			Zip::ZipFile.open("#{ dir }/#{ file[0, 21] }.zip", Zip::ZipFile::CREATE) { |zipfile|
				zipfile.get_output_stream("#{ file }.html") { |f| f.puts html }
			}
			
		end
		result = Array[ dir[7..-1] ]
		result << file unless file.empty?
		return result
	end
	
	def prepare_data( department="" )
		result = Array.new
				
		departments = @client.execute( createSqlQuery( :select_actvtype, { :name => "Route", :value => department }  ) ).each( :symbolize_keys => true )
		
		id_structure_last = Hash[ :id => -1, :i => 0 ]
		departments.each_with_index do |department, index_dep|
			tasks = @client.execute( createSqlQuery( :select_tasks_with_structure, { :id_actv_code => department[:actv_code_id], :name_actv_code => "Structure" }  ) ).each( :symbolize_keys => true )
			if not tasks.empty?					
				index_task = 0
				tasks.each do |task|
					if id_structure_last[:id] != task[:id_structure]
						id_structure_last[:id] = task[:id_structure] 
						id_structure_last[:i] = id_structure_last[:i] + 1 
						index_task = 0
						result << [
												"<b>#{ id_structure_last[:i] }</b>",
												"",
												"<b>Этап #{ task[:short_name_structure] }. #{ task[:name_structure] }</b>"
											]
					end
					
					index_task += 1
					
					result << [ 
											"#{ id_structure_last[:i] }.#{ index_task }.",
											udf_code_to_value( @client.execute( createSqlQuery( :select_actvcode, { :id_task => task[:task_id], :name_actvtype => "DO" } ) ).each( :symbolize_keys => true ) ),
											task[:task_name],
											udf_code_to_value( @client.execute( createSqlQuery( :select_actvcode, { :id_task => task[:task_id], :name_actvtype => "Route full" } ) ).each( :symbolize_keys => true ) ) + " / " + udf_code_to_value( route_num_str = @client.execute( createSqlQuery( :select_actvcode, { :id_task => task[:task_id], :name_actvtype => "Step route" } ) ).each( :symbolize_keys => true ) ),
											"",
											task[:target_start_date].strftime( "%d.%m.%Y" ),
											task[:target_end_date].strftime( "%d.%m.%Y" ),
											"",
											"",
											udf_code_to_value( @client.execute( createSqlQuery( :select_udf_code, { :id_task => task[:task_id], :name => "Трудоёмкость по ТП" } ) ).each( :symbolize_keys => true ), :number ),			
											"",
											udf_code_to_value( @client.execute( createSqlQuery( :select_udf_code, { :id_task => task[:task_id], :name => "Количество" } ) ).each( :symbolize_keys => true ), :number )
									  ] 
				end	
			
			end
		end
		
		return result
	end

	private 
	
		def udf_code_to_value( array, type=:string )
			case type
				when :string
					return ( not array.empty? ) ? array[0][:short_name].to_s : ""
				when :number
					return ( not array.empty? ) ? array[0][:udf_number].to_i.to_s : 0.to_s
			end
		end
		
		def createSqlQuery( name_query, params={} )
			case name_query
			
	#	  	when
	#	  		## Required: params{  }
	#	  		return 
					
				## def prepare_data
				when :select_actvtype
					## Required: params{ :name [, :value ] }
					sql = Array.new
					if not params[:value].nil?
						sql[0] = "AND ( ACTVCODE.short_name = '#{ params[:value] }' OR ACTVCODE_PARENT.short_name = '#{ params[:value] }' )"
					end
					return "SELECT ACTVCODE.[actv_code_id], ACTVCODE.[short_name] , ACTVCODE_PARENT.[actv_code_id] as PARENT_actv_code_id 
FROM [dbo].[ACTVTYPE] AS ACTVTYPE
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE
 		ON ACTVCODE.[actv_code_type_id] = ACTVTYPE.[actv_code_type_id]
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE_PARENT 
		ON ACTVCODE_PARENT.[actv_code_id] = ACTVCODE.[parent_actv_code_id]		
WHERE ACTVTYPE.[actv_code_type] LIKE '#{ params[:name] }' #{ sql[0] }; "
				when :select_tasks_with_structure
					## Required: params{ :id_actv_code, :name_actv_code }
					return "SELECT 
	TASK.[task_id], TASK.[task_name], 
	--TASK.[status_code], 
	TASK.[remain_drtn_hr_cnt], TASK.[target_drtn_hr_cnt], 
	TASK.[target_start_date], TASK.[target_end_date],
	ACTVCODE_structure.actv_code_id AS id_structure, ACTVCODE_structure.actv_code_name AS name_structure , ACTVCODE_structure.short_name AS short_name_structure
FROM [dbo].[TASKACTV] AS TASKACTV
	LEFT JOIN [dbo].[TASK] AS TASK
		ON TASK.[task_id] = TASKACTV.[task_id] AND TASK.[proj_id] = #{ @project[:id_project] } 
			AND TASK.[task_type] = 'TT_Task'
			AND TASK.[delete_date] is null
	LEFT JOIN [dbo].[TASKACTV] AS TASKACTV_structure
		ON TASKACTV_structure.task_id = TASK.task_id
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE_structure
		ON ACTVCODE_structure.actv_code_id = TASKACTV_structure.actv_code_id
WHERE TASKACTV.[actv_code_id] = #{ params[:id_actv_code] } 
	 AND TASKACTV.[proj_id] = #{ @project[:id_project] } 
	 AND TASKACTV_structure.actv_code_type_id = (SELECT TOP 1 ACTVTYPE_structure.actv_code_type_id 
		FROM [dbo].[ACTVTYPE] AS ACTVTYPE_structure 
		WHERE ACTVTYPE_structure.actv_code_type LIKE '#{ params[:name_actv_code] }')
			AND TASK.[act_end_date] is NULL 
			AND ( 
				( TASK.[target_start_date] BETWEEN CONVERT(DATETIME, '#{ @project[:period][:start] }', 102 ) 
					AND CONVERT( DATETIME, '#{ @project[:period][:finish] }', 102 ) )
				OR ( TASK.[act_start_date] BETWEEN CONVERT(DATETIME, '#{ @project[:period][:start] }', 102 ) 
					AND CONVERT( DATETIME, '#{ @project[:period][:finish] }', 102 ) )
				OR ( ( TASK.[target_end_date] BETWEEN CONVERT(DATETIME, '#{ @project[:period][:start] }', 102 ) 
					AND CONVERT( DATETIME, '#{ @project[:period][:finish] }', 102 ) ) )
				OR ( ( TASK.[target_start_date] < CONVERT(DATETIME, '#{ @project[:period][:finish] }', 102) )
					AND ( TASK.[target_end_date] > CONVERT(DATETIME, '#{ @project[:period][:start] }', 102) ) ) )
ORDER BY ACTVCODE_structure.actv_code_id, TASK.[task_id]"
				when :select_actvcode
					## Required: params{ :id_task, :name_actvtype }
					return "SELECT TOP 1 ACTVCODE.[short_name], ACTVCODE.[actv_code_name]
FROM [dbo].[TASKACTV] AS TASKACTV
	LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE
		ON ACTVCODE.actv_code_id = TASKACTV.actv_code_id
WHERE TASKACTV.[task_id] = #{ params[:id_task] }
	AND TASKACTV.[actv_code_type_id] = ( 
		SELECT TOP 1 ACTVTYPE.[actv_code_type_id] 
		FROM [dbo].[ACTVTYPE] AS ACTVTYPE
		WHERE ACTVTYPE.[actv_code_type] LIKE '#{ params[:name_actvtype] }' )"
				when :select_udf_code
					## Required: params{ :id_task, :name }
					return "SELECT TOP 1 UDFVALUE.[udf_number]
FROM [dbo].[UDFTYPE] AS UDFTYPE
	LEFT JOIN [dbo].[UDFVALUE] AS UDFVALUE
		ON UDFVALUE.[udf_type_id] = UDFTYPE.[udf_type_id]
			AND UDFVALUE.[fk_id] = #{ params[:id_task] }
WHERE UDFTYPE.[table_name] = 'TASK' AND UDFTYPE.[udf_type_label] LIKE '#{ params[:name] }'"
										
				## def load_data
				when :select_project
					## Required: params{  }
					return "SELECT TOP 1 PROJWBS.[wbs_id], PROJWBS.[proj_id], PROJWBS.[wbs_name] 
FROM [dbo].[PROJWBS] AS PROJWBS
WHERE PROJWBS.[wbs_short_name] = '#{ @project[:name].to_s }' AND [proj_node_flag] = 'Y'; "
					when :select_project_by_id
					## Required: params{  }
					return "SELECT TOP 1 PROJWBS.[wbs_id], PROJWBS.[wbs_name], PROJWBS.[wbs_short_name]
FROM [dbo].[PROJWBS] AS PROJWBS
WHERE PROJWBS.[proj_id] = #{ @project[:id_project].to_s } AND [proj_node_flag] = 'Y'; "

				## def get_all_projects
				when :select_projects
					## Required: params{  }
					return "SELECT PROJWBS.[wbs_id], PROJWBS.[proj_id], PROJWBS.[wbs_name], PROJWBS.[wbs_short_name] 
FROM [dbo].[PROJWBS] AS PROJWBS
<<<<<<< HEAD
  LEFT JOIN [dbo].[PROJECT] AS PROJECT 
    ON PROJECT.proj_id = PROJWBS.proj_id
WHERE PROJWBS.[proj_node_flag] = 'Y' 
  AND PROJECT.[orig_proj_id] is null
	AND PROJECT.[project_flag] = 'Y'
=======
LEFT JOIN [dbo].[PROJECT] AS PROJECT ON PROJECT.[proj_id] = PROJWBS.[proj_id]
WHERE PROJWBS.[proj_node_flag] = 'Y' AND PROJECT.[orig_proj_id] is null AND  PROJECT.[project_flag] = 'Y'
>>>>>>> e4eb9a4a1c3e3931dad20c4ad759d5f4468063e8
ORDER BY PROJWBS.[wbs_name] ASC; "

				else
					return nil
			end
		end
end
