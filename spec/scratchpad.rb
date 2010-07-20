#!/usr/bin/env ruby

require 'rubygems'
require 'lib/plist4r'


def output
  require 'plist4r/backend/test/output'
  o = Plist4r::Backend::Test::Output.new
  puts o
  o.write_html_file
end
# output

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






def select_test
  # Plist4r::Config[:backends].replace ["ruby_cocoa"]
  # Plist4r::Config[:backends].replace ["osx_plist"]

  # puts Plist4r::Config[:backends].inspect
  # Plist4r::Config[:backends].replace ["c_f_property_list", "haml", "libxml4r", "ruby_cocoa"]
  # Plist4r::Config[:backends].replace ["osx_plist", "haml", "libxml4r", "ruby_cocoa"]


  plist = Plist4r.new do
    key1 "value1"
    key2 "value2"

    # bool1 true
    # bool2 false
    # 
    # int1 1
    # int2 2
    # 
    # float1 1.01
    # float2 2.02
  end
  
  # puts plist.to_xml
  # puts ""
  # puts plist.to_hash.hash.inspect
  # puts plist.to_xml
  # puts ""

  # puts plist.backends.inspect
  # plist.save_as "tmp.xml"

  # puts plist.to_binary
  # puts ""
  # plist.file_format :binary
  # plist.save_as "tmp.plist"


  # plist.<< do
  #   select("zkey1", "zkey2")
  # end

  plist[:foo_fighters] = "too old to party?"
  # plist[:foo_fighters] = "too"
  # plist["HuggyBears"] = "are expensive"
  plist["HuggyBears"] = "are expensive party animals"
  # calls to which object?

  

  # plist.unselect("zkey1", "zkey2")

  # plist.select "Zkey1", "Zkey2"

  # plist.select do |k,v|
  #   if v.to_s =~ /value/
  #     true
  #   else
  #     false
  #   end
  # end

  # puts plist.huggy_bearsss.inspect

  plist.plist_type :info

  plist.<< do
    zkey1 "avalue11"
    zkey2 "avalue22"
    c_f_bundle_identifier "some string"
    c_f_bundle_version    "some string"
  
    # c_f_bundle_identifier 1
  end

  
  plist.map do |k,v|
    # [k,v]
    # [k,1]
    puts k.snake_case.to_sym.inspect
    [k.snake_case.to_sym,(v+" and other string")]
  end

  p2 = Plist4r.new do
    some_more_key1 "____________UNDERSCORE___________"
    some_more_key2 "____________UNDERSCORE___________"
    some_more_key3 "____________UNDERSCORE___________"
    some_more_key4 "____________UNDERSCORE___________"
    plist_type :info
  end
  plist.merge! p2

  # plist.delete :some_more_key1

  # p2.plist_type :info



  plist.delete_if do |k,v|
    # v =~ /11/
    # v =~ /slslslsl/
    false
  end

  
  # plist.to_hash.sort

  # plist.unselect "Zkey1", "Zkey2"
  # plist.delete "Zkey1", "Zkey2"
  # plist.select "Zkey1", "Zkey2"
  # plist.clear
  # plist.foo_fighters("zkey1")

  # plist.select do |k,v|
  #   v =~ /UNDER/
  # end


  # puts plist.backends.inspect

  # puts plist.to_hash.inspect
  
  puts plist.to_xml
  puts ""

  # puts plist.to_hash.inspect
  # puts ""

  # plist.from_string s
  # FileUtils.rm("tmp.xml")
  # plist.save_as "tmp.plist"


end
# select_test


# p = Plist4r.open("/Applications/Apps 1/Irssi.app/Contents/Info.plist")
# puts p.plist_type.inspect
# 
# p.open("/Library/LaunchDaemons/com.vmware.launchd.vmware.plist")
# puts p.plist_type.inspect



