
require 'plist4r/backend_base'

module Plist4r::Backend::Example
  class << self
    def from_string plist
      plist_string = plist.from_string
      plist_format = Plist4r.string_detect_format plist.from_string
      unless [:supported_fmt1,:supported_fmt2].include? plist_format
        raise "#{self} - cant convert string of format #{plist_format}"
      end
      hash = ::ActiveSupport::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format plist_format
      return plist
    end

    def to_xml plist
      hash = plist.to_hash
      xml_string = "Convert the plists's nested ruby hash into xml here"
      return xml_string
    end

    def to_binary
      hash = plist.to_hash
      binary_string = "Convert the plists's nested ruby hash into binary format here"
      return binary_string
    end

    def to_next_step
      hash = plist.to_hash
      next_step_string = "Convert the plists's nested ruby hash into next_step format here"
      return next_step_string
    end

    def open plist
      filename = plist.filename_path
      file_format = Plist4r.file_detect_format filename
      unless [:supported_fmt1,:supported_fmt2].include? file_format
        raise "#{self} - cant load file of format #{file_format}"
      end
      plist_file_as_string = File.read(filename)
      hash = ::ActiveSupport::OrderedHash.new
      # import / convert plist data into ruby ordered hash
      plist.import_hash hash
      plist.file_format file_format
      return plist
    end

    def save plist
      filename = plist.filename_path
      file_format = plist.file_format || Config[:default_format]
      unless [:xml,:binary].include? file_format
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



