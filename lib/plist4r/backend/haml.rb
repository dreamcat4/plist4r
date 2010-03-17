
require 'plist4r/backend_base'

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
					- when Fixnum
						%key #{k}
						%integer #{v}
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
						- raise "Invalid input. Hash: #{data.inspect} can only contain values of type true, false, String (<string>) Fixnum (<integer>) Array (<array>) or Hash (<dict>). Found value: #{v.inspect} of type: \"#{v.class}\""
		- p.call( @hash, p)
EOC
    end

    def to_xml plist
      require 'haml'
      # engine = Haml::Engine.new File.read("launchd_plist.haml")
      engine = Haml::Engine.new to_xml_haml
      rendered_xml_output = engine.render self
      File.open(@filename,'w') do |o|
        o << rendered_xml_output
      end
    end

    def save plist
      file_format = plist.file_format || Config[:default_format]
      raise "#{self} - cant save file format #{file_format}" unless file_format == :xml

      hash = plist.to_hash
      filename = plist.filename_path
      File.open(filename,'w') do |out|
        out << to_xml(plist)
      end
    end
  end
end

