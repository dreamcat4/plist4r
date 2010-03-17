
require 'plist4r/mixin/ordered_hash'
require 'plist4r/mixin/ruby_stdlib'
require 'plist4r/plist_cache'
require 'plist4r/plist_type'
Dir.glob(File.dirname(__FILE__) + "/plist_type/**/*.rb").each {|t| require File.expand_path t}
require 'plist4r/backend'

module Plist4r
  class Plist
    PlistOptionsHash = %w[from_string filename path file_format plist_type unsupported_keys backends]
    FileFormats      = %w[binary xml next_step]
  
    def initialize *args, &blk
      @hash             = ::ActiveSupport::OrderedHash.new
      # @plist_type       = plist_type PlistType::Plist
      @unsupported_keys = Config[:unsupported_keys]
      @backends         = Config[:backends]
      @from_string      = nil
      @filename         = nil
      @file_format      = nil
      @path             = Config[:default_path]

      case args.first
      when Hash
        parse_opts args.first

      when String, Symbol
        @filename = args.first.to_s
      when nil
      else
        raise "Unrecognized first argument: #{args.first.inspect}"
      end
      
      @plist_cache = PlistCache.new self
    end

    def from_string string=nil
      case string
      when String
        plist_format = ::Plist4r.string_detect_format string
        if plist_format
          eval "@plist_cache.from_#{format}, string"
        else
          raise "Unknown plist format for string: #{string}"
        end
        @from_string = string
      when nil
        @from_string
      else
        raise "Please specify a string of plist data"
      end
    end

    def filename filename=nil
      case filename
      when String
        @filename = filename
      when nil
        @filename
      else
        raise "Please specify a filename"
      end
    end

    def path path=nil
      case path
      when String
        @path = path
      when nil
        @path
      else
        raise "Please specify a directory"
      end
    end

    def filename_path filename_path=nil
      case path
      when String
        @filename = File.basename filename_path
        @path     = File.dirname  filename_path
      when nil
        File.expand_path @filename, @path    
      else
        raise "Please specify directory + filename"
      end
    end

    def file_format file_format=nil
      case file_format
      when Symbol, String
        if FileFormats.include? file_format.to_s.snake_case
          @file_format = file_format.to_s.snake_case
        else
          raise "Unrecognized plist file format: \"#{file_format.inspect}\". Please specify a valid plist file format, #{FileFormats.inspect}"
        end
      when nil
        @file_format
      else
        raise "Please specify a valid plist file format, #{FileFormats.inspect}"
      end
    end

    def plist_type plist_type=nil
      begin
        case plist_type
        when Class
          @plist_type = PlistType::Plist.new :hash => @hash
        when Symbol, String
          eval "pt_klass = PlistType::#{plist_type.to_s.camelcase}"
          @plist_type = pt_klass.new :hash => @hash
        when nil
          @plist_type
        else
          raise "Please specify a valid plist class name, eg ::Plist4r::PlistType::ClassName, \"class_name\" or :class_name"
        end
      rescue
        raise "Please specify a valid plist class name, eg ::Plist4r::PlistType::ClassName, \"class_name\" or :class_name"
      end
    end
  
    def unsupported_keys bool
      case bool
      when true,false
        @unsupported_keys = bool
      when nil
        @unsupported_keys
      else
        raise "Please specify true or false to enable / disable this option"
      end
    end
  
    def backends backends=nil
      case backends
      when Array
        @backends = backends
      when nil
        @backends
      else
        raise "Please specify an array of valid Plist4r Backends"
      end
    end
  
    def parse_opts opts
      PlistOptionsHash.each do |opt|
        eval "@#{opt} = #{opts[opt.to_sym]}" if opts[opt.to_sym]
      end
    end

    def open filename=nil
      @filename = filename if filename
      raise "No filename specified" unless @filename
      # @hash = @plist_cache.open
      @plist_cache.open
    end

    def << *args, &blk
      edit *args, &blk
    end

    def edit *args, &blk
      instance_eval &blk
    end
  
    def method_missing method_sym, *args, &blk
      @plist_type.send method_sym, *args, &blk
    end
  
    def import_hash hash=nil
      case hash
      when ::ActiveSupport::OrderedHash
        @hash = hash
      when nil
        @hash = ::ActiveSupport::OrderedHash.new
      else
        raise "Please use ::ActiveSupport::OrderedHash.new for your hashes"
      end
    end
  
    def to_hash
      @hash
    end
  
    def to_xml
      @plist_cache.to_xml
    end
  
    def to_binary
      @plist_cache.to_binary
    end

    def to_next_step
      @plist_cache.to_next_step
    end
  
    def save
      raise "No filename specified" unless @filename
      @plist_cache.save
    end
  
    def save_as filename
      @filename = filename
      save
    end
  end
end

module Plist4r
  class OldPlist
  
    def initialize path_prefix, plist_str, &blk
      plist_str << ".plist" unless plist_str =~ /\.plist$/

      @filename = nil
      if plist_str =~ /^\//
        @filename = plist_str
      else
        @filename = "#{path_prefix}/#{plist_str}"
      end
    
      @label = @filename.match(/^.*\/(.*)\.plist$/)[1]
      @shortname = @filename.match(/^.*\.(.*)$/)[1]

      @block = blk
      @hash = @orig = ::ActiveSupport::OrderedHash.new

      instance_eval(&@block) if @block
    end

    def finalize
      if File.exists? @filename
        if override_plist_keys?
          # @hash = @obj = ::LibxmlLaunchdPlistParser.new(@filename).plist_struct
          # eval_plist_block(&@block) if @block
          write_plist
        end
      else
        write_plist
      end
      validate
    end
  
    def override_plist_keys?
      return true unless @label == @filename.match(/^.*\/(.*)\.plist$/)[1]
      vars = self.instance_variables - ["@filename","@label","@shortname","@block","@hash","@obj"]
      return true unless vars.empty?
    end

    def write_plist
      require 'haml'
      engine = Haml::Engine.new File.read("launchd_plist.haml")
      rendered_xml_output = engine.render self
      File.open(@filename,'w') do |o|
        o << rendered_xml_output
      end

    end

    def validate
      system "/usr/bin/plutil #{@filename}"
    end
  end
end
