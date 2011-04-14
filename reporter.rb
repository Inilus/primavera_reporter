# force_encoding: utf-8
#
# File: creater.rb
#
# Docs for Yaml: 				http://santoro.tk/mirror/ruby-core/classes/YAML.html
# Docs for ProgressBar: http://0xcc.net/ruby-progressbar/index.html.en
# Docs for TinyTds: 		https://github.com/rails-sqlserver/tiny_tds#readme
# Docs for Spreadsheet:	http://spreadsheet.rubyforge.org/GUIDE_txt.html

require 'yaml'
require 'progressbar'
require 'tiny_tds'
require 'spreadsheet'

class Reporter

	def initialize ( name_project, department, period=Hash[ :start => Time.now, :duration_in_month => 1 ] )
		config = YAML.load_file( "config.yml" )
		@client = TinyTds::Client.new( :username => config[:db][:username], :password => config[:db][:password], :dataserver => config[:db][:dataserver], :database => config[:db][:database] )
		@project = Hash[ 
			:name 			=> name_project, 
			:department => department,
			:period 		=> period 
		]	
		
#		@book_report = Spreadsheet::Workbook.new
#		@sheet_report = @book_report.create_worksheet( :name => 'Report' )	
	end

	def load_data
		project = @client.execute( createSqlQuery( :select_project ) ).each( :symbolize_keys => true )[0]
		if project.nil?
			puts "Don't find project \"#{ @project[:name] }\"!"
			exit( 1 )
		end
		@project[:id_wbs] = project[:wbs_id]
		@project[:id_project] = project[:proj_id]
		@project[:name_wbs] = project[:wbs_name]
		
		@actv_types = @client.execute( createSqlQuery( :select_actvtype ) ).each( :symbolize_keys => true )
		@actv_codes = @client.execute( createSqlQuery( :select_actvcode ) ).each( :symbolize_keys => true )
		@actv_task_actvs = @client.execute( createSqlQuery( :select_actvcode ) ).each( :symbolize_keys => true )
		@tasks = @client.execute( createSqlQuery( :select_task ) ).each( :symbolize_keys => true )
	end
	
	def read_form_report
		book = Spreadsheet.open( 'forms/plan.xls' )
		sheet = book.worksheet( 0 )
		
		## Save footer and clear
		footer = sheet.row( 11 )	
		sheet.update_row( 11, '' )

		## Insert new data
		sheet[1, 5] = sheet.row( 1 )[5] + @project[:department].to_s
		months = Array["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь"]
		sheet[2, 5] = sheet.row( 2 )[5] + " #{ months[@project[:period][:start].month - 1] } месяц #{ @project[:period][:start].year } г."
		
		format = Spreadsheet::Format.new 	:weight => 700,
																			:name => "Arial Narrow",
																			:weight => 700,
																			:bottom_color => :border, 
																			:top_color => :border, 
																			:left_color => :border, 
																			:right_color => :border, 
																			:diagonal_color => :border, 
																			:pattern_fg_color => :border,
																			:horizontal_align => :center, 
																			:vertical_align		=> :bottom,
																			:left							=> true, 
																			:bottom						=> true
                                   		
#		14.times do |i| 
			sheet.row( 10 ).set_format( 0, sheet.row( 9 ).format( 0 ) )
			sheet[10, 0] = "10"
			sheet[10, 1] = "10"
			sheet.row( 11 ).set_format( 1, sheet.row( 9 ).format( 1 ) )
			sheet[11, 0] = "11"
			sheet[11, 1] = "11"
			sheet.row( 12 ).default_format = format
			sheet.row( 13 ).default_format = format
#		end
		
		## Restore footer
		14.times do |i| 
			sheet[15, i] = footer[i]
			sheet.row( 15 ).set_format( i, footer.format( i ) )
		end
		
		## Save file
		book.write 'output/report.xls'
	end


	def createSqlQuery( name_query, params={} )
	  case name_query
	  
#	  	when
#	  		## Required: params{  }
#	  		return 
	  		
			## def load_data
		  when :select_project
		  	## Required: params{  }
		  	return "SELECT TOP 1 [wbs_id], [proj_id], [wbs_name] FROM [dbo].[PROJWBS] WHERE [wbs_short_name] LIKE '#{ @project[:name].to_s }' AND [proj_node_flag] = 'Y'; "
		  when :select_actvtype
		  	## Required: params{  }
		  	return "SELECT [actv_code_type_id], [actv_code_type] FROM [dbo].[ACTVTYPE]; "
		  when :select_actvcode
	  		## Required: params{  }
	  		return "SELECT ACTVCODE.[actv_code_id], ACTVCODE.[actv_code_type_id], ACTVCODE.[short_name], ACTVCODE.[actv_code_name], ACTVCODE_PARENT.[actv_code_id] as PARENT_actv_code_id, ACTVCODE_PARENT.[short_name] as short_name, ACTVCODE_PARENT.[actv_code_name] as PARENT_actv_code_name 
FROM [dbo].[ACTVCODE] AS ACTVCODE 
LEFT JOIN [dbo].[ACTVCODE] AS ACTVCODE_PARENT ON ACTVCODE_PARENT.[actv_code_id] = ACTVCODE.[parent_actv_code_id]; "
		  when :select_taskactv
	  		## Required: params{  }
	  		return "SELECT [task_id],[actv_code_type_id],[actv_code_id],[proj_id] FROM [dbo].[TASKACTV] WHERE [proj_id] = #{ @project[:id_project].to_s }; "
			when :select_task
	  		## Required: params{  }
	  		start  = "#{ @project[:period][:start].year }-#{ @project[:period][:start].month }-01"
	  		finish = "#{ @project[:period][:start].year }-#{ @project[:period][:start].month + @project[:period][:duration_in_month] }-01"
	  		return "SELECT TASK.[status_code], TASK.[task_name], TASK.[remain_drtn_hr_cnt], TASK.[target_drtn_hr_cnt], TASK.[target_start_date], TASK.[target_end_date] 
FROM [dbo].[TASK] AS TASK
--LEFT JOIN 

WHERE TASK.[proj_id]	= #{ @project[:id_project].to_s } AND TASK.[wbs_id] = #{ @project[:id_wbs].to_s } AND TASK.[task_type] = 'TT_Task'	AND ( ( TASK.[target_start_date] BETWEEN CONVERT(DATETIME, '#{ start }', 102) AND CONVERT(DATETIME, '#{ finish }', 102) ) OR ( TASK.[target_end_date] BETWEEN CONVERT(DATETIME, '#{ start }', 102) AND CONVERT(DATETIME, '#{ finish }', 102) ) ); "
	  		# TODO Add Left join and filter by department
		  else
		  	return nil
		end
	end
end
