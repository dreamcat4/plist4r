
require 'spec_helper'

describe Plist4r::Plist, "#initialize" do

  before(:each) do
    Plist4r::Config.stub!(:[]).with(:strict_keys).and_return("Config[:strict_keys]")
    Plist4r::Config.stub!(:[]).with(:backends).and_return("Config[:backends]")
    Plist4r::Config.stub!(:[]).with(:default_path).and_return("Config[:default_path]")

    @plist_cache = Plist4r::PlistCache.new "@plist"
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)

    @plist.stub(:edit)
    @plist = Plist4r::Plist.new
  end

  it "should return a Plist4r::Plist object" do
    @plist.should be_a_kind_of(Plist4r::Plist)
  end

  it "should set @hash to a Plist4r::OrderedHash" do
    @plist.instance_eval { @hash }.should be_a_kind_of(Plist4r::OrderedHash)
  end

  it "should set @strict_keys to Config[:strict_keys]" do
    @plist.instance_eval { @strict_keys }.should == "Config[:strict_keys]"
  end

  it "should set @backends to Config[:backends]" do
    @plist.instance_eval { @backends }.should == "Config[:backends]"
  end

  it "should set @path to Config[:default_path]" do
    @plist.instance_eval { @path }.should == "Config[:default_path]"
  end

  it "should call parse_opts if the first argument is a Hash" do
    hash = { "key" => "value" }
    @plist.should_receive(:parse_opts).with(hash)
    @plist.instance_eval{ initialize(hash) }
  end

  it "should set @filename if the first argument is a String or Symbol" do
    @plist = Plist4r::Plist.new("filename")
    @plist.instance_eval { @filename }.should == "filename"
    @plist = Plist4r::Plist.new(:filename)
    @plist.instance_eval { @filename }.should == :filename.to_s
  end

  it "should raise an error when the first argument is not a Hash, String, Symbol, or nil" do
    not_a_hash_string_symbol_or_nil = false
    lambda { Plist4r::Plist.new(not_a_hash_string_symbol_or_nil) }.should raise_error(Exception)
  end

  it "should set @plist_cache to a Plist4r::PlistCache object" do
    @plist.instance_eval { @plist_cache }.should == @plist_cache
  end

  it "should call edit with block if a block is given" do
    @plist.should_receive(:edit)
    @plist.instance_eval{ initialize(){} }
  end

  it "should not call edit with block if no block is given" do
    @plist.should_not_receive(:edit)
    @plist.instance_eval{ initialize() }
  end

end

describe Plist4r::Plist, "#from_string" do
  before(:each) do
    Plist4r.stub!(:string_detect_format).with("string").and_return(:plist_format)

    @plist_cache = Plist4r::PlistCache.new "@plist"
    @plist_cache.stub!(:from_string).and_return(@plist)
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)

    @plist = Plist4r::Plist.new
  end

  it "should call Plist4r.string_detect_format with the supplied string" do
    Plist4r.should_receive(:string_detect_format).and_return(:plist_format)
    @plist.from_string("string")
  end

  it "should not raise an exception if Plist4r.string_detect_format returns a value" do
    lambda { @plist.from_string("string") }.should_not raise_error(Exception)
  end

  it "should call Plist4r::PlistCache.new with self when @plist_cache is nil" do
    Plist4r::PlistCache.should_receive(:new).with(@plist)
    @plist.instance_eval { @plist_cache = nil }
    @plist.from_string("string")
  end

  it "should set @from_string to the supplied string and call @plist.cache.from_string" do
    @plist_cache.should_receive(:from_string)
    @plist.from_string("string")
    @plist.instance_eval { @from_string }.should == "string"
  end

  it "should raise an exception if Plist4r.string_detect_format returns nil" do
    Plist4r.stub!(:string_detect_format).with("string").and_return(nil)
    lambda { @plist.from_string("string") }.should raise_error(Exception)
  end

  it "should return @from_string for an argument of nil" do
    from_string = "string"
    @plist.instance_eval { @from_string = from_string }
    @plist.from_string.should == from_string
  end

  it "should raise an error for an argument that is not a string, or nil" do
    not_a_string_or_nil = false
    lambda { @plist.from_string(not_a_string_or_nil) }.should raise_error(Exception)
  end

end

describe Plist4r::Plist, "#filename" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end

  it "should raise an error when the supplied argument is not a string, or nil" do
    not_a_string_or_nil = false
    lambda { @plist.filename not_a_string_or_nil }.should raise_error(Exception)
  end
end

describe Plist4r::Plist, "#path" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end

  it "should raise an error when the supplied argument is not a string, or nil" do
    not_a_string_or_nil = false
    lambda { @plist.path not_a_string_or_nil }.should raise_error(Exception)
  end
end

describe Plist4r::Plist, "#filename_path" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist.filename_path "/dirname/basename"
  end
  
  it "should set @filename to basename when given a filename path" do
    @plist.instance_eval { @filename }.should == "basename"
  end

  it "should set @path to /dirname when given a filename path" do
    @plist.instance_eval { @path }.should == "/dirname"
  end

  it "should return /dirname/basename when no argument is given" do
    @plist.filename_path.should == "/dirname/basename"
  end
  
  it "should call File.expand_path with @filename, @path when no argument is given" do
    File.should_receive(:expand_path).with("basename", "/dirname")
    @plist.filename_path
  end
  
  it "should raise an error when the supplied argument is not a string, or nil" do
    not_a_string_or_nil = false
    lambda { @plist.filename_path not_a_string_or_nil }.should raise_error(Exception)
  end
end

describe Plist4r::Plist, "#file_format" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end

  it "should return @file_format when the supplied argument is nil" do
    @plist.file_format "xml"
    @plist.file_format.should == "xml"
    @plist.file_format :xml
    @plist.file_format.should == :xml.to_s
  end

  it "should raise an error when the supplied argument is not a recognised plist file format" do
    not_a_recognised_plist_file_format = false
    lambda { @plist.file_format not_a_recognised_plist_file_format }.should raise_error(Exception)        
  end

  it "should raise an error when the supplied argument is not a string, symbol, or nil" do
    not_a_string_symbol_or_nil = false
    lambda { @plist.file_format not_a_string_symbol_or_nil }.should raise_error(Exception)    
  end
end

describe Plist4r::Plist, "#detect_plist_type" do
  before(:each) do
    class Plist4r::PlistType::Type < Plist4r::PlistType
    end
    class Plist4r::PlistType::Type2 < Plist4r::PlistType
    end
    @plist = Plist4r::Plist.new
  end

  it "should iterate over the array of known plist types and evaluate any strings, or symbols" do
    Plist4r::Config.stub!(:[]).with(:types).and_return(["type",:type])
    # @plist.stub!(:eval).with("::Plist4r::PlistType::Type").and_return(Plist4r::PlistType::Type)
    @plist.stub!(:eval).and_return(Plist4r::PlistType::Type)
    @plist.detect_plist_type
  end

  it "should raise an error for a Config[:types] array element that is not a string, symbol, Class, or nil" do
    Plist4r::Config.stub!(:[]).with(:types).and_return([false])
    lambda { @plist.detect_plist_type }.should raise_error(Exception)
  end
  
  it "should call match_stat on each known Plist4r::PlistType" do
    Plist4r::Config.stub!(:[]).with(:types).and_return([:type,:type2])
    @stat_t = { :matches => 0, :ratios => "ratios" }
    Plist4r::PlistType::Type.should_receive(:match_stat).and_return(@stat_t)
    Plist4r::PlistType::Type2.should_receive(:match_stat).and_return(@stat_t)
    Plist4r::PlistType::Type.stub!(:match_stat).and_return(@stat_t)
    @plist.detect_plist_type
  end
end

describe Plist4r::Plist, "#plist_type" do
  before(:each) do
    class Plist4r::PlistType::Type < Plist4r::PlistType
    end
    @plist = Plist4r::Plist.new
  end

  it "should set the default @plist_type to a kind of Plist4r::PlistType" do
    @plist.instance_eval { @plist_type }.should be_a_kind_of(Plist4r::PlistType)
  end

  it "should set @plist_type to an instance of the supplied class" do
    @plist.plist_type(Plist4r::PlistType::Type)
    @plist.instance_eval { @plist_type }.should be_a_kind_of(Plist4r::PlistType::Type)
  end

  it "should set @plist_type to an instance of the class evaluated of the supplied string or symbol" do
    @plist.stub!(:eval).and_return(Plist4r::PlistType::Type)
    @plist.should_receive(:eval).with("::Plist4r::PlistType::Type")
    @plist.plist_type("type")
    @plist.instance_eval { @plist_type }.should be_a_kind_of(Plist4r::PlistType::Type)
  end

  it "should return a symbol representing the classname of the @plist_type instance" do
    @plist.plist_type("type").should == :type
    @plist.plist_type.should == :type
  end

  it "should raise an error if the supplied class is not a Plist4r::PlistType" do
    not_a_plist4r_plist_type = Object
    lambda { @plist.plist_type(not_a_plist4r_plist_type) }.should raise_error(Exception)
  end

  it "should raise an error when the supplied argument is not a class, symbol, string or nil" do
    not_a_class_symbol_string_or_nil = false
    lambda { @plist.plist_type(not_a_class_symbol_string_or_nil) }.should raise_error(Exception)
  end
end

describe Plist4r::Plist, "#backends" do
  before(:each) do
    module Plist4r::Backend::Backend1
    end
    module Plist4r::Backend::Backend2
    end
    @plist = Plist4r::Plist.new
  end

  it "should raise an error if one of the supplied symbols or strings are not a recognised Plist4r::Backend" do
    not_a_plist4r_backend = "not_a_plist4r_backend"
    lambda { @plist.backends([not_a_plist4r_backend]) }.should raise_error(Exception)    
  end
  
  it "should set @backends to an array of valid backend symbols (or strings)" do
    @plist.backends([:backend1, :backend2])
    @plist.instance_eval { @backends }.should == [:backend1, :backend2]
    @plist.backends(["backend1", "backend2"])
    @plist.instance_eval { @backends }.should == [:backend1, :backend2]
  end
  
  it "should raise an error if the supplied array contains an element that is not a symbol, string, or nil" do
    not_a_symbol_string_or_nil = false
    lambda { @plist.backends([not_a_symbol_string_or_nil]) }.should raise_error(Exception)
  end

  it "should return @backends when supplied with a nil argument" do
    @plist.instance_eval { @backends = "backends" }
    @plist.backends.should == "backends"
  end
  
  it "should raise an error when the supplied argument is not an array, or nil" do
    not_an_array_or_nil = false
    lambda { @plist.backends(not_an_array_or_nil) }.should raise_error(Exception)
  end
end

describe Plist4r::Plist, "#parse_opts" do
  before(:each) do
    class Plist4r::Plist
      OldOptionsHash = OptionsHash
    end
    @plist = Plist4r::Plist.new
  end
  
  it "should call any methods on @plist, that are included in OptionsHash and the supplied hash of options" do
    Plist4r::Plist::OptionsHash.replace [:meth1, "meth2"]
    @plist.stub!(:meth1)
    @plist.stub!(:meth2)
    @plist.should_receive(:meth1).with("meth1arg")
    @plist.should_receive(:meth2).with("meth2arg")
    @plist.parse_opts({ :meth1 => "meth1arg", :meth2 => "meth2arg" })
    
  end

  after(:all) do
    class Plist4r::Plist
      OptionsHash.replace OldOptionsHash
    end
  end
end

describe Plist4r::Plist, "#open" do
  before(:each) do
    @plist_cache = Plist4r::PlistCache.new "@plist"
    @plist_cache.stub(:open)
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)
    @plist = Plist4r::Plist.new
  end
  
  it "should set @filename to the supplied string" do
    @plist.open("filename")
    @plist.instance_eval { @filename }.should == "filename"
  end

  it "should raise an error unless @filename is non-nil" do
    lambda { @plist.open }.should raise_error(Exception)
  end
  
  it "should call @plist_cache.open" do
    @plist_cache.should_receive(:open).twice
    @plist.open("filename")
    @plist.open
  end
end

describe Plist4r::Plist, "#<<" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end
  
  it "should call edit with the supplied arguments" do
    edit_args = [:arg1, :arg2, :etc]
    @plist.should_receive(:edit).with(edit_args)
    @plist.<< edit_args
  end
end

describe Plist4r::Plist, "#edit" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist.stub(:instance_eval)
  end
  
  it "should call instance_eval with the supplied arguments" do
    edit_args = [:arg1, :arg2, :etc]
    @plist.should_receive(:instance_eval).with(edit_args)
    @plist.edit edit_args
  end

  it "should call detect_plist_type" do
    edit_args = [:arg1, :arg2, :etc]
    @plist.should_receive(:detect_plist_type)
    @plist.edit edit_args
  end
end

describe Plist4r::Plist, "#method_missing" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)
    @plist = Plist4r::Plist.new
  end

  it "should call @plist_type.send with the supplied arguments" do
    method_missing_args = [:method_sym, :arg1, :arg2, :etc]
    @plist_type.should_receive(:method_missing).with(method_missing_args)
    @plist.method_missing(method_missing_args)
  end
end

describe Plist4r::Plist, "#import_hash" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end
  
  it "should set @hash to be a kind of ordered hash when the supplied argument is nil" do
    @plist.import_hash
    @plist.instance_eval { @hash }.should be_a_kind_of(Plist4r::OrderedHash)
  end
  
  it "should set @hash to be the supplied ordered hash" do
    ordered_hash = Plist4r::OrderedHash.new :key1 => "value1", :key2 => "value2"
    @plist.import_hash(ordered_hash)
    @plist.instance_eval { @hash }.should == ordered_hash
  end

  it "should raise an error when the supplied argument is not an ordered hash, or nil" do
    not_an_ordered_hash_or_nil = false
    lambda { @plist.import_hash(not_an_ordered_hash_or_nil) }.should raise_error(Exception)
  end
end

describe Plist4r::Plist, "#[]" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)

    @plist = Plist4r::Plist.new do
      key1 "value1"
      key2 "value2"
    end
  end
  
  it "should call set_or_return on @plist_type with the supplied key" do
    @plist_type.should_receive(:set_or_return).with("Key1")
    @plist["Key1"]
  end
end

describe Plist4r::Plist, "#[]=" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end
  
  it "should call store with the supplied key and value" do
    @plist.should_receive(:store).with("Key1","value1")
    @plist["Key1"] = "value1"
  end
end

describe Plist4r::Plist, "#store" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)
    @plist = Plist4r::Plist.new
  end
  
  it "should call set_or_return on @plist_type with the supplied key and value" do
    @plist_type.should_receive(:set_or_return).with("Key1","value1")
    @plist["Key1"] = "value1"
  end
end

describe Plist4r::Plist, "#select" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)
    @plist = Plist4r::Plist.new do
      key1 "value1"
      key2 "value2"
    end
    
    @hash = @plist.to_hash
    @hash.stub(:select).and_return([["Key1", "value1"],["Key2", "value2"]])
    @hash_copy = Plist4r::OrderedHash.new
    @hash_copy.store "Key1", "value1"
    @hash_copy.store "Key2", "value2"
    @hash.stub(:deep_clone).and_return(@hash_copy)
  end
  
  it "should call block_given?" do
    @plist.stub!(:block_given?).and_return(true)
    @plist.should_receive(:block_given?)
    @plist.select
  end
  
  describe "when a block is given" do
    it "should follow the default calling path" do
      @hash.should_receive(:select)
      @hash.should_receive(:deep_clone)
      @plist.should_receive(:clear)
      @plist.should_receive(:store).exactly(4).times

      @plist.select :key1, :key2 do
        true
      end
    end
  end
  
  describe "when no block is given" do
    it "should follow the alternate calling path" do
      @plist_type.should_receive(:array_dict).with(:select, :key1, :key2)
      @plist.select :key1, :key2
    end
  end
end

describe Plist4r::Plist, "#map" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)

    @plist = Plist4r::Plist.new do
      key1 "value1"
      key2 "value2"
    end
    
    @hash = @plist.to_hash
    @hash.stub(:select).and_return([["Key1", "value1"],["Key2", "value2"]])
    @hash_copy = Plist4r::OrderedHash.new
    @hash_copy.store "Key1", "value1"
    @hash_copy.store "Key2", "value2"
    @hash.stub(:deep_clone).and_return(@hash_copy)
  end
  
  it "should call block_given?" do
    @plist.stub!(:block_given?).and_return(true)
    @plist.should_receive(:block_given?)
    @plist.map do
    end
  end
  
  describe "when a block is given" do
    it "should follow the default calling path" do
      @plist.stub!(:yield).and_return(["SomeKey","some value"])
      @hash.should_receive(:deep_clone)
      @plist.should_receive(:clear)
      @hash_copy.should_receive(:each).once

      @plist.map do |k,v|
        [k,v]
      end
    end
  end
  
  describe "when no block is given" do
    it "should raise an error" do
      lambda { @plist.map }.should raise_error(Exception)
    end
  end
end

describe Plist4r::Plist, "#collect" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end
  
  it "should call map" do
    @plist.should_receive(:map)
    @plist.collect do |k,v|
      [k,v]
    end
  end
end

describe Plist4r::Plist, "#unselect" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end
  
  it "should call delete with the supplied keys" do
    @plist.should_receive(:delete).with(:arg1, :arg2)
    @plist.unselect :arg1, :arg2
  end
end

describe Plist4r::Plist, "#delete" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)
    @plist = Plist4r::Plist.new do
      key1 "value1"
      key2 "value2"
    end
  end
  
  it "should call @plist_type.array_dict with :unselect and the suppled keys" do
    @plist_type.should_receive(:array_dict).with(:unselect, :key1, :key2)
    @plist.unselect :key1, :key2
  end
end

describe Plist4r::Plist, "#delete_if" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)
    @plist = Plist4r::Plist.new do
      key1 "value1"
      key2 "value2"
    end

    @hash = @plist.to_hash
    @hash.stub(:select).and_return([["Key1", "value1"],["Key2", "value2"]])
    @hash_copy = Plist4r::OrderedHash.new
    @hash_copy.store "Key1", "value1"
    @hash_copy.store "Key2", "value2"
    # @hash.stub(:deep_clone).and_return(@hash_copy)
  end
  
  it "should call delete with the supplied keys" do
    @plist.should_receive(:delete).with(:arg1, :arg2)
    @plist.delete_if :arg1, :arg2
  end
  
  it "should call @hash.delete_if" do
    @hash.should_receive(:delete_if)
    @plist.delete_if :arg1, :arg2
  end
  
  it "should call @plist_type.hash with @hash" do
    @plist_type.should_receive(:hash).with(@hash)
    @plist.delete_if :arg1, :arg2
  end
end

describe Plist4r::Plist, "#clear" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)
    @plist = Plist4r::Plist.new do
      key1 "value1"
      key2 "value2"
    end
  end
  
  it "should call @plist_type.array_dict with :unselect_all" do
    @plist_type.should_receive(:array_dict).with(:unselect_all)
    @plist.clear
  end
end

describe Plist4r::Plist, "#merge!" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist_type = Plist4r::PlistType::Plist.new @plist
    @plist_type.stub(:method_missing)
    Plist4r::PlistType::Plist.stub(:new).and_return(@plist_type)

    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash

    @other_plist = Plist4r::Plist.new
    @other_hash = @other_plist.to_hash
  end
  
  it "should call plist_type" do
    @plist.should_receive(:plist_type)
    @other_plist.should_receive(:plist_type)
    @plist.merge! @other_plist
  end
  
  it "should follow the default calling path is the plist_type matches" do
    @plist.stub!(:plist_type).and_return(:plist_type)
    @other_plist.stub!(:plist_type).and_return(:plist_type)
    @hash.should_receive(:merge!).with(@other_hash)
    @plist_type.should_receive(:hash).with(@hash)

    @plist.merge! @other_plist
  end

  it "should raise an error if the plist_type differs" do
    @plist.stub!(:plist_type).and_return(:plist_type1)
    @other_plist.stub!(:plist_type).and_return(:plist_type2)
    lambda { @plist.merge! @other_plist }.should raise_error(Exception)
  end
  
end

describe Plist4r::Plist, "#include?" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
    @key = "Key"
  end
  
  it "should call @hash.include? with the supplied key" do
    @hash.should_receive(:include?).with(@key)
    @plist.include? @key
  end
end

describe Plist4r::Plist, "#has_key?" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
    @key = "Key"
  end
  
  it "should call @hash.has_key? with the supplied key" do
    @hash.should_receive(:has_key?).with(@key)
    @plist.has_key? @key
  end
end

describe Plist4r::Plist, "#empty?" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
  end
  
  it "should call @hash.empty?" do
    @hash.should_receive(:empty?)
    @plist.empty?
  end
end

describe Plist4r::Plist, "#each" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
  end
  
  it "should call @hash.each" do
    @hash.should_receive(:each)
    @plist.each
  end
end

describe Plist4r::Plist, "#length" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
  end
  
  it "should call @hash.length" do
    @hash.should_receive(:length)
    @plist.length
  end
end

describe Plist4r::Plist, "#size" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
  end
  
  it "should call @hash.size" do
    @hash.should_receive(:size)
    @plist.size
  end
end

describe Plist4r::Plist, "#keys" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.to_hash
  end
  
  it "should call @hash.keys" do
    @hash.should_receive(:keys)
    @plist.keys
  end
end

describe Plist4r::Plist, "#to_hash" do
  before(:each) do
    @plist = Plist4r::Plist.new
  end
  
  it "should return @hash" do
    @plist.to_hash.should == @plist.instance_eval { @hash }
  end
end

describe Plist4r::Plist, "#to_xml" do
  before(:each) do
    @plist_cache = Plist4r::PlistCache.new "@plist"
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)
    @plist = Plist4r::Plist.new
  end
  
  it "should call @plist_cache.to_xml" do
    @plist_cache.should_receive(:to_xml)
    @plist.to_xml
  end
end

describe Plist4r::Plist, "#to_binary" do
  before(:each) do
    @plist_cache = Plist4r::PlistCache.new "@plist"
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)
    @plist = Plist4r::Plist.new
  end
  
  it "should call @plist_cache.to_binary" do
    @plist_cache.should_receive(:to_binary)
    @plist.to_binary
  end
end

describe Plist4r::Plist, "#to_gnustep" do
  before(:each) do
    @plist_cache = Plist4r::PlistCache.new "@plist"
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)
    @plist = Plist4r::Plist.new
  end
  
  it "should call @plist_cache.to_gnustep" do
    @plist_cache.should_receive(:to_gnustep)
    @plist.to_gnustep
  end
end

describe Plist4r::Plist, "#save" do
  before(:each) do
    @plist_cache = Plist4r::PlistCache.new "@plist"
    Plist4r::PlistCache.stub(:new).and_return(@plist_cache)
    @plist = Plist4r::Plist.new
  end

  it "should raise an error if @filename is nil" do
    lambda { @plist.save }.should raise_error(Exception)
  end
  
  it "should call @plist_cache.save" do
    @plist.filename "filename"
    @plist_cache.should_receive(:save)
    @plist.save
  end
end

describe Plist4r::Plist, "#save_as" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @plist.stub!(:save)
  end

  it "should set @filename to the supplied filename" do
    @plist.save_as "filename"
    @plist.instance_eval { @filename }.should == "filename"    
  end

  it "should call save" do
    @plist.should_receive(:save)
    @plist.save_as "filename"
  end
end

