
require 'plist4r/config'
require 'plist4r/mixin/ordered_hash'

class Plist4r::Backend
  ApiMethods = %w[from_string to_xml to_binary to_next_step open save]

  def initialize plist, *args, &blk
    @plist = plist
    @backends = Config[:backends].collect do |b| 
      case b
      when Module
        b
      when Symbol, String
        eval "::Plist4r::Backend::#{b.to_s.camelcase}"
      else
        raise "Backend #{b.inspect} is of unsupported type: #{b.class}"
      end
    end
  end

  def call method_sym, *args, &blk
    raise "Unsupported api call #{method_sym.inspect}" unless ApiMethods.include? method_sym.to_s
    exceptions = []
    @backends.each do |backend|
      if backend.respond_to? method_sym
        begin
          return backend.send(method_sym, @plist, *args, &blk)
        rescue LoadError
          exceptions << $!
        rescue
          exceptions << $!
        end
      end
      if Config[:raise_any_failure] && exceptions.first
        raise exceptions.first
      end
    end
    if exceptions.empty?
      raise "Plist4r: No backend found to handle method #{method_sym.inspect}. Could not execute method #{method_sym.inspect} on plist #{@plist.inspect}"
    else
      $stderr.puts "Couldn't execute method #{method_sym.inspect} on plist #{@plist.inspect}."
      exceptions.each do |e|
        $stderr.puts e.inspect
      end
      raise exceptions.first
    end
  end
end



