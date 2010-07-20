
require 'spec_helper'

describe Plist4r::DataMethods, "#set_or_return" do
  before(:each) do
    class DataMethodsClass
      include Plist4r::DataMethods
    end
    @data_methods = DataMethodsClass.new
    @data_methods.instance_eval { @plist = Plist4r::Plist.new }
    @integer_keys = ["IntegerKey1","IntegerKey2"]
    @string_keys  = ["StringKey1","StringKey2"]
    @valid_keys = { :integer => @integer_keys, :string  => @string_keys }
    DataMethodsClass::ValidKeys = @valid_keys
    @plist = @data_methods.instance_eval { @plist }
  end
  
  it "should follow the default calling path when the supplied key is a known plist key" do
    @key = @integer_keys.first
    @integer_keys.stub(:include?).and_return(true)
    @data_methods.stub(:set_or_return_of_type)
    @valid_keys.should_receive(:each).and_yield(:integer,@integer_keys).and_yield(:string,@string_keys)
    @integer_keys.should_receive(:include?).with(@key)
    @string_keys.should_not_receive(:include?).with(@key)
    @data_methods.should_receive(:set_or_return_of_type)
    @data_methods.set_or_return(@key, "value")
  end

  it "should follow the alternate calling path when the supplied key is not a known plist key" do
    @key = @integer_keys.first
    @integer_keys.stub(:include?).and_return(false)
    @string_keys.stub(:include?).and_return(false)
    @data_methods.stub(:set_or_return_of_type)
    @valid_keys.should_receive(:each).and_yield(:integer,@integer_keys).and_yield(:string,@string_keys)
    @integer_keys.should_receive(:include?).with(@key)
    @string_keys.should_receive(:include?).with(@key)
    @plist.stub(:strict_keys).and_return(false)
    @plist.should_receive(:strict_keys)
    @data_methods.should_receive(:set_or_return_of_type)
    @data_methods.set_or_return(@key, "value")
  end
  
  it "should raise an error when strict_keys is true" do
    @key = @integer_keys.first
    @integer_keys.stub(:include?).and_return(false)
    @string_keys.stub(:include?).and_return(false)
    @data_methods.stub(:set_or_return_of_type)
    @valid_keys.should_receive(:each).and_yield(:integer,@integer_keys).and_yield(:string,@string_keys)
    @integer_keys.should_receive(:include?).with(@key)
    @string_keys.should_receive(:include?).with(@key)
    @plist.stub(:strict_keys).and_return(true)
    @plist.should_receive(:strict_keys)
    @data_methods.should_not_receive(:set_or_return_of_type)
    lambda { @data_methods.set_or_return(@key, "value") }.should raise_error(Exception)
  end
  
  after(:each) do
    class DataMethodsClass
      remove_const(:ValidKeys)
    end
  end
end

describe Plist4r::DataMethods, "#set_or_return_of_type" do
  before(:each) do
    class DataMethodsClass
      include Plist4r::DataMethods

      alias_method :validate_value_orig, :validate_value
      def validate_value key_type, key, value
      end
    end
    @data_methods = DataMethodsClass.new
  end

  it "should return the value of the stored @orig hash key, if the supplied value is nil" do
    @data_methods.instance_eval { @orig = { "Key1" => "value1", "Key2" => "value2" } }
    @data_methods.set_or_return_of_type(:key_type,"Key1").should == "value1"
    @data_methods.set_or_return_of_type(:key_type,"Key2").should == "value2"
  end
  
  it "should follow the alternate calling path when supplied value is not nil" do
    @data_methods.instance_eval { @hash = {} }
    @data_methods.set_or_return_of_type(:key_type,"Key1","value1")
    @data_methods.set_or_return_of_type(:key_type,"Key2","value2")
    
    @data_methods.instance_eval { @hash["Key1"] }.should == "value1"
    @data_methods.instance_eval { @hash["Key2"] }.should == "value2"
  end
  
  after(:each) do
    class DataMethodsClass
      alias_method :validate_value, :validate_value_orig
    end
  end
end
