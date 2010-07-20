
require 'spec_helper'

describe Plist4r::Backend, "#initialize" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @backend = Plist4r::Backend.new @plist
  end
  
  it "should set @plist to the supplied plist" do
    @backend.instance_eval { @plist }.should == @plist
  end
end

describe Plist4r::Backend, "#generic_call" do
  before(:each) do
    class Plist4r::Backend::Test
      def respond_to? meth, private=false
        return true if meth.to_s == "to_format"
        return true if meth.to_s == "from_format"
        return false
      end
    end
    @backend_module_const = Plist4r::Backend::Test.new
    
    @plist_cache = Plist4r::PlistCache.new "@plist"
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)

    @plist_cache.stub!(:send).with(:to_format).and_return("plist_string_of_type_format")
    @plist_cache.stub!(:send).with(:from_string).and_return(@plist)

    @plist = Plist4r::Plist.new
    @plist.stub!(:file_format).and_return(:format)
    @plist.stub!(:filename_path).and_return("filename_path")
    @plist.stub!(:from_string).and_return("plist_string_of_type_format")

    @backend = Plist4r::Backend.new @plist
    File.stub(:open).with("filename_path",'w').and_yield("plist_string_of_type_format")

    File.stub(:read).with("filename_path").and_return("plist_string_of_type_format")
    Plist4r.stub!(:string_detect_format).with("plist_string_of_type_format").and_return("format")
  end
  
  it "should follow the :save calling path when he supplied method_sym is :save" do
    @plist.should_receive(:file_format).and_return(:format)
    @backend_module_const.stub!(:respond_to?).and_return(true)
    @backend_module_const.should_receive(:respond_to?).with("to_format")
    File.should_receive(:open).with("filename_path",'w').and_yield("plist_string_of_type_format")
    @backend.generic_call(@backend_module_const,:save)
  end

  it "should call Plist4r::Config[:default_format] if @plist.file_format is nil" do
    @plist.stub!(:file_format).and_return(nil)
    Plist4r::Config.stub!(:[]).with(:default_format).and_return(:format)
    Plist4r::Config.should_receive(:[]).with(:default_format).and_return(:format)
    @backend.generic_call(@backend_module_const,:save)
  end

  it "should return an exception when the supplied backend has no matching to_fmt save method" do
    @backend_module_const.stub!(:respond_to?).and_return(false)
    @backend.generic_call(@backend_module_const,:save).should be_a_kind_of(Exception)
  end

  it "should follow the :open calling path when he supplied method_sym is :open" do
    # @plist.should_receive(:instance_eval).with("@from_string = File.read(filename_path)")
    # @plist.should_receive(:instance_eval)
    Plist4r.should_receive(:string_detect_format).with("plist_string_of_type_format").and_return("format")
    @plist_cache.should_receive(:send).with(:from_string)
    @backend_module_const.stub!(:respond_to?).and_return(true)
    @backend_module_const.should_receive(:respond_to?).with("from_format")

    @backend.generic_call(@backend_module_const,:open)
    @backend.instance_eval { @from_string_fmt }.should == "format"
  end

  it "should return an exception when the supplied backend has no matching from_fmt open method" do
    @backend_module_const.stub!(:respond_to?).and_return(false)
    @backend.generic_call(@backend_module_const,:open).should be_a_kind_of(Exception)
  end

  it "should follow the :from_string calling path when he supplied method_sym is :from_string" do
    Plist4r.should_receive(:string_detect_format).with("plist_string_of_type_format").and_return("format")
    @backend_module_const.stub!(:respond_to?).and_return(true)
    @backend_module_const.should_receive(:respond_to?).with("from_format")
    @backend_module_const.stub!(:send).with(:from_format, @plist)
    @backend_module_const.should_receive(:send).with(:from_format, @plist)
    @plist.should_receive(:file_format).with("format")

    @backend.generic_call(@backend_module_const,:from_string)
  end

  it "should return an exception when the supplied backend has no matching from_fmt method" do
    @backend_module_const.stub!(:respond_to?).and_return(false)
    @backend.generic_call(@backend_module_const,:from_string).should be_a_kind_of(Exception)
  end
end

describe Plist4r::Backend, "#call" do
  before(:each) do
    module Plist4r::Backend::Backend1
    end
    module Plist4r::Backend::Backend2
    end
    module Plist4r::Backend::Backend3
    end

    @plist = Plist4r::Plist.new
    @backend = Plist4r::Backend.new @plist
    Plist4r::Config.stub(:[]).with(:backend_timeout).and_return(15)
    Plist4r::Config.stub(:[]).with(:raise_any_failure).and_return(false)
    $stderr.stub(:puts)
  end

  it "should raise an error if the supplied method_sym isnt a PlistCacheApiMethod" do
    lambda { @backend.call :not_a_plist_cache_api_method }.should raise_error(Exception)
  end

  describe "when method_sym is any type of PlistCacheApiMethod" do
    before(:each) do
      @method_sym = :open
    end

    describe "when there is only one backend that implements method_sym" do
      before(:each) do
        @backends = [:backend1]
        @plist.stub!(:backends).and_return(@backends)
      end

      it "should follow the default calling path when the supplied method_sym is valid and the first backend implements it" do
        module Plist4r::Backend::Backend1
          class << self
            def open plist
              return plist
            end
          end
        end
        @plist.should_receive(:backends).and_return(@backends)
        @backends.should_receive(:each).and_yield(:backend1)
        Plist4r::Config.should_receive(:[]).with(:backend_timeout)
        # Timeout.should_receive(:timeout)
        # Plist4r::Backend::Backend.should_receive(:respond_to?).with(@method_sym)
        # Plist4r::Backend::Backend.should_receive(:send).with(@method_sym, @plist)
        Plist4r::Backend::Backend1.should_receive(@method_sym).with(@plist).and_return(@plist)
        @backend.call(@method_sym).should == @plist
      end

      it "should raise an error when the only backend that implements method_sym raises an error" do
        @plist.should_receive(:backends).and_return(@backends)
        @backends.should_receive(:each).and_yield(:backend1)
        Plist4r::Config.should_receive(:[]).with(:backend_timeout)    
        # Timeout.should_receive(:timeout)
        # Plist4r::Backend::Backend.should_receive(:respond_to?).with(@method_sym)
        # Plist4r::Backend::Backend.should_receive(:send).with(@method_sym, @plist)
        Plist4r::Backend::Backend1.stub(@method_sym).with(@plist).and_raise(Exception)
        Plist4r::Backend::Backend1.should_receive(@method_sym).with(@plist).and_raise(Exception)
        lambda { @backend.call @method_sym }.should raise_error(Exception)
      end
    end
  end

  describe "when method_sym is a direct call ApiMethod (eg to_xml, to_binary, etc)" do
    before(:each) do
      @method_sym = :to_xml
    end

    describe "when there are 2 matching backends which implement method_sym and one which does not" do
      before(:each) do
        module Plist4r::Backend::Backend1
          class << self
            def to_xml plist
              return "xml_string"
            end
          end
        end
        module Plist4r::Backend::Backend3
          class << self
            def to_xml plist
              return "xml_string"
            end
          end
        end
        @backends = [:backend1,:backend2,:backend3]
        @plist.stub!(:backends).and_return(@backends)
      end

      it "should not raise an error when at least 1 backend which implements method_sym does not raise an error" do
        Plist4r::Backend::Backend1.stub(@method_sym).with(@plist).and_raise(Exception)
        lambda { @backend.call @method_sym }.should_not raise_error(Exception)
      end

      it "should raise an error when all backends which implement method_sym raise an error" do
        Plist4r::Backend::Backend1.stub(@method_sym).with(@plist).and_raise(Exception)
        Plist4r::Backend::Backend3.stub(@method_sym).with(@plist).and_raise(Exception)
        lambda { @backend.call @method_sym }.should raise_error(Exception)
      end

      describe "when the first backend raises an error, and the second backend does not" do
        before(:each) do
          Plist4r::Backend::Backend1.stub(@method_sym).with(@plist).and_raise(Exception)
        end

        it "should call method_sym on the second available backend" do
          Plist4r::Backend::Backend1.stub(@method_sym).with(@plist).and_raise(Exception)
          Plist4r::Backend::Backend3.should_receive(@method_sym).with(@plist)
          lambda { @backend.call @method_sym }.should_not raise_error(Exception)
        end

        it "should raise an error when Config[:raise_any_failure] is true" do
          Plist4r::Config.stub(:[]).with(:raise_any_failure).and_return(true)
          lambda { @backend.call @method_sym }.should raise_error(Exception)
        end
      end
    end
  end

  describe "when method_sym is a PrivateApiMethod (eg from_string, open, save etc)" do
    before(:each) do
      @method_sym = :from_string
    end
    
    describe "when the highest priority backend does not implement method_sym directly" do
      before(:each) do
        @backends = [:backend1,:backend2,:backend3]
        @plist.stub!(:backends).and_return(@backends)
        @backend.stub(:generic_call)
      end
      
      it "should call generic_call with the first backend module constant and the PrivateApiMethod method_sym" do
        @backend.should_receive(:generic_call).with(Plist4r::Backend::Backend1,@method_sym)
        @backend.call @method_sym
      end

      describe "when generic_call returns a valid value which is not an Exception" do
        before(:each) do
          @backend.stub(:generic_call).and_return(@plist)
        end

        it "should not call subsequent backends" do
          @backend.should_not_receive(:generic_call).with(Plist4r::Backend::Backend2,@method_sym)
          @backend.should_not_receive(:generic_call).with(Plist4r::Backend::Backend3,@method_sym)
          @backend.call @method_sym
        end

        it "should not raise an error" do
          lambda { @backend.call @method_sym }.should_not raise_error(Exception)
        end
        
        it "should return that value" do
          @backend.call(@method_sym).should == @plist
        end
      end
    end
  end

end

