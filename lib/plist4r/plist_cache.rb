
require 'plist4r/backend'
module Plist4r
  class PlistCache
    def initialize plist, *args, &blk
      @plist = plist
      @backend = Backend.new plist, *args, &blk
    end
  
    def checksum
      @plist.to_hash.hash
    end
  
    def last_checksum
      @checksum
    end

    def update_checksum
      @checksum = @plist.to_hash.hash
    end

    def needs_update
      checksum != last_checksum
    end

    def from_string
      @backend.call :from_string
      update_checksum
      @plist.detect_plist_type
      @plist
    end

    def to_xml
      if needs_update || @xml.nil?
        # puts "needs update"
        # is there still a caching error here?
        update_checksum
        @xml = @backend.call :to_xml
      else
        @xml
      end
    end
  
    def to_binary
      if needs_update || @binary.nil?
        update_checksum
        @binary = @backend.call :to_binary
      else
        @binary
      end
    end

    def to_gnustep
      if needs_update || @gnustep.nil?
        update_checksum
        @gnustep = @backend.call :to_gnustep
      else
        @gnustep
      end
    end
  
    def open
      @backend.call :open
      update_checksum
      @plist.detect_plist_type
      @plist
    end
  
    def save
      puts "saving..."
      # if needs_update
        update_checksum
        @backend.call :save
      # else
        puts "not need saving?"
        true
      # end
    end
  end
end
