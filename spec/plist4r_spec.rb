require 'spec_helper'
require 'plist4r'

describe Plist4r, "#new" do
  before(:each) do
    @plist = Plist4r::Plist.new
    Plist4r::Plist.stub!(:new).and_return(@plist)
  end

  it "should return a Plist4r::Plist object" do
    Plist4r.new.should be_a_kind_of(Plist4r::Plist)
  end

  it "should call Plist4r::Plist.new with the supplied arguments and return @plist" do
    Plist4r::Plist.should_receive(:new).with(:arg1, :arg2, :arg3, :etc)
    @result = Plist4r.new(:arg1, :arg2, :arg3, :etc)
    @result.should == @plist
  end
end

describe Plist4r, "#open" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist.stub!(:open).and_return(@plist)
    Plist4r::Plist.stub!(:new).and_return(@plist)
  end

  it "should return a Plist4r::Plist object" do
    Plist4r.new.should be_a_kind_of(Plist4r::Plist)
  end

  it "should call Plist4r::Plist.new with the supplied arguments and return @plist" do
    Plist4r::Plist.should_receive(:new).with("filename", :arg2, :arg3, :etc)
    Plist4r.open("filename", :arg2, :arg3, :etc).should == @plist
  end

  it "should call @plist.open" do
    @plist.should_receive(:open)
    @result = Plist4r.open("filename", :arg2, :arg3, :etc)
  end
end

describe Plist4r, "#string_detect_format" do
  before(:each) do
    @plist_str_gnustep1 = "  ("
    @plist_str_gnustep2 = "  {"
    @plist_str_xml      = "  <?xml\n<!DOCTYPE plist"
    @plist_str_binary   = "  bplist"
  end

  it "should detect the plist format of the string given" do
    Plist4r::string_detect_format(@plist_str_gnustep1).should == :gnustep
    Plist4r::string_detect_format(@plist_str_gnustep2).should == :gnustep
    Plist4r::string_detect_format(@plist_str_xml).should == :xml
    Plist4r::string_detect_format(@plist_str_binary).should == :binary
  end
end

describe Plist4r, "#file_detect_format" do
  before(:each) do
    File.stub!(:read).with("filename").and_return("string")
    Plist4r.stub!(:string_detect_format).with("string").and_return(:plist_format)
    
  end

  it "should detect the plist format of the file given" do
    Plist4r::file_detect_format("filename").should == :plist_format
  end
end

describe String, "#to_plist" do
  before(:each) do
    @string = "string"
    @plist = Plist4r::Plist.new
    Plist4r.stub!(:new).and_return(@plist)
  end

  it "should run ::Plist4r.new with the supplied string (self) and return the new Plist object" do
    Plist4r.should_receive(:new).with(:from_string => @string)
    @string.to_plist.should == @plist
  end
end




