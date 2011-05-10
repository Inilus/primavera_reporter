# force_encoding: utf-8
#

require 'haml'
engine = Haml::Engine.new( File.read( 'test_haml.haml' ) )

data = {
	:greeting => 'Hello, Dave Thomas',
	:reasons => [
		{ :reason_name => 'flexible', 		:rank => '87' },
		{ :reason_name => 'transparent', 	:rank => '76' },
		{ :reason_name => 'fun', 					:rank => '94' },
	]
}
puts engine.render(nil, data)


