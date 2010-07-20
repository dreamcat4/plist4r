require 'plist4r/config'
require 'plist4r/cli'
require 'plist4r/commands'

module Plist4r
  # The Plist4r Application Object. Instantiated for command-line mode
  # @see Plist4r::CLI
  class Application

    def initialize *args, &blk
      @cli = Plist4r::CLI.new
      Plist4r::Config[:args] = @cli.parse

      @commands = Plist4r::Commands.new
      @commands.run
    end
  end
end
