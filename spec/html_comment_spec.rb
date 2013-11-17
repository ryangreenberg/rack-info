require 'spec_helper'

describe Rack::Metadata::HTMLComment do
  describe ".format" do
    before :each do
      @hsh = {:some_key => :some_value}
    end

    it "returns a string that starts with <!--" do
      Rack::Metadata::HTMLComment.format(@hsh).should be_start_with("<!--")
    end

    it "returns a string that ends with -->" do
      Rack::Metadata::HTMLComment.format(@hsh).should be_end_with("-->")
    end

    it "returns a string that includes the formatted values" do
      comment = Rack::Metadata::HTMLComment.format(@hsh)
      comment.should include(Rack::Metadata::HTMLComment.format_pairs(@hsh))
    end

    it "removes the string -- to avoid closing the comment early" do
      @hsh["value_including_html"] = "attempt to close comment early -->"
      comment = Rack::Metadata::HTMLComment.format(@hsh)
      comment.should include("attempt to close comment early >")
    end
  end

  describe ".format_pairs" do
    it "separates individual pairs with a newline" do
      hsh = {:a => 1, :b => 2}
      output = Rack::Metadata::HTMLComment.format_pairs(hsh)
      output.should include("\n")
    end

    it "sorts pairs alphabetically by key name" do
      hsh = {:c => 3, :b => 2, :a => 1}
      alphabetical_order = [[:a, 1], [:b, 2], [:c, 3]]
      expected_order = alphabetical_order.map do |ea|
        Rack::Metadata::HTMLComment.format_pair(*ea)
      end
      output = Rack::Metadata::HTMLComment.format_pairs(hsh)
      output.split("\n").should == expected_order
    end
  end

  describe ".format_pair" do
    it "separates the key and value with a colon" do
      output = Rack::Metadata::HTMLComment.format_pair("some_key", "some_value")
      output.should == "some_key: some_value"
    end

    it "converts key and value to strings" do
      output = Rack::Metadata::HTMLComment.format_pair(:some_key, :some_value)
      output.should == "some_key: some_value"
    end
  end
end