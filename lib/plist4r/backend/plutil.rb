
require 'plist4r/backend_base'

module Plist4r::Backend::Plutil
  # maybe this should be a helper, included by other backends
  class << self
    # use tempfile to write out data
    # convert it into target format

    # plutil -convert xml1 @filename
    # plutil -convert binary1 @filename
    # next step is not supported

    # def validate
    #   system "plutil #{@filename}"
    # end
  end
end



