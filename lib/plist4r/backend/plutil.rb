
require 'plist4r/backend_base'

module Plist4r::Backend::Plutil
  # maybe this could be useful as a helper, used by other backends
  class << self
    def convert_file_to_xml
      system "plutil -convert xml1 #{@filename}"
    end

    def convert_file_to_binary
      system "plutil -convert binary1 #{@filename}"
    end
    
    def validate
      system "plutil #{@filename}"
    end
  end
end



