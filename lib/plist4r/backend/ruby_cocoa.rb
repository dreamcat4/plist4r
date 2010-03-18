
require 'plist4r/backend_base'

module Plist4r::Backend::RubyCocoa
  class << self
    def ruby_cocoa_wrapper_rb
      @ruby_cocoa_wrapper_rb ||= <<-'EOC'
#!/usr/bin/ruby
raise "No path given to plist4r" unless ARGV[0] && File.exists?("#{ARGV[0]}/plist4r.rb")

dir = ARGV[0]
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'plist4r/mixin/ordered_hash'
require 'osx/cocoa'

class OSX::NSObject
  def to_ruby
    case self
    when OSX::NSDate
      self.to_time
    when OSX::NSCFBoolean
      self.boolValue
    when OSX::NSNumber
      self.integer? ? self.to_i : self.to_f
    when OSX::NSString
      self.to_s
    when OSX::NSAttributedString
      self.string.to_s
    when OSX::NSArray
      self.to_a.map { |x| x.is_a?(OSX::NSObject) ? x.to_ruby : x }
    when OSX::NSDictionary
      h = ::ActiveSupport::OrderedHash.new
      self.each do |x, y| 
        x = x.to_ruby if x.is_a?(OSX::NSObject)
        y = y.to_ruby if y.is_a?(OSX::NSObject)
        h[x] = y
      end
      h
    else
      self
    end
  end
end

module Plist
  def to_xml hash
    # to_plist defaults to NSPropertyListXMLFormat_v1_0
    x = hash.to_plist
    puts "#{x}"
  end

  def to_binary hash
    # Here 200 == NSPropertyListBinaryFormat_v1_0
    x = hash.to_plist 200
    puts "#{x}"
  end

  def open filename
    plist_dict = ::OSX::NSDictionary.dictionaryWithContentsOfFile(filename)
    puts "#{plist_dict.to_ruby.inspect}"
  end

  def save hash, filename, file_format
    case file_format.to_sym
    when :xml
      x = hash.to_plist # NSPropertyListXMLFormat_v1_0
    when :binary
      x = hash.to_plist 200 # NSPropertyListBinaryFormat_v1_0
    when :next_step
      raise "File format #{file_format.inspect} is not supported by RubyCocoa"
    else
      raise "File format #{file_format.inspect} not recognised"
    end
    File.open(filename,'w'){ |o| o << x }
  end
end

class RubyCocoaWrapper
  include Plist

  def exec stdin
    instance_eval stdin
    exit 0
  end
end

stdin = $stdin.read()
wrapper = RubyCocoaWrapper.new()
wrapper.exec stdin
EOC
    end

    def ruby_cocoa_exec stdin_str
      rubycocoa_framework = "/System/Library/Frameworks/RubyCocoa.framework"
      raise "RubyCocoa Framework not found. Searched in: #{rubycocoa_framework}" unless File.exists? rubycocoa_framework

      require 'tempfile'
      require 'plist4r/mixin/popen4'

      unless @rb_script && File.exists?(@rb_script.path)
        @rb_script = Tempfile.new "ruby_cocoa_wrapper.rb."
        @rb_script.puts ruby_cocoa_wrapper_rb
        @rb_script.close
        File.chmod 0755, @rb_script.path
      end
      
      plist4r_root = File.expand_path File.join(File.dirname(__FILE__), "..", "..")
      cmd = @rb_script.path

      pid, stdin, stdout, stderr = ::Plist4r::Popen4::popen4 [cmd, plist4r_root]

        stdin.puts stdin_str

        stdin.close
        ignored, status = Process::waitpid2 pid

        stdout_result = stdout.read.strip
        stderr_result = stderr.read.strip

      return [cmd, status, stdout_result, stderr_result]    
    end

    def to_xml plist
      hash = plist.to_hash
      result = ruby_cocoa_exec "to_xml(#{hash.inspect})"
      case result[1].exitstatus
      when 0
        xml_string = result[2]
        return xml_string
      else
        $stderr.puts result[3]
        raise "Error executing #{result[0]}. See stderr for more information"
      end
    end

    def to_binary plist
      hash = plist.to_hash
      result = ruby_cocoa_exec "to_binary(#{hash.inspect})"
      case result[1].exitstatus
      when 0
        binary_string = result[2]
        return binary_string
      else
        $stderr.puts result[3]
        raise "Error executing #{result[0]}. See stderr for more information"
      end
    end
    
    def open_with_args plist, filename
      result = ruby_cocoa_exec "open(\"#{filename}\")"
      case result[1].exitstatus
      when 0
        hash = ::ActiveSupport::OrderedHash.new
        eval("hash.replace("+result[2]+")")
        plist.import_hash hash
      else
        $stderr.puts result[3]
        raise "Error executing #{result[0]}. See stderr for more information"
      end
      file_format = Plist4r.file_detect_format filename
      plist.file_format file_format
      return plist
    end

    def from_string plist
      require 'tempfile'
      tf = Tempfile.new "from_string.plist."
      tf.write plist.from_string
      tf.close
      filename = tf.path
      return open_with_args plist, filename
    end

    def open plist
      return open_with_args plist, plist.filename
    end

    def save hash, filename, file_format
      filename = plist.filename_path
      file_format = plist.file_format || Config[:default_format]
      raise "#{self} - cant save file of format #{file_format}" unless [:xml,:binary].include? file_format

      hash = plist.to_hash
      result = ruby_cocoa_exec "save(\"#{hash.inspect}\",#{filename},#{file_format})"
      case result[1].exitstatus
      when 0
        return true
      else
        raise "Error executing #{result[0]}. See stderr for more information"
      end
    end
  end
end

