#!/usr/bin/env ruby

require 'lib/plist4r'

# puts "Backends = #{::Plist4r::Config[:backends].inspect}"
# Plist4r.new

p = Plist4r.open "plists/mini.xml"

# puts p.inspect
# puts p.to_hash.inspect
# puts p.to_xml

# b = p.to_binary
# puts b.inspect


# p2 = b.to_plist
# puts p2.inspect
# puts p2.to_xml

# puts p2.to_xml
# puts "plist type is"
# puts p2.plist_type.inspect

# p2.unsupported_keys false
# puts p2.unsupported_keys.inspect
# p2.<< do
#   somekey "append"
# end

# puts p2.to_hash.inspect
# puts p2.to_xml






