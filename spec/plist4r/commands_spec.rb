
require 'spec_helper'
require "plist4r/commands"

describe Plist4r::Commands, "#run" do
  before(:each) do
    Plist4r::Config[:args] = { :ruby_lib => true }
    @commands = Plist4r::Commands.new
    @commands.stub(:ruby_lib)
  end
  it "should follow the default calling path" do
    Plist4r::Commands::PriorityOrder.should_receive(:each).and_yield(:ruby_lib)
    Plist4r::Config[:args].should_receive(:[]).with(:ruby_lib).and_return(true)
    Plist4r::Config[:args].should_receive(:keys).and_return([:ruby_lib])
    Plist4r::Config[:args].should_receive(:each).and_yield(:ruby_lib,true)
    @commands.run
  end
end


