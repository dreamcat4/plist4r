
require 'plist4r/backend_base'
require 'libxml4r'
require 'base64'
require 'date'

# This backend uses Libxml4r / Libxml-Ruby to parse xml plists
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
          hash[k] = Time.parse vnode.inner_xml
        when "data"
          bstr = Base64.decode64(vnode.inner_xml)
          bstr.blob = true
          hash[k] = bstr
        when "array"
          hash[k] = tree_array(vnode)
        when "dict"
          hash[k] = tree_hash(vnode)
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
          array << node.inner_xml.to_f
        when "date"
          array << Time.parse(node.inner_xml)
        when "data"
          bstr = bstr = Base64.decode64(node.inner_xml)
          bstr.blob = true
          array << bstr
        when "array"
          array << tree_array(node)
        when "dict"
          array << tree_hash(node)
        end
      end
      return array
    end

    def parse_plist_xml string
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

    def from_xml plist
      hash = parse_plist_xml plist.from_string
      plist.import_hash hash
      plist.file_format "xml"
      return plist
    end
  end
end


