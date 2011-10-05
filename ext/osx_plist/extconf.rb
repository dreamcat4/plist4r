#!/usr/bin/env ruby

require 'mkmf'

if File.exists? "/System/Library/Frameworks/CoreFoundation.framework"
  $LDFLAGS += ' -framework CoreFoundation -undefined suppress -flat_namespace'
  $LIBRUBYARG_SHARED=""
  create_makefile("plist4r/backend/osx_plist/ext/osx_plist")
else
  create_makefile("")
end

