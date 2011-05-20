#!/usr/bin/env ruby
#
# force_encoding: utf-8
#
# File:	runner_html.rb

require 'sinatra'
require 'haml'			# http://haml-lang.com/docs/yardoc/Haml.html
require 'yaml'			# http://santoro.tk/mirror/ruby-core/classes/YAML.html

require_relative  'reporter'

begin

	configure do
		@config = YAML.load_file( "config.yml" )
#    set :bind => "10.10.120.202", :port => 8001
    set :bind => @config[:bind][:ip], :port => @config[:bind][:port]
  end

	before do
		@reporter = Reporter.new( @config )
	end

	get '/' do
    haml :index, :locals => { :projects => @reporter.get_all_projects }
  end

	post '/run/*' do
		puts params
		@reporter.load_data( params["Project"].to_i, Hash[ :start => params["from"], :finish => params["to"] ] )
		path = @reporter.work_with_department

		paths = Array.new
		# On [0] save path to zip file
		paths[0] = nil
		Dir.foreach( path ) do |filename|
			unless filename.include? (".zip")
				paths << "#{ path[7..-1] }/#{ filename }" unless File::directory?( filename )
			else
				paths[0] = "#{ path[7..-1] }/#{ filename }"
			end
		end

		haml :end, :locals => { :paths => paths }
	end



end

