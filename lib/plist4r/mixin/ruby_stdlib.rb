

class Object
  def method_name
    if  /`(.*)'/.match(caller.first)
      return $1
    end
    nil
  end
end


class String
  def camelcase
    str = self.dup.capitalize.gsub(/[-_.\s]([a-zA-Z0-9])/) { $1.upcase } \
                  .gsub('+', 'x')
  end

  def snake_case
    str = self.dup.gsub(/[A-Z]/) {|s| "_" + s}
    str = str.downcase.sub(/^\_/, "")
  end
end

