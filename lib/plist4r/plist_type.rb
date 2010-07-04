
require 'plist4r/mixin/data_methods'

module Plist4r
  class PlistType
    include ::Plist4r::DataMethods

    # @param [Plist4r::Plist] plist A pointer referencing back to the plist object
    def initialize plist, *args, &blk
      @plist = plist
      @hash = @orig = plist.to_hash
    end
    
    # Set or return the plist's raw data object
    # @param [Plist4r::OrderedHash] hash Set the hash if not nil
    # @return [Plist4r::OrderedHash] @hash
    def hash hash=nil
      case hash
      when ::Plist4r::OrderedHash
        @hash = @orig = hash
      when nil
        @hash
      else
        raise "Must hash be an ::Plist4r::OrderedHash"
      end
    end

    # Compare a list of foreign keys to the valid keys for this known PlistType.
    # Generate statistics about how many keys (what proportion) match the the key names
    # match this particular PlistType.
    # @param [Array] plist_keys The list of keys to compare to this PlistType
    # @return [Hash] A hash of the match statistics
    # @see Plist4r::Plist#detect_plist_type
    # @example
    #  Plist4r::PlistType::Launchd.match_stat ["ProgramArguments","Sockets","SomeArbitraryKeyName"]
    #  # => { :matches => 2, :ratio => 0.0465116279069767 }
    def self.match_stat plist_keys
      type_keys = self::ValidKeys.values.flatten
      matches = plist_keys & type_keys
      include_ratio = matches.size.to_f / type_keys.size
      return :matches => matches.size, :ratio => include_ratio
    end

    # @return The shortform string, in snake case, a unique name
    # @example
    #  pt = Plist4r::PlistType::Launchd.new
    #  pt.to_s
    #  # => "launchd"
    def to_s
      return @string ||= self.class.to_s.gsub(/.*:/,"").snake_case
    end

    # @return A symbol representation the shortform string, in snake case, a unique name
    # @example
    #  pt = Plist4r::PlistType::Launchd.new
    #  pt.to_sym
    #  # => :launchd
    def to_sym
      return @sym ||= to_s.to_sym
    end
  end

  # Abstract Base class. Represents some nested data structure within an open {Plist4r::Plist}.
  # Typically, a {Plist4r::PlistType} will create and build upon nested instances of this class.
  class ArrayDict
    include ::Plist4r::DataMethods

    # The initializer for this object. Here we set a reference to our raw data structure,
    # which typically is a nested hash within the plist root hash object.
    # Or an Array type structure if index is set.
    # @param [OrderedHash] orig The nested hash object which this structure represents.
    # @param [Fixnum] index The Array index (if representing an Array structure)
    def initialize orig, index=nil, &blk
      @orig = orig
      if index
        @enclosing_block = self.class.to_s.snake_case + "[#{index}]"
        @orig = @orig[index]
      else
        @enclosing_block = self.class.to_s.snake_case
      end
      # puts "@orig = #{@orig.inspect}"
      # puts "@enclosing_block = #{@enclosing_block}"

      @block = blk
      @hash = ::Plist4r::OrderedHash.new
      # puts "@hash = #{@hash}"

      instance_eval(&@block) if @block
      # puts "@hash = #{@hash}"
    end

    # The raw data object
    # @return [Plist4r::OrderedHash] @hash
    def hash
      @hash
    end

    # Select (keep) plist keys from the object.
    # Copy them to the resultant object moving forward.
    # @param [Array, *args] keys The list of Plist Keys to keep
    def select *keys
      keys.flatten.each do |k|
        @hash[k] = @orig[k]
      end
    end

    # Unselect (delete) plist keys from the object.
    # @param [Array, *args] keys The list of Plist Keys to delete
    def unselect *keys
      keys.flatten.each do |k|
        @hash.delete k
      end
    end

    # Unselect (delete) all plist keys from the object.
    def unselect_all
      @hash = ::Plist4r::OrderedHash.new
    end

    # Select (keep) all plist keys from the object.
    # Copy them to the resultant object moving forward.
    def select_all
      @hash = @orig
    end
  end
end
