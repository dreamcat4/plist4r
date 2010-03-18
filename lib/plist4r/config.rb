
require 'plist4r/mixin/mixlib_config'
require 'plist4r/backend'
Dir.glob(File.dirname(__FILE__) + "/backend/**/*.rb").each {|b| require File.expand_path b}

module Plist4r
  class Config
    extend Mixlib::Config

    types [] << Dir.glob(File.dirname(__FILE__) + "/plist_type/**/*.rb").collect {|b| File.basename(b,".rb") }
    types.flatten!.uniq!
    
    backends ["ruby_cocoa","haml","libxml4r"]
    backends << Dir.glob(File.dirname(__FILE__) + "/backend/**/*.rb").collect {|b| File.basename(b,".rb") }
    backends.flatten!.uniq!

    unsupported_keys true
    raise_any_failure true
    deafult_format :xml
    default_path nil
  end
end


