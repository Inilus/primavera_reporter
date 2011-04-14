# force_encoding: utf-8
#
# runner.rb

require_relative  'reporter'

class Runner
	def initialize
		if ARGV.empty? or ARGV[0].nil? or ARGV[1].nil?
			puts "Incorrect parameter! For example: \"ruby runner.rb '91.2446' 4\""
  		exit( 1 )
		end
		
		reporter = Reporter.new( ARGV[0].to_s, ARGV[1].to_s )
		
		reporter.load_data
		reporter.read_form_report
		
	end
	
	def run
	
	end
	
end

Runner.new.run
