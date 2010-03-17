
require 'plist4r/mixin/mixlib_config'
require 'plist4r/backend'
Dir.glob(File.dirname(__FILE__) + "/backend/**/*.rb").each {|b| require File.expand_path b}

module Plist4r
  class Config
    extend Mixlib::Config

    backends [
      ::Plist4r::Backend::RubyCocoa,
      ::Plist4r::Backend::Haml,
      ::Plist4r::Backend::Libxml4r
    ]

    unsupported_keys true
    raise_any_failure false
    deafult_format :xml
    default_path nil
  end
end
