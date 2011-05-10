# 
# force_encoding: utf-8
#
# runner_html.rb

require 'sinatra'
require 'haml'

require_relative  'reporter'

begin

	configure do
    set :bind => "10.10.120.202", :port => 8001
  end

	before do
		@reporter = Reporter.new
	end
	
	get '/' do				
    haml :index, :locals => { :projects => @reporter.get_all_projects }
  end

	post '/run/*' do
		puts params
		@reporter.load_data( params["Project"].to_i, Hash[ :start => params["from"], :finish => params["to"] ] )
		paths = @reporter.work_with_department		
	
		paths_tmp = Array.new
		paths.each do |p|
			paths_tmp << p unless p.nil?
		end		
		paths = paths_tmp

		haml :end, :locals => { :paths => paths }
	end
	

	
end
