
require 'plist4r/config'
require 'plist4r/backend_base'
require 'plist4r/mixin/ordered_hash'

module Plist4r
  # This class is the Backend broker. The purpose of this object is to manage and handle API
  # calls, passing them over to the appropriate Plist4r backends.
  class Backend
    # The list of known backend API methods. Any combination or subset of API methods
    # can be implemented by an individual backend.
    # @see Plist4r::Backend::Example
    ApiMethods = %w[from_string to_xml to_binary to_next_step open save]
    
    # A new instance of Backend. A single Backend will exist for the the life of
    # the Plist object. The attribute @plist is set during initialization and 
    # refers back to the plist instance object.
    def initialize plist, *args, &blk
      @plist = plist
      @backends = plist.backends.collect do |b| 
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

    # vv We need a version of this to call our matrix test harness vv
    # Call a Plist4r API Method. Here, we usually pass a {Plist4r::Plist} object
    # as one of the parameters, which will also contain all the input data to work on.
    # 
    # This function loops through the array of available backends, and calls the
    # same method on the first backend found to implemente the specific request.
    # 
    # If the request fails, the call is re-executed on the next available 
    # backend.
    # 
    # The plist object is updated in-place.
    # 
    # @raise if no backend is able to sucessfully execute the request.
    # @param [Symbol] method_sym The API method call to execute
    # @param *args Any optional arguments to pass to the backend
    def call method_sym, *args, &blk
      # puts "in call"
      # puts "#{method_sym.inspect} #{args.inspect}"
      raise "Unsupported api call #{method_sym.inspect}" unless ApiMethods.include? method_sym.to_s
      exceptions = []
      @backends.each do |backend|
        if backend.respond_to? method_sym
          begin
            result = backend.send(method_sym, @plist, *args, &blk)
            # puts "result = #{result.inspect}"
            return result
            # return backend.send(method_sym, @plist, *args, &blk)
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
        # $stderr.puts "Failure(s) while executing method #{method_sym.inspect} on plist #{@plist}."
        exceptions.each do |e|
          $stderr.puts e.inspect
          $stderr.puts e.backtrace.collect { |l| "\tfrom #{l}"}.join "\n"
        end
        # raise exceptions.first
        raise "Failure(s) while executing method #{method_sym.inspect} on plist #{@plist}."
      end
    end
  end
end


