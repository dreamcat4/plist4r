#!/usr/bin/env ruby

require 'lib/plist4r'


# Plist4r.new

p = Plist4r.open "plists/foofoo.xml"

# puts p.inspect
# puts p.to_hash.inspect

puts p.to_xml

