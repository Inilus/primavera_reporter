# force_encoding: utf-8
#
# runner.rb

require_relative  'reporter'

class Runner
	def initialize
		if ARGV.empty? or ARGV[0].nil? or ARGV[1].nil? or ARGV[2].nil?
			puts "Incorrect parameter! For example: \"ruby runner.rb '91.2446' '2011-04-25' '2011-06-30'\""
  		exit( 1 )
		end
		
		reporter = Reporter.new
		
		reporter.load_data( ARGV[0].to_s, Hash[ :start => ARGV[1].to_s, :finish => ARGV[2].to_s ] )
		reporter.work_with_department
#		reporter.create_report
		
	end
	
	def run
	
	end
	
end

Runner.new.run
