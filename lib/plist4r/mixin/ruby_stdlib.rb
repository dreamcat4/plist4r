
# These methods should all be nemespaced to ::Plist4r
# we don't want to upset anyone else's code

class Object
  # The method name
  # @return [String] The name of the current method
  # @example
  #  def my_method
  #    method_name
  #  end
  # my_method => "my_method"
  def method_name
    if  /`(.*)'/.match(caller.first)
      return $1
    end
    nil
  end
end

class String
  # A Camel-ized string. The reverse of {#snake_case}
  # @example
  #  "my_plist_key".camelcase => "MyPlistKey"
  def camelcase
    str = self.dup.capitalize.gsub(/[-_.\s]([a-zA-Z0-9])/) { $1.upcase } \
                  .gsub('+', 'x')
  end

  # A snake-cased string. The reverse of {#camelcase}
  # @example
  #  "MyPlistKey".snake_case => "my_plist_key"
  def snake_case
    str = self.dup.gsub(/[A-Z]/) {|s| "_" + s}
    str = str.downcase.sub(/^\_/, "")
  end
end

