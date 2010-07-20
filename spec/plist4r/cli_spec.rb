
require 'spec_helper'
require "plist4r/cli"

describe Plist4r::CLI, "#plist4r_cli_options" do
  it "should call option to define cli options" do
    Plist4r::CLI.should_receive(:option).at_least(:once)
    Plist4r::CLI.plist4r_cli_options
  end
end

describe Plist4r::CLI, "#parse" do
  before(:each) do
    @cli = Plist4r::CLI.new
    @cli.stub(:parse_options)
    @cli.stub(:config)
    @argv = ["arg1","arg2","etc..."]
  end

  it "should follow the default calling path" do
    @cli.should_receive(:parse_options).with(@argv)
    @cli.should_receive(:config)
    @cli.parse(@argv)
  end
end