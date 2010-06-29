
require 'plist4r/mixin/mixlib_config'
require 'plist4r/backend'

# Dir.glob(File.dirname(__FILE__) + "/backend/**/*.rb").each {|b| require File.expand_path b}
Dir.glob(File.dirname(__FILE__) + "/backend/*.rb").each {|b| require File.expand_path b}

module Plist4r

  # The special configuration object, which holds all runtime defaults for individual plist instances.
  # When we create a new {Plist4r::Plist} object, it will inherit these defaults.
  # @example 
  # # Reverse the priority order of backends
  # Plist4r::Config[:backends].reverse!
  # 
  # # Set the default folder from which to load / save plist files
  # Plist4r::Config[:default_path] = "/path/to/my/plist/files"
  # 
  # # Save new plist files as binary plists (when format not known)
  # Plist4r::Config[:default_format] = :binary
  # 
  # # Add custom / application specific Plist Type. You'll also need to subclass {Plist4r::PlistType}
  # Expects class Plist4r::PlistType::MyPlistType to be defined
  # require 'my_plist_type.rb'
  # Plist4r::Config[:types] << "my_plist_type"
  # 
  # # Raise an exception plist keys which dont belong to the selected Plist type
  # Plist4r::Config[:strict_keys] = true
  class Config
    def self.default_backends sym=nil
      case sym
      when :brew
        ["ruby_cocoa"]
      else
        rubycocoa_framework = "/System/Library/Frameworks/RubyCocoa.framework"
        if File.exists? rubycocoa_framework
          ["osx_plist","c_f_property_list","haml","libxml4r","ruby_cocoa"]
        else
          ["c_f_property_list","haml","libxml4r"]
        end
      end
    end

    extend Mixlib::Config

    types [] << Dir.glob(File.dirname(__FILE__) + "/plist_type/**/*.rb").collect {|b| File.basename(b,".rb") }
    types.flatten!.uniq!
    
    backends default_backends
    backends << Dir.glob(File.dirname(__FILE__) + "/backend/*.rb").collect {|b| File.basename(b,".rb") }
    backends.flatten!.uniq!

    strict_keys false
    raise_any_failure false
    deafult_format :xml
    default_path nil
  end
end


