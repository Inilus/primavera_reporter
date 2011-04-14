# force_encoding: utf-8
#
# reporter_spec.rb

require_relative  'reporter'

describe Reporter, "#load_data" do
  it "returns Hash with data of project on period of time: " do
    department = "4"
    period = Hash[:start => Time.local(2011, 5, 1).to_i, :duration => 1 ]
    creater = Reporter.new( "91.2710 (ПВД К-6)", department, period )

  end

end

