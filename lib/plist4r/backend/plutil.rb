
require 'plist4r/backend_base'

# This backend does not implement any official Plist4r API methods.
# But can be used to enhance and add functionality to other backends.
# 
# (Mac OSX operating systems only)
module Plist4r::Backend::Plutil
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



