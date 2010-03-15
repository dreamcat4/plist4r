
require 'plist4r/mixin/mixlib_config'

class Plist4r::Config
  extend Mixlib::Config

  backends [
    Plist4r::Backend::RubyCocoa,
    Plist4r::Backend::Haml,
    Plist4r::Backend::Libxml4r
  ]

  unsupported_keys true
  raise_any_failure false
  deafult_format :xml
  default_path nil
end

