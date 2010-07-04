
require 'plist4r/config'
require 'plist4r/mixin/ordered_hash'

module Plist4r
  module DataMethods

    # Return those Class constants which the value of a Plist Key must conform to.
    # This is class-based data validation.
    ClassesForKeyType = 
    {
      :string => [String], 
      :bool => [TrueClass,FalseClass],
      :bool_or_string => [TrueClass,FalseClass,String],
      :integer => [Fixnum], 
      :array_of_strings => [Array],
      :array_of_hashes => [Array],
      :array => [Array],
      :array_or_integer => [Array,Fixnum],
      :array_or_hash => [Array, Hash],
      :hash_of_bools => [Hash],
      :hash_of_strings => [Hash],
      :hash_of_arrays => [Hash],
      :hash_of_arrays_of_strings => [Hash],
      :hash => [Hash],
      :bool_or_string_or_array_of_strings => [TrueClass,FalseClass,String,Array]
    }

    # A Hash Array of the supported plist keys for this type. These are only those plist keys 
    # recognized as belonging to a specific plist datatype. Used in validation, part of DataMethods.
    # We usually overload this method in subclasses. To see how to use these Plist Keys, go to {file:PlistKeyNames}
    # @example
    #  class Plist4r::PlistType::MyPlistType < PlistType
    #    ValidKeys =
    #    {
    #       :string => %w[PlistKeyS1 PlistKeyS2 ...],
    #       :bool => %w[PlistKeyB1 PlistKeyB2 ...],
    #       :integer => %w[PlistKeyI1 PlistKeyI2 ...],
    #       :method_defined => %w[CustomPlistKey1 CustomPlistKey2 ...]
    #    }
    #  end
    #
    #  plist.plist_type :my_plist_type
    #  plist.plist_key_s1 "some string"
    #  plist.plist_key_b1 true
    #  plist.plist_key_i1 08
    #  plist.custom_plist_key1 MyClass.new(opts)
    # @see ClassesForKeyType
    ValidKeys = {}

    # A template for creating new plist types
    ValidKeysTemplate =
    {
      :string => %w[
        
        ],
      :bool => %w[
        
        ],
      :integer => %w[
        
        ],
      :array_of_strings => %w[
        
        ],
      :array_of_hashes => %w[
        
        ],
      :array => %w[
        
        ],
      :hash_of_bools => %w[
        
        ],
      :hash_of_strings => %w[
        
        ],
      :hash_of_arrays => %w[
        
        ],
      :hash_of_arrays_of_strings => %w[
        
        ],
      :hash => %w[
        
        ],
      :could_be_method_defined   => %w[
        
        ]
    }


    # Call {#set_or_return} with the appropriate arguments. If {Plist4r::Plist#strict_keys} is enabled, 
    # then raise an error on any unrecognised Plist Keys.
    def method_missing method_symbol, *args, &blk
      # puts "method_missing: #{method_symbol.inspect}, args: #{args.inspect}"
      # puts "@hash = #{@hash.inspect}"
      ValidKeys.each do |key_type, valid_keys_of_those_type|
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

    # This method is called when setting a value to a plist key. (or some value within a nested plist sub-structure).
    # @param [Symbol] key_type This Symbol is resolved to a class constant, by looking it up in {ClassesForKeyType}
    # @param value The value to validate. We just check that the value conforms to key_type.
    # @see ClassesForKeyType
    # @raise Class mistmatch
    # @example
    #  plist.validate_value :string, "CFBundleIdentifier", "com.apple.myapp"
    #  # => Okay, no error raised
    #  plist.validate_value :string, "CFBundleIdentifier", ["com.apple.myapp"]
    #  # => Raises Class mismatch. Value is of type Array, should be String
    def validate_value key_type, key, value
      unless ClassesForKeyType[key_type].include? value.class
        raise "Key: #{key}, value: #{value.inspect} is of type #{value.class}. Should be: #{ClassesForKeyType[key_type].join ", "}"
      end
      case key_type
      when :array_of_strings, :bool_or_string_or_array_of_strings
        if value.class == Array
          value.each_index do |i|
            unless value[i].class == String
              raise "Element: #{key}[#{i}], value: #{value[i].inspect} is of type #{value[i].class}. Should be: #{ClassesForKeyType[:string].join ", "}"
            end
          end
        end
      when :array_of_hashes
        value.each_index do |i|
          unless value[i].class == Hash
            raise "Element: #{key}[#{i}], value: #{value[i].inspect} is of type #{value[i].class}. Should be: #{ClassesForKeyType[:hash].join ", "}"
          end
        end
      when :hash_of_bools
        value.each do |k,v|
          unless [TrueClass,FalseClass].include? v.class
            raise "Key: #{key}[#{k}], value: #{v.inspect} is of type #{v.class}. Should be: #{ClassesForKeyType[:bool].join ", "}"
          end
        end
      when :hash_of_strings
        value.each do |k,v|
          unless v.class == String
            raise "Key: #{key}[#{k}], value: #{v.inspect} is of type #{v.class}. Should be: #{ClassesForKeyType[:string].join ", "}"
          end
        end
      when :hash_of_arrays
        value.each do |k,v|
          unless v.class == Array
            raise "Key: #{key}[#{k}], value: #{v.inspect} is of type #{v.class}. Should be: #{ClassesForKeyType[:array].join ", "}"
          end
        end
      when :hash_of_arrays_of_strings
        value.each do |k,v|
          unless v.class == Array
            raise "Key: #{key}[#{k}], value: #{v.inspect} is of type #{v.class}. Should be: #{ClassesForKeyType[:array].join ", "}"
          end
          v.each_index do |i|
            unless v[i].class == String
              raise "Element: #{key}[#{k}][#{i}], value: #{v[i].inspect} is of type #{v[i].class}. Should be: #{ClassesForKeyType[:string].join ", "}"
            end
          end
        end
      end
    end

    # Set a plist key to a specific value
    # @param [String] The Plist key, as-is
    # @param value A ruby object (Hash, String, Array, etc) to set as the value of the plist key
    # @see #set_or_return
    # @example
    #  plist.set "CFBundleIdentifier", "com.apple.myapp"
    def set key, value
      set_or_return nil, key, value
    end

    # Return the value of an existing plist key
    # @return The key's current value, at the time this method was called 
    # @see #set_or_return
    # @example
    #  plist.value_of "CFBundleIdentifier"
    #  # => "com.apple.myapp"
    def value_of key
      set_or_return nil, key
    end

    # Set or return a plist key, value pair
    # @param [Symbol, nil] key_type The type of class which the value of the key must belong to. Used for validity check.
    # If key_type is set to nil, then skip value data check
    # @return the key's value
    # @see #validate_value
    # @example
    #  plist.set_or_return :string, "CFBundleIdentifier", "com.apple.myapp"
    #  
    #  plist.set_or_return nil, "SomeUnknownKey", [[0],1,2,{ 3 => true}]
    #  # Skips validation
    def set_or_return key_type, key, value=nil
      # puts "#{method_name}, key_type: #{key_type.inspect}, key: #{key.inspect}, value: #{value.inspect}"
      case value
      when nil
        @orig[key]
      else
        validate_value key_type, key, value unless key_type == nil
        @hash[key] = value
      end
    end
  end
end
