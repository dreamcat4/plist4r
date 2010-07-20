
require 'spec_helper'

describe Plist4r::PlistCache, "#intialize" do
  before(:each) do

    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)

    @plist_cache = Plist4r::PlistCache.new "@plist"
  end
  
  it "should set @checksum to {}" do
    @plist_cache.instance_eval { @checksum }.should == {}
  end
  
  it "should set @plist to the supplied parameter" do
    @plist_cache.instance_eval { @plist }.should == "@plist"
  end
  
  it "should set @backends to a Plist4r::Backend object" do
    @plist_cache.instance_eval { @backend }.should == @backend
  end
end

describe Plist4r::PlistCache, "#from_string" do
  before(:each) do
    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)
    @backend.stub!(:call).and_return("from_string")

    @plist = Plist4r::Plist.new
    @plist_cache = Plist4r::PlistCache.new @plist
    @plist.stub!(:detect_plist_type).and_return("plist_type")
    @plist.stub!(:file_format).and_return("file_format")
  end
  
  it "should follow the default calling path if the cached @from_string has not changed" do
    @plist.instance_eval { @from_string = "from_string" }
    @plist_cache.instance_eval { @from_string = "from_string" }
    @plist_cache.instance_eval { @from_string_plist_type = "plist_type" }
    @backend.should_not_receive(:call).with(:from_string)
    @plist_cache.from_string
  end
  
  it "should call @plist.detect_plist_type if the cached @from_string_plist_type is stale, or empty" do
    @plist.instance_eval { @from_string = "from_string" }
    @plist.instance_eval { @plist_type = "plist_type" }
    @plist.should_receive(:detect_plist_type)
    @plist_cache.instance_eval { @from_string = "from_string" }
    @plist_cache.instance_eval { @from_string_plist_type = "stale" }
    @plist_cache.from_string
  end
  
  it "should call @plist.file_format if the @plist.file_format was changed from the cached @from_string_file_format" do
    @plist.instance_eval { @from_string = "from_string" }
    @plist.instance_eval { @file_format = "file_format" }
    @plist.should_receive(:file_format).with("cached_file_format")
    @plist_cache.instance_eval { @from_string = "from_string" }
    @plist_cache.instance_eval { @from_string_file_format = "cached_file_format" }
    @plist_cache.from_string
  end
  
  it "should follow the alternate calling path if the cached @from_string is stale, or empty" do
    @plist.instance_eval { @from_string = "from_string" }
    @plist.instance_eval { @plist_type = "plist_type" }
    @plist_cache.instance_eval { @from_string = "stale" }
    @plist_cache.instance_eval { @from_string_plist_type = "stale" }
    @backend.should_receive(:call).with(:from_string)
    @plist.should_receive(:detect_plist_type)

    @plist_cache.from_string
    @plist_cache.instance_eval { @from_string }.should == "from_string"
    @plist_cache.instance_eval { @from_string_plist_type }.should == "plist_type".to_sym
  end

  it "should return @plist" do
    @plist_cache.from_string.should == @plist
  end
end

describe Plist4r::PlistCache, "#update_checksum_for" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.instance_eval { @hash }
    @plist_cache = Plist4r::PlistCache.new @plist
    @checksum = @plist_cache.instance_eval { @checksum }
  end
  
  it "should call @plist.to_hash" do
    @plist.should_receive(:to_hash)
    @plist_cache.update_checksum_for(:fmt)
  end
  
  it "should call hash on @hash" do
    @hash.should_receive(:hash)
    @plist_cache.update_checksum_for(:fmt)
  end

  it "should call []= on @checksum with the supplied fmt" do
    @checksum.should_receive(:[]=).with(:fmt,@hash.hash)
    @plist_cache.update_checksum_for(:fmt)
  end
end

describe Plist4r::PlistCache, "#needs_update_for" do
  before(:each) do
    @plist = Plist4r::Plist.new
    @hash = @plist.instance_eval { @hash }
    @plist_cache = Plist4r::PlistCache.new @plist
    @checksum = @plist_cache.instance_eval { @checksum }
  end
  
  it "should call @plist.to_hash" do
    @plist.should_receive(:to_hash)
    @plist_cache.needs_update_for(:fmt)
  end
  
  it "should call hash on @hash" do
    @hash.should_receive(:hash)
    @plist_cache.needs_update_for(:fmt)
  end

  it "should call [] on @checksum with the supplied fmt" do
    @checksum.should_receive(:[]).with(:fmt)
    @plist_cache.needs_update_for(:fmt)
  end
end

describe Plist4r::Plist, "#to_xml" do
  before(:each) do
    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)
    @backend.stub!(:call).and_return("xml_string")

    @plist = Plist4r::Plist.new
    @plist_cache = Plist4r::PlistCache.new @plist
    @plist_cache.instance_eval { @xml = "cached_xml_string" }
    @plist_cache.stub!(:needs_update_for).and_return(false)
    @plist_cache.stub!(:update_checksum_for)
  end

  it "should follow the default calling path when the xml checksum for @hash is stale" do
    @plist_cache.stub!(:needs_update_for).and_return(true)
    @backend.should_receive(:call).with(:to_xml)
    @plist_cache.should_receive(:update_checksum_for).with(:xml)
    @plist_cache.to_xml
    @plist_cache.instance_eval { @xml }.should == "xml_string"
  end

  it "should follow the default calling path when @xml is nil" do
    @plist_cache.instance_eval { @xml = nil }
    @backend.should_receive(:call).with(:to_xml)
    @plist_cache.should_receive(:update_checksum_for).with(:xml)
    @plist_cache.to_xml
    @plist_cache.instance_eval { @xml }.should == "xml_string"
  end
end

describe Plist4r::Plist, "#to_binary" do
  before(:each) do
    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)
    @backend.stub!(:call).and_return("binary_string")

    @plist = Plist4r::Plist.new
    @plist_cache = Plist4r::PlistCache.new @plist
    @plist_cache.instance_eval { @binary = "cached_binary_string" }
    @plist_cache.stub!(:needs_update_for).and_return(false)
    @plist_cache.stub!(:update_checksum_for)
  end

  it "should follow the default calling path when the binary checksum for @hash is stale" do
    @plist_cache.stub!(:needs_update_for).and_return(true)
    @backend.should_receive(:call).with(:to_binary)
    @plist_cache.should_receive(:update_checksum_for).with(:binary)
    @plist_cache.to_binary
    @plist_cache.instance_eval { @binary }.should == "binary_string"
  end

  it "should follow the default calling path when @binary is nil" do
    @plist_cache.instance_eval { @binary = nil }
    @backend.should_receive(:call).with(:to_binary)
    @plist_cache.should_receive(:update_checksum_for).with(:binary)
    @plist_cache.to_binary
    @plist_cache.instance_eval { @binary }.should == "binary_string"
  end
end

describe Plist4r::Plist, "#to_gnustep" do
  before(:each) do
    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)
    @backend.stub!(:call).and_return("gnustep_string")

    @plist = Plist4r::Plist.new
    @plist_cache = Plist4r::PlistCache.new @plist
    @plist_cache.instance_eval { @gnustep = "cached_gnustep_string" }
    @plist_cache.stub!(:needs_update_for).and_return(false)
    @plist_cache.stub!(:update_checksum_for)
  end

  it "should follow the default calling path when the gnustep checksum for @hash is stale" do
    @plist_cache.stub!(:needs_update_for).and_return(true)
    @backend.should_receive(:call).with(:to_gnustep)
    @plist_cache.should_receive(:update_checksum_for).with(:gnustep)
    @plist_cache.to_gnustep
    @plist_cache.instance_eval { @gnustep }.should == "gnustep_string"
  end

  it "should follow the default calling path when @gnustep is nil" do
    @plist_cache.instance_eval { @gnustep = nil }
    @backend.should_receive(:call).with(:to_gnustep)
    @plist_cache.should_receive(:update_checksum_for).with(:gnustep)
    @plist_cache.to_gnustep
    @plist_cache.instance_eval { @gnustep }.should == "gnustep_string"
  end
end

describe Plist4r::PlistCache, "#open" do
  before(:each) do
    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)
    @backend.stub!(:call).and_return("gnustep_string")

    @plist = Plist4r::Plist.new
    @plist_cache = Plist4r::PlistCache.new @plist
  end
  
  it "should call @backend.call with :open" do
    @backend.should_receive(:call).with(:open)
    @plist_cache.open
  end
  
  it "should return @plist" do
    @plist_cache.open.should == @plist
  end
end

describe Plist4r::PlistCache, "#save" do
  before(:each) do
    @backend = Plist4r::Backend.new "@plist"
    Plist4r::Backend.stub(:new).and_return(@backend)
    @backend.stub!(:call).and_return("gnustep_string")

    @plist = Plist4r::Plist.new
    @plist_cache = Plist4r::PlistCache.new @plist
  end

  it "should call @backend.call with :save" do
    @plist.filename_path "filename_path"
    @backend.should_receive(:call).with(:save)
    @plist_cache.save
  end
  
  it "should return @plist.filename_path" do
    @plist.filename_path "filename_path"
    @plist_cache.save.should == @plist.filename_path
  end
end

