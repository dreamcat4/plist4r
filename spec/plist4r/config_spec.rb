
require 'spec_helper'

describe Plist4r::Config, "#default_backends" do
  describe "when the supplied sym is :brew" do
    it "should return the RubyCocoa backend" do
      Plist4r::Config.default_backends(:brew).should == ["ruby_cocoa"] 
    end
  end

  describe "when the supplied sym is nil" do
    
    describe "when there is no File at the path CoreFoundationFramework" do
      it "should return DefaultBackendsAny" do
        File.stub(:exists?).with(Plist4r::Config::CoreFoundationFramework).and_return(false)
        Plist4r::Config.default_backends.should == Plist4r::Config::DefaultBackendsAny
      end
    end

    describe "when there is a File at the path CoreFoundationFramework" do
      describe "when there is a File at the path RubycocoaFramework" do
        it "should return DefaultBackendsOsx + the RubyCocoa backend" do
          File.stub(:exists?).with(Plist4r::Config::CoreFoundationFramework).and_return(true)
          File.stub(:exists?).with(Plist4r::Config::RubycocoaFramework).and_return(true)
          Plist4r::Config.default_backends.should == Plist4r::Config::DefaultBackendsOsx + ["ruby_cocoa"]
        end
      end
      describe "when there is no File at the path RubycocoaFramework" do
        it "should return DefaultBackendsOsx" do
          File.stub(:exists?).with(Plist4r::Config::CoreFoundationFramework).and_return(true)
          File.stub(:exists?).with(Plist4r::Config::RubycocoaFramework).and_return(false)
          Plist4r::Config.default_backends.should == Plist4r::Config::DefaultBackendsOsx
        end
      end
    end
  end
end

