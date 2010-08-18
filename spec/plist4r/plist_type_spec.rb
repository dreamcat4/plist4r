
require 'spec_helper'

describe Plist4r::PlistType, "#initialize" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType.new @plist
  end

  it "should set @plist to the supplied plist" do
    @plist_type.instance_eval { @plist }.should == @plist
  end
  
  it "should set @hash and @orig to the supplied @plist.to_hash" do
    @plist_type.instance_eval { @hash }.should == @plist.to_hash
    @plist_type.instance_eval { @orig }.should == @plist.to_hash
  end
end

describe Plist4r::PlistType, "#hash" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType.new @plist
    @plist_type.instance_eval { @hash = "hash" }
  end
  
  it "should set @hash and @orig if the supplied hash is a Plist4r::OrderedHash" do
    hash = Plist4r::OrderedHash.new
    @plist_type.to_hash(hash)
    @plist_type.instance_eval { @hash }.should == hash
    @plist_type.instance_eval { @orig }.should == hash
  end
  
  it "should return @hash if there are no supplied arguments" do
    @plist_type.to_hash.should == "hash"
  end

  it "should raise an error when the supplied argument is not a Plist4r::OrderedHash, or nil" do
    not_a_plist4r_ordered_hash_or_nil = false
    lambda { @plist_type.to_hash(not_a_plist4r_ordered_hash_or_nil) }.should raise_error(Exception)
  end
end

describe Plist4r::PlistType, "#match_stat" do
  it "should follow the default calling path" do
    @valid_keys_values = []
    Plist4r::PlistType::ValidKeys.stub(:values).and_return(@valid_keys_values)
    @type_keys = []
    @valid_keys_values.stub(:flatten).and_return(@type_keys)
    @valid_keys_values.should_receive(:flatten).and_return(@type_keys)
    Plist4r::PlistType::ValidKeys.should_receive(:values).and_return(@valid_keys_values)
    @plist_keys = []
    @matches = []
    @plist_keys.stub(:&).with(@type_keys).and_return(@matches)
    @plist_keys.should_receive(:&).and_return(@matches)
    @matches.should_receive(:size).and_return(0)
    @type_keys.should_receive(:size).and_return(0)
    @matches.should_receive(:size).and_return(0)

    Plist4r::PlistType.match_stat @plist_keys
  end
end

describe Plist4r::PlistType, "#to_s" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType.new @plist
    @plist_type.instance_eval { @hash = "hash" }
  end

  it "should return @string if @string is not nil" do
    @plist_type.instance_eval { @string = "string" }
    @plist_type.to_s.should == "string"
  end
  
  it "should follow the alternate calling path when string is nil" do
    @plist_type.to_s.should == "plist_type"
    @plist_type.instance_eval { @string }.should == "plist_type"
  end
end

describe Plist4r::PlistType, "#to_sym" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType.new @plist
    @plist_type.instance_eval { @hash = "hash" }
  end

  it "should return @sym if @sym is not nil" do
    @plist_type.instance_eval { @sym = :symbol }
    @plist_type.to_sym.should == :symbol
  end

  it "should call to_s" do
    @string = "string"
    @plist_type.stub(:to_s).and_return(@string)
    @plist_type.should_receive(:to_s).and_return(@string)
    @string.stub(:to_sym).and_return(:symbol)
    @string.should_receive(:to_sym).and_return(:symbol)
    @plist_type.to_sym.should == :symbol
  end
end

describe Plist4r::PlistType, "#array_dict" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType.new @plist
    @plist_type.instance_eval { @hash = "hash" }
  end

  it "should follow the default calling path" do
    @hash = Plist4r::OrderedHash.new
    @array_dict = Plist4r::ArrayDict.new @hash
    Plist4r::ArrayDict.stub(:new).and_return(@array_dict)
    @method_sym = :method
    @result = Object.new
    @array_dict.stub(@method_sym).with(:arg1,:arg2,:etc).and_return(@result)
    @array_dict.stub(:hash).and_return(@hash)
    @plist_type.array_dict(@method_sym,:arg1,:arg2,:etc)
    @plist_type.instance_eval { @hash }.should == @hash
    @plist_type.instance_eval { @orig }.should == @hash
    @plist.instance_eval { @hash }.should == @hash
  end
  
end

