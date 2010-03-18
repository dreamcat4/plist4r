
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
      when ::ActiveSupport::OrderedHash
        @hash = @orig = hash
      when nil
        @hash
      else
        raise "Must hash be an ::ActiveSupport::OrderedHash"
      end
    end

    def self.valid_keys
      raise "Method not implemented #{method_name.to_sym.inspect}, for class #{self.inspect}"
    end

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
      @hash = ::ActiveSupport::OrderedHash.new
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
      @hash = ::ActiveSupport::OrderedHash.new
    end

    def select_all
      @hash = @orig
    end
  end
end
