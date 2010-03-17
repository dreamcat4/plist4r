require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

module PlistSpecHelper
  def test_xml_plist
    @test_xml_plist ||= <<-'EOC'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict></dict></plist>
EOC
  end

  def valid_plist_attributes
    {
      :from_string => test_xml_plist,
      :filename => "test_xml.plist"
      :plist_type => "test_type"
      :backends => ["test"]
    }
  end
end


describe Plist4r::Plist, "initialize" do
  before do
    # set expected plist object
    # mock and stub the method call
  end

  describe "when the first argument is not a Hash, String, or Symbol"
    before do
    end

    it "should raise an error" do
    end
  end

  it "should return the new Plist object" do
    # .should_be an_instance_of(::Plist4r::Plist)
  end
end


