#!/usr/bin/env ruby

require 'rubygems'
require 'lib/plist4r'


def output
  require 'plist4r/backend/test/output'
  o = Plist4r::Backend::Test::Output.new
  puts o
  o.write_html_file
end
output

def start_irb
  # cd tmp/plist4r
  # irb -r 'rubygems' -r 'lib/plist4r'
end


# convert DateTime to Time
# require 'time'
# require 'date'
# 
# t = Time.now
# d = DateTime.now
# 
# dd = DateTime.parse(t.to_s)
# tt = Time.parse(d.to_s)



def general_test
  Plist4r.new

  Plist4r::Config[:raise_any_failure] = true
  # Plist4r::Config[:backends].replace ["haml","libxml4r","ruby_cocoa"]
  # Plist4r::Config[:backends].replace ["osx_plist"]
  Plist4r::Config[:backends].replace ["c_f_property_list"]
  puts `pwd`
  Plist4r::Config[:default_path] = "spec/data"
  # puts Plist4r::Config[:default_path]
  p = Plist4r.open "manual/array_mini.xml"
  p = Plist4r.open "manual/example_medium_launchd.xml"
  # p = Plist4r.open "manual/example_big_binary.plist"

  # Plist4r.new do
  # end

  # puts p.inspect
  puts p.to_hash.inspect
  puts p.to_xml

  b = p.to_binary
  puts b.inspect


  p2 = b.to_plist
  # puts p2.inspect
  puts p2.to_xml

  # puts p2.to_xml
  # puts "plist type is"
  # puts p2.plist_type.inspect

  # p2.strict_keys false
  # puts p2.strict_keys.inspect
  # p2.<< do
  #   somekey "append"
  # end

  # puts p2.to_hash.inspect
  # puts p2.to_xml
end
# general_test





