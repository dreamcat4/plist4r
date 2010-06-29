
require 'plist4r/backend_base'

# This backend uses Libxml4r / Libxml-Ruby to *read* xml plists
# @author Dreamcat4 (dreamcat4@gmail.com)
module Plist4r::Backend::Libxml4r
  class << self
    def tree_hash n
      hash = ::Plist4r::OrderedHash.new
      n_xml_keys = n.nodes["key"]
      n_xml_keys.each do |n|
        k = n.inner_xml
        vnode = n.next
        case vnode.name
        when "true", "false"
          hash[k] = eval(vnode.name)
        when "string"
          hash[k] = vnode.inner_xml
        when "integer"
          hash[k] = vnode.inner_xml.to_i
        when "real"
          hash[k] = vnode.inner_xml.to_f
        when "date"
          require 'date'
          hash[k] = Time.parse vnode.inner_xml
        when "data"
          require 'base64'
          data = Base64.decode64(vnode.inner_xml.gsub(/\s+/, ''))
          obj = nil
          begin
            obj = Marshal.load(data)
            hash[k] = obj
          rescue Exception => e
            io = StringIO.new
            io.write data
            io.rewind
            hash[k] = io
          end
        when "array"
          hash[k] = tree_array(vnode)
        when "dict"
          hash[k] = tree_hash(vnode)
        else
          raise "Unsupported / not recognized plist key: #{vnode.name}"
        end
      end
      return hash
    end

    def tree_array n
      array = []
      n.children.each do |node|
        case node.name
        when "true", "false"
          array << eval(node.name)
        when "string"
          array << node.inner_xml
        when "integer"
          array << node.inner_xml.to_i
        when "real"
          hash[k] = vnode.inner_xml.to_f
        when "date"
          require 'date'
          hash[k] = Time.parse vnode.inner_xml
        when "data"
          require 'base64'
          data = Base64.decode64(vnode.inner_xml.gsub(/\s+/, ''))
          obj = nil
          begin
            obj = Marshal.load(data)
            hash[k] = obj
          rescue Exception => e
            io = StringIO.new
            io.write data
            io.rewind
            hash[k] = io
          end
        when "array"
          array << tree_array(node)
        when "dict"
          array << tree_hash(node)
        else
          raise "Unsupported / not recognized plist key: #{vnode.name}"
        end
      end
      return array
    end

    def parse_plist_xml string
      require 'rubygems'
      require 'libxml4r'
      ::LibXML::XML.default_keep_blanks = false
      doc = string.to_xmldoc
      doc.strip!

      root = doc.node["/plist/dict"]
      ordered_hash = nil
      if root
        ordered_hash = tree_hash root
      else
        root = doc.node["/plist/array"]
        if root
          ordered_hash = ::Plist4r::OrderedHash.new
          ordered_hash["Array"] = tree_array root
        end
      end
      ordered_hash
    end

    # def from_xml plist, string
    #   # plist_format = Plist4r.string_detect_format string
    #   # raise "#{self} - cant convert string of format #{plist_format}" unless plist_format == :xml
    #   hash = parse_plist_xml string
    #   plist.import_hash hash
    #   plist.file_format plist_format
    #   return plist
    # end

    def from_xml plist
      hash = parse_plist_xml plist.from_string
      plist.import_hash hash
      plist.file_format "xml"
      return plist
    end
  end
end


