
require 'spec_helper'
require "plist4r/application"

describe Plist4r::Application, "#initialize" do
  before(:each) do
    @cli = Plist4r::CLI.new
    Plist4r::CLI.stub(:new).and_return(@cli)
    @mixlib_cli_args = {}
    @cli.stub(:parse).and_return(@mixlib_cli_args)

    @commands = Plist4r::Commands.new
    Plist4r::Commands.stub(:new).and_return(@commands)

    @application = Plist4r::Application.new
  end

  it "should set Plist4r::Config[:args] to a Hash" do
    Plist4r::Config[:args].should be_a_kind_of(Hash)
  end

  it "should set @cli to a Plist4r::CLI object" do
    @application.instance_eval { @cli }.should be_a_kind_of(Plist4r::CLI)
  end
  
  it "should set @commands to a Plist4r::Commands object" do
    @application.instance_eval { @commands }.should be_a_kind_of(Plist4r::Commands)
  end

  it "should follow the default calling path" do
    @cli.should_receive(:parse)
    Plist4r::Config.should_receive(:[]=).with(:args,@mixlib_cli_args)
    @commands.should_receive(:run)
    @application.instance_eval { initialize }
  end
end

