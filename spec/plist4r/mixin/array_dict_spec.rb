
require 'spec_helper'

describe Plist4r::ArrayDict, "#initialize" do
  before(:each) do
    @orig = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @orig
  end
  
  it "should follow the default calling path when the supplied index is nil" do
    orig = Plist4r::OrderedHash.new
    @array_dict.instance_eval { initialize orig }
    @array_dict.instance_eval { @orig }.should == @orig
    @array_dict.instance_eval { @hash }.should be_a_kind_of(Plist4r::OrderedHash)
  end

  it "should follow the alternate calling path when the supplied index is not nil" do
    orig = [nil,nil,@orig]
    @array_dict.instance_eval { initialize orig, 2 }
    @array_dict.instance_eval { @orig }.should == @orig
    @array_dict.instance_eval { @hash }.should be_a_kind_of(Plist4r::OrderedHash)
  end
end

describe Plist4r::ArrayDict, "#hash" do
  before(:each) do
    @orig = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @orig
  end
  
  it "should return @hash" do
    @array_dict.instance_eval { @hash = "hash" }
    @array_dict.hash.should == "hash"
  end
end

describe Plist4r::ArrayDict, "#select" do
  before(:each) do
    @orig = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @orig
  end
  
  it "should follow the default calling path" do
    @key1 = "key1"
    @key1.stub(:class).and_return(Symbol)
    @key1.stub(:to_s).and_return("key1")
    @key1.stub(:camelcase).and_return("Key1")
    @key2.stub(:class).and_return(Symbol)
    @key2.stub(:to_s).and_return("key2")
    @key2.stub(:camelcase).and_return("Key2")
    @keys = [@key1, @key2]
    @keys.stub(:flatten).and_return(@keys)

    @array_dict.instance_eval { @orig = { "Key1" => "value1", "Key2" => "value2", "Key3" => "value3" } }

    @array_dict.select(@keys)
    @array_dict.instance_eval { @hash }.should have_key("Key1")
    @array_dict.instance_eval { @hash }.should have_key("Key2")
    @array_dict.instance_eval { @hash }.should_not have_key("Key3")
  end
end

describe Plist4r::ArrayDict, "#unselect" do
  before(:each) do
    @orig = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @orig
  end
  
  it "should follow the default calling path" do
    @key1 = "key1"
    @key1.stub(:class).and_return(Symbol)
    @key1.stub(:to_s).and_return("key1")
    @key1.stub(:camelcase).and_return("Key1")
    @key2.stub(:class).and_return(Symbol)
    @key2.stub(:to_s).and_return("key2")
    @key2.stub(:camelcase).and_return("Key2")
    @keys = [@key1, @key2]
    @keys.stub(:flatten).and_return(@keys)

    @array_dict.instance_eval { @orig = { "Key1" => "value1", "Key2" => "value2", "Key3" => "value3" } }

    @array_dict.unselect(@keys)
    @array_dict.instance_eval { @hash }.should_not have_key("Key1")
    @array_dict.instance_eval { @hash }.should_not have_key("Key2")
    @array_dict.instance_eval { @hash }.should have_key("Key3")
  end
end

describe Plist4r::ArrayDict, "#unselect_all" do
  before(:each) do
    @orig = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @orig
  end
  
  it "should clear all keys in @hash" do
    @array_dict.instance_eval { @hash = { "Key1" => "value1", "Key2" => "value2", "Key3" => "value3" } }

    @array_dict.unselect_all
    @array_dict.instance_eval { @hash }.should be_a_kind_of(Plist4r::OrderedHash)

    @array_dict.instance_eval { @hash }.should_not have_key("Key1")
    @array_dict.instance_eval { @hash }.should_not have_key("Key2")
    @array_dict.instance_eval { @hash }.should_not have_key("Key3")
  end
end

describe Plist4r::ArrayDict, "#select_all" do
  before(:each) do
    @orig = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @orig
  end
  
  it "should set @hash to @orig" do
    @array_dict.instance_eval { @orig = "orig" }
    @array_dict.instance_eval { @hash = nil }
    @array_dict.select_all
    @array_dict.instance_eval { @hash }.should == "orig"
  end
end

