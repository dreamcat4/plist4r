require 'plist4r/mixin/mixlib_cli'
require 'plist4r/mixin/mixlib_config'

module Plist4r
  # Defines options for the `plist4r` command line utility
  class CLI
    include Plist4r::Mixlib::CLI

    # The Plist4r CLI Options
    # 
    # @example
    # Usage: bin/plist4r (options)
    #     -b, --brew        Customize for Brew. Use with --ruby-lib.
    #     -d, --dir DIR     The directory to dump files into. Use with --ruby-lib. Defaults to cwd.
    #     -r, --ruby-lib    Convert plist4r gem into a ruby lib, and write to the filesystem. (required)
    #     -h, --help        Show this message
    def self.plist4r_cli_options
      option :ruby_lib, :required => true,
        :short => "-r", :long  => "--ruby-lib", :boolean => true, :default => false, 
        :description => "Convert plist4r gem into a ruby lib, and write to the filesystem."

      option :brew,
        :short => "-b", :long  => "--brew", :boolean => true, :default => false,
        :description => "Customize for Brew. Use with --ruby-lib."

      option :dir,
        :short => "-d DIR", :long  => "--dir DIR", :default => nil,
        :description => "The directory to dump files into. Use with --ruby-lib. Defaults to cwd."

      option :help, :short => "-h", :long => "--help", :boolean => true,
        :description => "Show this message",
        :on => :tail,
        :show_options => true,
        :exit => 0
    end
    plist4r_cli_options
    
    def parse argv=ARGV
      parse_options(argv)
      config
    end

  end
end
