# force_encoding: utf-8

require 'rubygems'
require 'roo'

#s = Openoffice.new("input/91-2710.ods")
#s = Excel.new("input/91-2710.xls")

s = Google.new("Test_table", "inilus.work@gmail.com", "funnyb@g")

#s.default_sheet = s.sheets.first

p s.cell('A',2)

s.set_value('A', 2, "Test_ID")

p s.cell('A',2)
