require 'spec_helper'

describe Rack::Metadata do
  def base_metadata
    {:some_key => :some_value}
  end

  def base_config(hsh = base_metadata)
    Rack::Metadata::Config.from(hsh)
  end

  describe "#call" do
    it "can be constructed with a hash instead of a config object" do
      hsh = {:color => "Red", :virtue => "Beauty"}
      app = rack_app(OK_APP, Rack::Metadata, hsh)
      rsp = app.call(rack_env)
      rsp.headers.should include({"X-Color" => "Red"}, {"X-Virtue" => "Beauty"})
    end

    context "when config.enabled? returns false" do
      it "does not add headers"
      it "does not modify HTML"
      it "calls the underlying app when config.path is requested"
    end

    context "when config.add_headers? returns true" do
      it "adds the metadata pairs as response headers" do
        config = Rack::Metadata::Config.new do |config|
          config.metadata = {:color => "Blue", :virtue => "Justice"}
        end
        config.stub(:add_headers?).and_return(true)
        app = rack_app(OK_APP, Rack::Metadata, config)
        rsp = app.call(rack_env)
        rsp.headers.should include({"X-Color" => "Blue"}, {"X-Virtue" => "Justice"})
      end
    end

    context "when config.add_headers? returns false" do
      it "does not modify the response headers" do
        env = rack_env
        config = base_config
        config.stub(:add_headers?).and_return(false)
        app = rack_app(OK_APP, Rack::Metadata, config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(OK_APP, env).headers
      end
    end
  end

  describe ".header_name" do
    it "prepends X-" do
      Rack::Metadata.header_name("Dog").should == "X-Dog"
    end

    it "capitalizes words" do
      Rack::Metadata.header_name("cat").should == "X-Cat"
    end

    it "converts symbols to strings" do
      Rack::Metadata.header_name(:giraffe).should == "X-Giraffe"
    end

    it "converts spaces to dashes" do
      Rack::Metadata.header_name("mountain lion").should == "X-Mountain-Lion"
    end

    it "converts underscores to dashes" do
      Rack::Metadata.header_name("mountain_lion").should == "X-Mountain-Lion"
    end
  end

  describe ".header_value" do
    it "converts to a string" do
      actual_values = [1, true, :true, nil]
      expected_values = ["1", "true", "true", ""]
      actual_values.zip(expected_values).each do |actual, expected|
        Rack::Metadata.header_value(actual).should == expected
      end
    end
  end
end
