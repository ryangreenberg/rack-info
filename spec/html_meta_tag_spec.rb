require 'spec_helper'

describe Rack::Metadata::HTMLMetaTag do
  describe ".format_item" do
    it "returns a <meta> tag string" do
      tag = Rack::Metadata::HTMLMetaTag.format_item("color", "red")
      tag.should be_start_with("<meta")
      tag.should be_end_with(">")
    end

    it "converts the key into a name attribute" do
      tag = Rack::Metadata::HTMLMetaTag.format_item("color", "red")
      tag.should include('name="color"')
    end

    it "converts the value into a content attribute" do
      tag = Rack::Metadata::HTMLMetaTag.format_item("color", "red")
      tag.should include('content="red"')
    end

    it "escapes HTML entities in the key and value" do
      tag = Rack::Metadata::HTMLMetaTag.format_item(%|"it's & its"|, "my <item>")
      tag.should include('&quot;it&#x27;s &amp; its&quot;')
      tag.should include('my &lt;item&gt;')
    end
  end
end