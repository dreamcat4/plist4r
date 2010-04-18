
require 'plist4r/config'
require 'plist4r/mixin/ordered_hash'

module Plist4r
  module DataMethods

    def classes_for_key_type
      {
        :string => [String], 
        :bool => [TrueClass,FalseClass],
        :integer => [Fixnum], 
        :array_of_strings => [Array],
        :hash_of_bools => [Hash],
        :hash => [Hash],
        :bool_or_string_or_array_of_strings => [TrueClass,FalseClass,String,Array]
      }
    end

    def valid_keys
      {}
    end

    def method_missing method_symbol, *args, &blk
      # puts "method_missing: #{method_symbol.inspect}, args: #{args.inspect}"
      # puts "@hash = #{@hash.inspect}"
      valid_keys.each do |key_type, valid_keys_of_those_type|
        if valid_keys_of_those_type.include?(method_symbol.to_s.camelcase)
          puts "key_type = #{key_type}, method_symbol.to_s.camelcase = #{method_symbol.to_s.camelcase}, args = #{args.inspect}"
          # return eval("set_or_return key_type, method_symbol.to_s.camelcase, *args, &blk")
          return set_or_return key_type, method_symbol.to_s.camelcase, *args, &blk
        end
      end
      # puts @plist.inspect
      unless @plist.strict_keys
        key_type = nil
        # return eval("set_or_return key_type, method_symbol.to_s.camelcase, *args, &blk")
        return set_or_return key_type, method_symbol.to_s.camelcase, *args, &blk
      else
        raise "Unrecognized key for class: #{self.class.inspect}. Tried to set_or_return #{method_symbol.inspect}, with: #{args.inspect}"
      end
      # puts "bob"
    end

    def validate_value key_type, key, value
      unless classes_for_key_type[key_type].include? value.class
        raise "Key: #{key}, value: #{value.inspect} is of type #{value.class}. Should be: #{classes_for_key_type[key_type].join ", "}"
      end
      case key_type
      when :array_of_strings, :bool_or_string_or_array_of_strings
        if value.class == Array
          value.each_index do |i|
            unless value[i].class == String
              raise "Element: #{key}[#{i}], value: #{value[i].inspect} is of type #{value[i].class}. Should be: #{classes_for_key_type[:string].join ", "}"
            end
          end
        end
      when :hash_of_bools
        value.each do |k,v|
          unless [TrueClass,FalseClass].include? v.class
            raise "Key: #{key}[#{k}], value: #{v.inspect} is of type #{v.class}. Should be: #{classes_for_key_type[:bool].join ", "}"
          end
        end
      end
    end

    # Set a plist key to a specific value
    # @param [String] The Plist key, as-is
    # @param value A ruby object (Hash, String, Array, etc) to set as the value of the plist key
    # @example
    # plist.set "CFBundleIdentifier", "com.apple.myapp"
    # @see #set_or_return
    def set key, value
      set_or_return nil, key, value
    end

    # Return the value of an existing plist key
    # @return The key's current value, at the time this method was called 
    # @see #set_or_return
    def value_of key
      set_or_return nil, key
    end

    # Set or return a plist key, value pair
    # @param [Symbol, nil] key_type The type of class which the value of the key must belong to. Used for validity check.
    # If key_type is set to nil, then skip value data check
    # @return the key's value
    # @see #validate_value
    def set_or_return key_type, key, value=nil
      # puts "#{method_name}, key_type: #{key_type.inspect}, key: #{key.inspect}, value: #{value.inspect}"
      if value
        validate_value key_type, key, value unless key_type == nil
        @hash[key] = value
      else
        @orig[key]
      end
    end
  end
end




