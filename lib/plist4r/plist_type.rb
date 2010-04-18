
require 'plist4r/mixin/data_methods'

module Plist4r
  class PlistType
    include ::Plist4r::DataMethods

    def initialize plist, *args, &blk
      @plist = plist
      @hash = @orig = plist.to_hash
    end
    
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

    def self.valid_keys
      raise "Method not implemented #{method_name.to_sym.inspect}, for class #{self.inspect}"
    end

    # A Hash Array of the supported plist keys for this type. These are only those plist keys 
    # recognized as belonging to a specific plist datatype. Used in validation, part of DataMethods.
    # We usually overload this method in subclasses of {Plist4r::PlistType}.
    # @example
    #  class Plist4r::PlistType::MyPlistType < PlistType
    #      def self.valid_keys
    #     {
    #        :string => %w[PlistKeyS1 PlistKeyS2 ...],
    #        :bool => %w[PlistKeyB1 PlistKeyB2 ...],
    #        :integer => %w[PlistKeyI1 PlistKeyI2 ...],
    #        :method_defined => %w[CustomPlistKey1 CustomPlistKey2 ...]
    #      }
    #    end
    #  end
    #
    #  plist.plist_type :my_plist_type
    #  plist.plist_key_s1 "some string"
    #  plist.plist_key_b1 true
    #  plist.plist_key_i1 08
    #  plist.custom_plist_key1 MyClass.new(opts)
    # 
    def valid_keys
      self.class.valid_keys
    end

    def self.match_stat plist_keys
      type_keys = valid_keys.values.flatten
      matches = plist_keys & type_keys
      include_ratio = matches.size.to_f / type_keys.size
      return :matches => matches.size, :ratio => include_ratio
    end

    def to_s
      return @string ||= self.class.to_s.gsub(/.*:/,"").snake_case
    end

    def to_sym
      return @sym ||= to_s.to_sym
    end
  end

  class ArrayDict
    include ::Plist4r::DataMethods

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

    def hash
      @hash
    end

    def select *keys
      keys.each do |k|
        @hash[k] = @orig[k]
      end
    end

    def unselect *keys
      keys.each do |k|
        @hash.delete k
      end
    end

    def unselect_all
      @hash = ::Plist4r::OrderedHash.new
    end

    def select_all
      @hash = @orig
    end
  end
end
