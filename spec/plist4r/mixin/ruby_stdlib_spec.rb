
require 'spec_helper'

describe Object, "#method_name" do
  before(:each) do
    class Object
      def test_method_name
        method_name
      end
    end
    @object = Object.new
  end
  
  it "should return the name of the current method" do
    @object.test_method_name.should == "test_method_name"
  end
  
  after(:all) do
    class Object
      undef :test_method_name
    end
  end
end

describe Object, "#deep_clone" do
  before(:each) do
    @object = Object.new
    @object2 = Object.new
    @mershal_dump = Marshal.dump(@object)
    Marshal.stub!(:dump).and_return(@marshal_dump)
    Marshal.stub!(:load).with(@marshal_dump).and_return(@object2)
  end

  it "should call Marshal.dump with @object" do
    Marshal.should_receive(:dump).with(@object)
    @object.deep_clone
  end

  it "should call Marshal.load with @marshal_dump" do
    Marshal.should_receive(:load).with(@marshal_dump)
    @object.deep_clone
  end
  
  it "should return @object2" do
    @object.deep_clone.should == @object2
  end
end

describe Array, "#multidim?" do
  before(:each) do
    @empty_array = []
    @flat_array = [1,2,3]
    @mixed_array = [[1],2,[3]]
    @multi_array = [[1],[2],[3]]    
  end

  it "should return false for an empty array" do
    @empty_array.multidim?.should == false
  end
  
  it "should return false for a flat array" do
    @flat_array.multidim?.should == false
  end

  it "should return false for a mixed array" do
    @mixed_array.multidim?.should == false
  end

  it "should return true for a multidimensional array" do
    @multi_array.multidim?.should == true
  end
end

describe Array, "#to_ranges" do
  before(:each) do
    @a1 = [3,4,5,1,6,9,8]
    @r1 = [1..1,3..6,8..9]

    @a2 = [19,3,18,15,17,2,16]
    @r2 = [2..3,15..19]
  end
  
  it "should convert an array of integers into an array of ranges" do
    @a1.to_ranges.should == @r1
    @a2.to_ranges.should == @r2
  end
end

describe Hash, "#merge_array_of_hashes_of_arrays" do
  before(:each) do
    @aohoa1 = {}

    @aohoa2 = [
      { :array1 => [:a], :array2 => [:a,:b], :array3 => [:a,:b,:c] },
      { :array1 => [:aa], :array2 => [:aa,:bb], :array3 => [:aa,:bb,:cc] },
      { :array1 => [:aaa], :array2 => [:aaa,:bbb], :array3 => [:aaa,:bbb,:ccc] }
    ]

    @aohoa3 = { 
      :array1 => [:a,:aa,:aaa], 
      :array2 => [:a,:b,:aa,:bb,:aaa,:bbb], 
      :array3 => [:a,:b,:c,:aa,:bb,:cc,:aaa,:bbb,:ccc]
    }
  end

  it "should raise an error if the supplied argument is not an aohoa" do
    @not_a_aohoa1 = false
    lambda { @aohoa1.merge_array_of_hashes_of_arrays @not_a_aohoa1 }.should raise_error(Exception)

    @not_a_aohoa2 = [
      false,
      { :array1 => [11], :array2 => [11,22], :array3 => [11,22,33], },
      { :array1 => [111], :array2 => [111,222], :array3 => [111,222,333], },
    ]
    lambda { @aohoa1.merge_array_of_hashes_of_arrays @not_a_aohoa2 }.should raise_error(Exception)

    @not_a_aohoa3 = [
      { :array1 => [1], :array2 => [1,2], :array3 => [1,2,3], },
      false,
      { :array1 => [111], :array2 => [111,222], :array3 => [111,222,333], },
    ]
    lambda { @aohoa1.merge_array_of_hashes_of_arrays @not_a_aohoa3 }.should raise_error(Exception)

    @not_a_aohoa4 = [
      { :array1 => [1], :array2 => [1,2], :array3 => [1,2,3], },
      { :array1 => [11], :array2 => [11,22], :array3 => [11,22,33], },
      { :array1 => false, :array2 => [111,222], :array3 => [111,222,333], },
    ]
    lambda { @aohoa1.merge_array_of_hashes_of_arrays @not_a_aohoa4 }.should raise_error(Exception)
  end
  
  it "should merge together 2 aohoa" do
    @aohoa1.merge_array_of_hashes_of_arrays(@aohoa2).should == @aohoa3
  end
end

describe Hash, "#merge_array_of_hashes_of_arrays!" do
  before(:each) do
    @aohoa1 = {}

    @aohoa2 = [
      { :array1 => [:a], :array2 => [:a,:b], :array3 => [:a,:b,:c] },
      { :array1 => [:aa], :array2 => [:aa,:bb], :array3 => [:aa,:bb,:cc] },
      { :array1 => [:aaa], :array2 => [:aaa,:bbb], :array3 => [:aaa,:bbb,:ccc] }
    ]

    @aohoa3 = { 
      :array1 => [:a,:aa,:aaa], 
      :array2 => [:a,:b,:aa,:bb,:aaa,:bbb], 
      :array3 => [:a,:b,:c,:aa,:bb,:cc,:aaa,:bbb,:ccc]
    }
  end
  
  it "should call merge_array_of_hashes_of_arrays in place" do
    @aohoa1 = {}
    @aohoa1.merge_array_of_hashes_of_arrays!(@aohoa2)
    @aohoa1.should == @aohoa3
  end
end

describe Range, "#size" do
  it "should return the size of @range" do
    @range = 0..3
    @range.size.should == 4

    @range = 5..5
    @range.size.should == 1
  end
end

describe Range, "#&" do
  it "should return the intersection of 2 discrete ranges" do
    (1..3).&(5..9).should == nil
    (1..3).&(4..9).should == nil
    (1..3).&(3..9).should == (3..3)
    (1..9).&(3..8).should == (3..8)
    (1..6).&(3..9).should == (3..6)
  end
  
  it "should raise an error when the supplied argument is not a Range" do
    not_a_range = false
    lambda { (1..3).&(not_a_range) }.should raise_error(Exception)
  end
end

describe Range, "#include_range?" do
  it "should return true if self wholely includes the supplied range" do
    (1..3).include_range?(1..1).should == true
    (1..3).include_range?(3..3).should == true
    (1..3).include_range?(1..9).should == false
    (1..9).include_range?(3..8).should == true
    (1..6).include_range?(3..9).should == false
  end
  
  it "should raise an error when the supplied argument is not a Range" do
    not_a_range = false
    lambda { (1..3).include_range?(not_a_range) }.should raise_error(Exception)
  end
end

describe String, "#camelcase" do
  it "should return the CamelCased version of string" do
    "".camelcase.should == ""
    "string".camelcase.should == "String"
    "word1_word2".camelcase.should == "Word1Word2"
    "Word1Word2".camelcase.should == "Word1Word2"
  end
end

describe String, "#snake_case" do
  it "should return the snake_cased version of string" do
    "".snake_case.should == ""
    "String".snake_case.should == "string"
    "Word1Word2".snake_case.should == "word1_word2"
    "word1_word2".snake_case.should == "word1_word2"
  end
end

describe Float, "#round" do
  it "should round self to the supplied number of decimal places" do
    @f = 0.123456789
    @f.round(0).to_s.should == "0.0"
    @f.round(1).to_s.should == "0.1"
    @f.round(2).to_s.should == "0.12"
    @f.round(3).to_s.should == "0.123"
  end
end

