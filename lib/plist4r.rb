
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'plist4r/plist'

module Plist4r
  class << self
    def new *args, &blk
      # puts args.inspect
      return Plist.new *args, &blk
    end

    def open filename, *args, &blk
      # puts args.inspect
      p = Plist.new filename, *args, &blk
      p.open
    end
    
    def string_detect_format string
      s = string.strip!
      case s[0,1]
      when "{","("
        :next_step
      when "b"
        if s =~ /^bplist/
          :binary
        else
          nil
        end
      when "<"
        if s =~ /^\<\?xml/ && s =~ /\<\!DOCTYPE plist/
          :xml
        else
          nil
        end
      else
        nil
      end
    end

    def file_detect_format filename
      string_detect_format File.read(filename)
    end
  end
end

class String
  def to_plist
    return ::Plist4r.new(:from_string => self)
  end
end



