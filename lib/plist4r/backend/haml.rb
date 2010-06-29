
require 'plist4r/backend_base'

# This backend uses haml to *write* xml plists
# @author Dreamcat4 (dreamcat4@gmail.com)
module Plist4r::Backend::Haml
  class << self
    def to_xml_haml
      @to_xml_haml ||= <<-'EOC'
!!! XML UTF-8
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd" >
%plist{ :version => '1.0' }
	%dict
		- p = Proc.new do |data, block| 
			- data.each_pair do |k,v|
				- raise "Invalid input. Hash: #{data.inspect} can only contain keys of type Symbol or String. Found key #{k.inspect}, of type: \"#{k.class}\"" unless [Symbol,String].include? k.class
				- case v
					- when TrueClass, FalseClass
						%key #{k}
						<#{v}/>
					- when String
						%key #{k}
						%string #{v}
					- when Integer
						%key #{k}
						%integer #{v}
					- when Float
						%key #{k}
						%real #{v}
					- when Time
						%key #{k}
						%date #{v.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}
					- when Date
						%key #{k}
						%date #{v.strftime('%Y-%m-%dT%H:%M:%SZ')}
					- when IO, StringIO
						- data = String.new; v.rewind
						- Base64::encode64(v.read).gsub(/\s+/, '').scan(/.{1,68}/o) { data << $& << "\n" }
						%key #{k}
						%data #{data}
					- when Array
						%key #{k}
						%array
							- v.compact.each do |e|
								- case e
									- when TrueClass, FalseClass
										<#{v}/>
									- when String
										%string #{e}
									- when Fixnum
										%integer #{v}
									- when Hash
										%dict
											- tab_up ; block.call(e, block) ; tab_down
									- else
										- raise "Invalid input. Array: #{v.inspect} can only contain elements of type String (<string>) or Hash (<dict>). Found element: #{e.inspect} of type: \"#{e.class}\""
					- when Hash
						%key #{k}
						%dict
							- tab_up ; block.call(v, block) ; tab_down
					- else
						- data = String.new
						- Base64::encode64(Marshal.dump(v)).gsub(/\s+/, '').scan(/.{1,68}/o) { data << $& << "\n" }
						%key #{k}
						%data
							#{data}

		- p.call( @plist.to_hash, p)
EOC
    end

    def to_xml plist
      @plist = plist
      require 'haml'
      require 'base64'
      engine = Haml::Engine.new to_xml_haml
      rendered_xml_output = engine.render self
    end

  end
end

