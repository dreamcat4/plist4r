#!/usr/bin/env ruby

if File.exists? "/System/Library/Frameworks/CoreFoundation.framework"
  require 'mkmf'
  $LDFLAGS += ' -framework CoreFoundation -undefined suppress -flat_namespace'
  $LIBRUBYARG_SHARED=""
  create_makefile("plist4r/backend/osx_plist/ext/osx_plist")
end

