
require 'plist4r/backend_base'
require 'plist4r/backend/c_f_property_list/rbCFPropertyList'

# C.Kruse's CFPropertyList is an independant Ruby Library and written natively in Ruby.
# Supports binary and xml format property lists. With a dependency on libxml-ruby
# for reading/writing the xml plists.
# @author Christian Kruse (http://github.com/ckruse)
module Plist4r::Backend::CFPropertyList
  class << self

    def from_string plist
      cf_plist = Plist4r::Backend::CFPropertyList::List.new
      cf_plist.load_str(plist.from_string)
      ruby_object = Plist4r::Backend::CFPropertyList.native_types(cf_plist.value)

      hash_obj = nil
      if ruby_object.is_a? Hash
        hash_obj = ruby_object

      elsif ruby_object
        hash_obj = { ruby_object.class.to_s => ruby_object }

      else
        raise "Conversion tp plist object failed"
      end

      hash = ::Plist4r::OrderedHash.new
      hash.replace hash_obj
      plist.import_hash hash

      return plist
    end

    def from_xml plist
      from_string plist
    end

    def from_binary plist
      from_string plist
    end

    def to_xml plist
      cf_plist = Plist4r::Backend::CFPropertyList::List.new
      cf_plist.value = Plist4r::Backend::CFPropertyList.guess(plist.to_hash)
      return cf_plist.to_str(Plist4r::Backend::CFPropertyList::List::FORMAT_XML)
    end

    def to_binary plist
      cf_plist = Plist4r::Backend::CFPropertyList::List.new
      cf_plist.value = Plist4r::Backend::CFPropertyList.guess(plist.to_hash)
      return cf_plist.to_str(Plist4r::Backend::CFPropertyList::List::FORMAT_BINARY)
    end

  end
end



