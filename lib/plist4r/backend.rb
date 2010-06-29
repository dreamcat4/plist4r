
require 'plist4r/config'
require 'plist4r/mixin/ordered_hash'

module Plist4r
  # This class is the Backend broker. The purpose of this object is to manage and handle API
  # calls, passing them over to the appropriate Plist4r backends.
  class Backend
    # The list of known backend API methods. Any combination or subset of API methods
    # can be implemented by an individual backend.
    # @see Plist4r::Backend::Example
    ApiMethods = %w[from_string to_xml to_binary to_gnustep open save]
    
    # A new instance of Backend. A single Backend will exist for the the life of
    # the Plist object. The attribute @plist is set during initialization and 
    # refers back to the plist instance object.
    def initialize plist, *args, &blk
      @plist = plist
    end

    def generic_call backend, method_sym, *args, &blk
      case method_sym

      when :save
        fmt = @plist.file_format || Config[:default_format]
        unless backend.respond_to? "to_#{fmt}"
          return Exception.new "Plist4r: No backend found to handle method :to_#{fmt}. Could not execute method :save on plist #{@plist.inspect}"
        end
        File.open(@plist.filename_path,'w') do |out|
          out << backend.send("to_#{fmt}".to_sym, @plist)
        end
        @plist

      when :open
        @plist.instance_eval "@from_string = File.read(filename_path)"
        fmt = Plist4r.string_detect_format @plist.from_string
        unless backend.respond_to? "from_#{fmt}"
          return Exception.new "Plist4r: No backend found to handle method :from_#{fmt}. Could not execute method :open on plist #{@plist.inspect}"
        end
        backend.send("from_#{fmt}".to_sym, @plist)
        @plist

      when :from_string
        fmt = Plist4r.string_detect_format @plist.from_string
        unless backend.respond_to? "from_#{fmt}"
          return Exception.new "Plist4r: No backend found to handle method :from_#{fmt}. Could not execute method :from_string on plist #{@plist.inspect}"
        end
        backend.send("from_#{fmt}".to_sym, @plist)
        @plist
      end
    end

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
      generic_call_exception = nil

      @plist.backends.each do |b_sym|
        backend = eval "::Plist4r::Backend::#{b_sym.to_s.camelcase}"


        # We can Wrap this call in a Timeout block
        begin
          if backend.respond_to? method_sym
              # puts @plist.inspect
              result = backend.send(method_sym, @plist, *args, &blk)
              # puts "result = #{result.inspect}"
              return result
              # return backend.send(method_sym, @plist, *args, &blk)

          elsif [:open, :save, :from_string].include? method_sym
            result = generic_call backend, method_sym, *args, &blk
            if result.is_a? Exception
              generic_call_exception = result
            else
              return result
            end
            return result unless result.is_a? Exception
          end

        rescue LoadError
          exceptions << $!
        rescue RuntimeError
          exceptions << $!
        rescue SyntaxError
          exceptions << $!
        rescue Exception
          exceptions << $!
        rescue
          exceptions << $!
        end

        if Config[:raise_any_failure] && exceptions.first
          raise exceptions.first
        end
      end
      if exceptions.empty?
        if generic_call_exception
          raise generic_call_exception
        else
          raise "Plist4r: No backend found to handle method #{method_sym.inspect}. Could not execute method #{method_sym.inspect} on plist #{@plist.inspect}"
        end
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


