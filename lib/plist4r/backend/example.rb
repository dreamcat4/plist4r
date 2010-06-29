
require 'plist4r/backend_base'

# An example Plist4r Backend. 
# These examples demonstrate the common convenience methods which are available to your backend.
# Its not necessary to implement all of the API methods in your backend.
# You may selectively implement any single method or method(s).
# 
# In the case of {from_string} and {open}, the source plist format is not known beforehand.
# For those cases you should call {Plist4r.string_detect_format} or {Plist4r.file_detect_format} 
# as appropriate. Then raise an exception for those situation where backend is unable to continue.
# 
# For example, if your backend is only able to load :xml files, then it should raise an exception
# whenever it encounters :binary or :gnustep formatted files. This is intentional.
# By throwing the error, it means the API call can be picked up and passed on to the next available backend.
# 
# @see Plist4r::Backend
module Plist4r::Backend::Example
  class << self

    # Parse a String of plist data and store it into the supplied {Plist4r::Plist}
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to read the string from
    # @return [Plist4r::Plist] the same plist object, but updated to match its from_string
    # @see Plist4r::Plist#from_string
    # @see Plist4r.string_detect_format
    def from_xml plist
      plist_string = plist.from_string
      plist_format = Plist4r.string_detect_format plist.from_string
      unless [:xml].include? plist_format
        raise "#{self} - cant convert string of format #{plist_format}"
      end
      hash = ::Plist4r::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format plist_format
      return plist
    end

    # Parse a String of plist data and store it into the supplied {Plist4r::Plist}
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to read the string from
    # @return [Plist4r::Plist] the same plist object, but updated to match its from_string
    # @see Plist4r::Plist#from_string
    # @see Plist4r.string_detect_format
    def from_binary plist
      plist_string = plist.from_string
      plist_format = Plist4r.string_detect_format plist.from_string
      unless [:binary].include? plist_format
        raise "#{self} - cant convert string of format #{plist_format}"
      end
      hash = ::Plist4r::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format plist_format
      return plist
    end

    # Parse a String of plist data and store it into the supplied {Plist4r::Plist}
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to read the string from
    # @return [Plist4r::Plist] the same plist object, but updated to match its from_string
    # @see Plist4r::Plist#from_string
    # @see Plist4r.string_detect_format
    def from_gnustep plist
      plist_string = plist.from_string
      plist_format = Plist4r.string_detect_format plist.from_string
      unless [:gnustep].include? plist_format
        raise "#{self} - cant convert string of format #{plist_format}"
      end
      hash = ::Plist4r::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format plist_format
      return plist
    end
    
    # Parse a String of plist data and store it into the supplied {Plist4r::Plist}
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to read the string from
    # @return [Plist4r::Plist] the same plist object, but updated to match its from_string
    # @see Plist4r::Plist#from_string
    # @see Plist4r.string_detect_format
    def from_string plist
      plist_string = plist.from_string
      plist_format = Plist4r.string_detect_format plist.from_string
      unless [:supported_fmt1,:supported_fmt2].include? plist_format
        raise "#{self} - cant convert string of format #{plist_format}"
      end
      hash = ::Plist4r::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format plist_format
      return plist
    end

    # Convert a {Plist4r::Plist} into an "xml" formatted plist String
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to convert
    # @return [String] the xml string
    def to_xml plist
      hash = plist.to_hash
      xml_string = "Convert the plists's nested ruby hash into xml here"
      return xml_string
    end

    # Convert a {Plist4r::Plist} into an "binary" formatted plist String
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to convert
    # @return [String] the binary string
    def to_binary plist
      hash = plist.to_hash
      binary_string = "Convert the plists's nested ruby hash into binary format here"
      return binary_string
    end

    # Convert a {Plist4r::Plist} into a "gnustep" formatted plist String
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to convert
    # @return [String] the gnustep string
    def to_gnustep plist
      hash = plist.to_hash
      gnustep_string = "Convert the plists's nested ruby hash into gnustep format here"
      return gnustep_string
    end

    # (Optional) Open a plist file and store the contents into the supplied {Plist4r::Plist}
    # * Please click "View Source" for the example.
    # @param [Plist4r::Plist] plist The plist object to convert
    # @return [String] the gnustep string
    # @see Plist4r.file_detect_format
    def open plist
      filename = plist.filename_path
      file_format = Plist4r.file_detect_format filename
      unless [:supported_fmt1,:supported_fmt2].include? file_format.to_sym
        raise "#{self} - cant load file of format #{file_format}"
      end
      plist_file_as_string = File.read(filename)
      hash = ::Plist4r::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format file_format
      return plist
    end

    # (Optional) Save a plist to file
    # @param [Plist4r::Plist] plist The plist object save. Also to read the filename from
    # @return [Plist4r::Plist] the same plist object, but updated to match the file contents
    # @see Plist4r::Plist#filename_path
    def save plist
      filename = plist.filename_path
      file_format = plist.file_format || Config[:default_format]
      unless [:xml,:binary].include? file_format.to_sym
        raise "#{self} - cant save file of format #{file_format}"
      end
      hash = plist.to_hash
      output_string = String.new
      # convert plist's @hash representation into an output_string, 
      # and formatted to your supported plist file_format(s)
      File.open(filename,'w') do |out|
        out << output_string
      end
      return true
    end
  end
end



