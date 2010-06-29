
require 'plist4r/mixin/ordered_hash'
require 'plist4r/mixin/ruby_stdlib'
require 'plist4r/plist_cache'
require 'plist4r/plist_type'
Dir.glob(File.dirname(__FILE__) + "/plist_type/**/*.rb").each {|t| require File.expand_path t}
# require 'plist4r/backend'

module Plist4r
  class Plist
    # Recognised keys of the options hash. Passed when instantiating a new Plist Object
    # @see #initialize
    # @see #parse_opts
    OptionsHash = %w[filename path file_format plist_type strict_keys backends from_string]
    # The plist file formats, written as symbols. 
    # @see #file_format
    FileFormats      = %w[binary xml gnustep]

    # Instantiate a new Plist4r::Plist object. We usually set our per-application defaults in {Plist4r::Config} beforehand.
    # 
    # @param [String] filename
    # @param [Hash] options - for advanced usage
    # @example Create new, empty plist
    # Plist4r::Plist.new => #<Plist4r::Plist:0x111546c @file_format=nil, ...>
    # @example Load from file
    # Plist4r::Plist.new("example.plist") => #<Plist4r::Plist:0x1152d1c @file_format="xml", ...>
    # @example Load from string
    # plist_string = "{ \"key1\" = \"value1\"; \"key2\" = \"value2\"; }"
    # Plist4r::Plist.new({ :from_string => plist_string })
    #  => #<Plist4r::Plist:0x11e161c @file_format="xml", ...>
    # @example Advanced options
    # plist_working_dir = `pwd`.strip
    # Plist4r::Plist.new({ :filename => "example.plist", :path => plist_working_dir, :backends => ["libxml4r","ruby_cocoa"]})
    #  => #<Plist4r::Plist:0x111546c @file_format=nil, ...>
    # @return [Plist4r::Plist] The new Plist object
    # @yield An optional block to instance_eval &blk, and apply an edit on creation
    def initialize *args, &blk
      @hash             = ::Plist4r::OrderedHash.new
      plist_type :plist

      @strict_keys = Config[:strict_keys]
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
      
      @plist_cache ||= PlistCache.new self

      edit(&blk) if block_given?
    end

    # Reinitialize plist object from string (overwrites the current contents). Usually called from {Plist#initialize}
    # @example Load from string
    # plist = Plist4r::Plist.new
    #  => #<Plist4r::Plist:0x11e161c @file_format=nil, ...>
    # plist.from_string "{ \"key1\" = \"value1\"; \"key2\" = \"value2\"; }"
    #  => #<Plist4r::Plist:0x11e161c @file_format="gnustep", ...>
    def from_string string=nil
      case string
      when String
        plist_format = ::Plist4r.string_detect_format(string)
        if plist_format
          @from_string = string
          @plist_cache ||= PlistCache.new self
          @plist_cache.from_string
        else
          raise "Unknown plist format for string: #{string}"
        end
      when nil
        @from_string
      else
        raise "Please specify a string of plist data"
      end
    end

    # Set or return the filename attribute of the plist object.
    # @param [String] filename either a relative path or absolute
    # @return The plist's filename
    # @see Plist::Plist#open
    # @see Plist::Plist#save
    # @see Plist::Plist#save_as
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

    # Set or return the path attribute of the plist object. Pre-pended to the plist's filename (if filename is path-relative)
    # @param [String] path (must be an absolute pathname)
    # @return The plist's working path
    # @see Plist::Plist#filename_path
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

    # Set or return the combined filename+path.
    # We use this method in the backends api as the full path to load / save
    # @param [String] filename_path concactenation of both filename and path elements. Also sets the @filename and @path attributes
    # @return the full, expanded path to the plist file
    # @see filename
    # @see path
    def filename_path filename_path=nil
      case filename_path
      when String
        @filename = File.basename filename_path
        @path     = File.dirname  filename_path
      when nil
        File.expand_path @filename, @path    
      else
        raise "Please specify directory + filename"
      end
    end

    # The file format of the plist file we are loading / saving. Written as a symbol.
    # One of {Plist4r::Plist.FileFormats}. Defaults to :xml
    # @param [Symbol, String] file_format Can be :binary, :xml, :gnustep
    # @return The file format associated to this current plist object
    # @see Plist4r::Plist.FileFormats
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

    # Called automatically on plist load / instantiation. This method detects the "Plist Type", 
    # using an algorithm that stats the plist data. The plist types with the highest stat (score) 
    # is chosen to be the object's "Plist Type".
    # @see Plist4r::PlistType
    # @return [true] always
    def detect_plist_type
      stat_m = {}
      stat_r = {}
      Config[:types].each do |t|
        case t
        when String, Symbol
          t = eval "::Plist4r::PlistType::#{t.to_s.camelcase}"
        when Class
          t = t
        else
          raise "Unrecognized plist type: #{t.inspect}"
        end
        t_sym = t.to_s.gsub(/.*:/,"").snake_case.to_sym
        stat_t = t.match_stat @hash.keys

        stat_m.store stat_t[:matches], t_sym
        stat_r.store stat_t[:ratio], t_sym
      end

      most_matches = stat_m.keys.sort.last      
      if most_matches == 0
        plist_type :plist
      elsif stat_m.keys.select{ |m| m == most_matches }.size > 1
        most_matches = stat_r.keys.sort.last          
        if stat_r.keys.select{ |m| m == most_matches }.size > 1
          plist_type :plist
        else
          plist_type stat_r[most_matches]
        end
      else
        plist_type stat_m[most_matches]
      end
      return true
    end

    # Set or return the plist_type of the current object. We can use this to override the automatic type detection.
    # @param [Symbol, String] plist_type. Must be a sublcass of {Plist4r::PlistType}
    # @return The plist's known type, written as a symbol. Will be a sublcass of Plist4r::PlistType. Defaults to :plist
    # @see Plist4r::PlistType
    # @see Plist4r::PlistType::Plist
    def plist_type plist_type=nil
      begin
        case plist_type
        when Class
          unless plist_type.is_a? ::Plist4r::PlistType
            raise "Unrecognized Plist type. Class #{plist_type.inspect} isnt inherited from ::Plist4r::PlistType"
          end
        when Symbol, String
          plist_type = eval "::Plist4r::PlistType::#{plist_type.to_s.camelcase}"
        when nil
          return @plist_type.to_sym
        else
          raise "Please specify a valid plist class name, eg ::Plist4r::PlistType::ClassName, \"class_name\" or :class_name"
        end
        @plist_type = plist_type.new self
        return @plist_type.to_sym
      rescue
        raise "Please specify a valid plist class name, eg ::Plist4r::PlistType::ClassName, \"class_name\" or :class_name"
      end
    end

    # Set or return strict_keys mode
    # @param [true, false] bool If true, then raise an error for any unrecognized keys that dont belong to the {#plist_type}
    # @return The strict_keys setting for this object
    # @see Plist4r::Config
    def strict_keys bool=nil
      case bool
      when true,false
        @strict_keys = bool
      when nil
        @strict_keys
      else
        raise "Please specify true or false to enable / disable this option"
      end
    end

    # An array of strings, symbols or class names which correspond to the active Plist4r::Backends for this object.
    # The priority order in which backends are executed is determined by the in sequence array order.
    # @param [Array <Symbol,String>] A new list of backends to use, in Priority order
    # @return [Array <Symbol>] The plist's backends, each written as a symbol. Must be a sublcass of Plist4r::Backend
    # Defaults to {Plist4r::Config}[:backends]
    # @example
    # plist.backends [:haml, :ruby_cocoa]
    # @see Plist4r::Backend
    # @see Plist4r::Backend::Example
    def backends backends=nil
      case backends
      when Array
        @backends = backends.collect do |b| 
          case b
          when Symbol, String
            eval "::Plist4r::Backend::#{b.to_s.camelcase}"
            b.to_sym
          else
            raise "Backend #{b.inspect} is of unsupported type: #{b.class}"
          end
        end
      when nil
        @backends
      else
        raise "Please specify an array of valid Plist4r Backends"
      end
    end
  
    # Sets up those valid (settable) plist attributes as found the options hash.
    # Normally we dont call this method directly. Called from {#initialize}.
    # @param [Hash <OptionsHash>] opts The options hash, containing keys of {OptionsHash}
    # @see #initialize
    def parse_opts opts
      OptionsHash.each do |opt|
        if opts[opt.to_sym]
          value = opts[opt.to_sym]
          eval "self.#{opt}(value)"
        end
      end
    end

    # Opens a plist file
    # 
    # @param [String] filename plist file to load. Uses the @filename attribute when nil
    # @return [Plist4r::Plist] The loaded Plist object
    # @example Load from file
    # plist = Plist4r.new
    # plist.open("example.plist") => #<Plist4r::Plist:0x1152d1c @file_format="xml", ...>
    def open filename=nil
      @filename = filename if filename
      raise "No filename specified" unless @filename
      @plist_cache.open
    end

    # An alias of {#edit}
    # @example
    #  plist.<< do
    #    set "PFReleaseVersion" "0.1.1"
    #  end
    # @see #edit
    def << *args, &blk
      edit *args, &blk
    end

    # Edit a plist object. Set or return plist keys. Add or remove a selection of keys.
    # Plist key accessor methods are snake-cased versions of the key string.
    # @example Set some arbitrary keys and values via {DataMethods#set}
    #  plist.edit do
    #    set "PFInstance" "4982394823"
    #    set "PFReleaseVersion" "0.1.1"
    #  end
    # @example Retrieve, and modify a plist key, value pair, with {DataMethods#set} and {DataMethods#value_of}
    #  plist.edit do
    #    new_ver = value_of("PFReleaseVersion") + 0.1
    #    set "PFReleaseVersion" new_ver
    #  end
    # @example Modify a Launchd plist, by camel-cased accessor methods
    #  plist.edit do
    #    new_ver = value_of("PFReleaseVersion") + 0.1
    #    set "PFReleaseVersion" new_ver
    #  end
    def edit *args, &blk
      @plist_type.hash @hash
      instance_eval *args, &blk
      detect_plist_type
      @plist_cache.update_checksum
    end
  
    # Pass down unknown method calls to the selected plist_type, to set or return plist keys.
    # All plist data manipulation API is called through method_missing -> PlistType -> DataMethods.
    # @example This will actually call {DataMethods#set}
    # plist.set "CFBundleVersion" "0.1.0"
    # @see Plist4r::DataMethods#method_missing
    # @see #plist_type
    def method_missing method_sym, *args, &blk
      @plist_type.send method_sym, *args, &blk
    end
  
    # Backend method to set or return all new plist data resulting from a backend API. Used in load operations.
    # @param [Plist4r::OrderedHash, nil] hash sets the new root object. Replaces all previous plist data.
    # @return If no argument given, then clears all plist data, returning the new @hash root object
    # @see Backend::Example
    def import_hash hash=nil
      case hash
      when ::Plist4r::OrderedHash
        @hash = hash
      when nil
        @hash = ::Plist4r::OrderedHash.new
      else
        raise "Please use ::Plist4r::OrderedHash.new for your hashes"
      end
    end
  
    # The primary storage object for plist data
    # 
    # @return [::Plist4r::OrderedHash] Nested hash of ruby objects. The raw Plist data
    # @see ::Plist4r::OrderedHash
    # @example 
    # plist = "{ \"key1\" = \"value1\"; \"key2\" = \"value2\"; }".to_plist
    # plist.to_hash => {"key1"=>"value1", "key2"=>"value2"}
    def to_hash
      @hash
    end

    # Calls out to the plist cache
    # 
    # @return [String] An xml string which represents the entire plist, as would be the plist xml file
    # @example 
    # plist = "{ \"key1\" = \"value1\"; \"key2\" = \"value2\"; }".to_plist
    # plist.to_xml 
    #  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>key1</key>\n\t<string>value1</string>\n\t<key>key2</key>\n\t<string>value2</string>\n</dict>\n</plist>"
    def to_xml
      @plist_cache.to_xml
    end
  
    # @example 
    # plist = "{ \"key1\" = \"value1\"; \"key2\" = \"value2\"; }".to_plist
    # plist.to_binary
    #  => "bplist00\322\001\002\003\004Tkey2Tkey1Vvalue2Vvalue1\b\r\022\027\036\000\000\000\000\000\000\001\001\000\000\000\000\000\000\000\005\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000%"
    def to_binary
      @plist_cache.to_binary
    end

    # @todo Needs a backend
    #   We are missing a backend for writing out :gnustep strings and saving :gnustep files to disk
    def to_gnustep
      @plist_cache.to_gnustep
    end
  
    # Save plist to #filename
    # @raise [RuntimeError] if the {#filename} attribute is nil
    # @see #filename
    # @see #path
    def save
      raise "No filename specified" unless @filename
      @plist_cache.save
    end
  
    # Save the plist under a new filename
    # @param [String] filename The new file name to save as. If a relative path, will be concactenated to plist.path
    # @see #save
    def save_as filename
      @filename = filename
      save
    end
  end
end

module Plist4r
  # @private
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
      @hash = @orig = ::Plist4r::OrderedHash.new

      instance_eval(&@block) if @block
    end

    def override_plist_keys?
      return true unless @label == @filename.match(/^.*\/(.*)\.plist$/)[1]
      vars = self.instance_variables - ["@filename","@label","@shortname","@block","@hash","@obj"]
      return true unless vars.empty?
    end

    def finalize
      if File.exists? @filename
        if override_plist_keys?
          # @hash = @obj = ::LibxmlLaunchdPlistParser.new(@filename).plist_struct
          # eval_plist_block(&@block) if @block
          # write_plist
        end
      else
        # write_plist
      end
    end  
  end
end


